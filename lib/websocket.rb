# Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
# Lincense: New BSD Lincense
# Reference: http://tools.ietf.org/html/draft-hixie-thewebsocketprotocol

require "socket"
require "uri"

module Socky
  class WebSocket

    class << self
      attr_accessor(:debug)
    end

    class Error < RuntimeError
    end

    def initialize(arg, params = {})
      uri = arg.is_a?(String) ? URI.parse(arg) : arg
      if uri.scheme == "wss"
        raise(WebSocket::Error, "wss scheme is unimplemented")
      elsif uri.scheme != "ws"
        raise(WebSocket::Error, "unsupported scheme: #{uri.scheme}")
      end
      @path = (uri.path.empty? ? "/" : uri.path) + (uri.query ? "?" + uri.query : "")
      host = uri.host + (uri.port == 80 ? "" : ":#{uri.port}")
      origin = params[:origin] || "http://#{uri.host}"
      @socket = TCPSocket.new(uri.host, uri.port || 80)
      write(
        "GET #{@path} HTTP/1.1\r\n" +
        "Upgrade: WebSocket\r\n" +
        "Connection: Upgrade\r\n" +
        "Host: #{host}\r\n" +
        "Origin: #{origin}\r\n" +
        "\r\n")
      flush
      line = gets().chomp()
      raise(WebSocket::Error, "bad response: #{line}") if !(line =~ /\AHTTP\/1.1 101 /n)
      read_header()
      if @header["WebSocket-Origin"] != origin
        raise(WebSocket::Error,
          "origin doesn't match: '#{@header["WebSocket-Origin"]}' != '#{origin}'")
      end
      @handshaked = true

      @received = []
      @buffer = ""
    end

    attr_reader(:header, :path)

    def send(data)
      if !@handshaked
        raise(WebSocket::Error, "call WebSocket\#handshake first")
      end
      data = force_encoding(data.dup(), "ASCII-8BIT")
      write("\x00#{data}\xff")
      flush
    end

    def receive()
      if !@handshaked
        raise(WebSocket::Error, "call WebSocket\#handshake first")
      end
      packet = gets("\xff")
      return nil if !packet
      if !(packet =~ /\A\x00(.*)\xff\z/nm)
        raise(WebSocket::Error, "input must start with \\x00 and end with \\xff")
      end
      return force_encoding($1, "UTF-8")
    end

    def close()
      @socket.close()
    end

  private

    def read_header()
      @header = {}
      while line = gets()
        line = line.chomp()
        break if line.empty?
        if !(line =~ /\A(\S+): (.*)\z/n)
          raise(WebSocket::Error, "invalid request: #{line}")
        end
        @header[$1] = $2
      end
      if @header["Upgrade"] != "WebSocket"
        raise(WebSocket::Error, "invalid Upgrade: " + @header["Upgrade"])
      end
      if @header["Connection"] != "Upgrade"
        raise(WebSocket::Error, "invalid Connection: " + @header["Connection"])
      end
    end

    def gets(rs = $/)
      line = @socket.gets(rs)
      $stderr.printf("recv> %p\n", line) if WebSocket.debug
      return line
    end

    def write(data)
      if WebSocket.debug
        data.scan(/\G(.*?(\n|\z))/n) do
          $stderr.printf("send> %p\n", $&) if !$&.empty?
        end
      end
      @socket.write(data)
    end

    def flush
      @socket.flush()
    end

    def force_encoding(str, encoding)
      if str.respond_to?(:force_encoding)
        return str.force_encoding(encoding)
      else
        return str
      end
    end

  end
end