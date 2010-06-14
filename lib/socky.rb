require "yaml"
require 'websocket'
require 'socky/render_extension'

module Socky
  CONFIG = YAML::load(ERB.new(IO.read("#{RAILS_ROOT}/config/socky_hosts.yml")).result).freeze

  class << self

    def send_to_all(data)
      hash = {
        :command  => :broadcast,
        :type     => :to_channels,
        :channels => nil,
        :body     => data
      }
      send_data(hash)
    end

    def send_to_clients(data, clients)
      hash = {
        :command => :broadcast,
        :type    => :to_clients,
        :clients => clients,
        :body    => data
      }
      send_data(hash)
    end
    alias send_to_client send_to_clients

    def send_to_channels(data, channels)
      hash = {
        :command  => :broadcast,
        :type     => :to_channels,
        :channels => channels,
        :body     => data
      }
      send_data(hash)
    end
    alias send_to_channel send_to_channels

    def send_to_clients_on_channels(data, clients, channels)
      hash = {
        :command  => :broadcast,
        :type     => :to_clients_on_channels,
        :clients  => clients,
        :channels => channels,
        :body     => data
      }
      send_data(hash)
    end
    alias send_to_clients_on_channel send_to_clients_on_channels
    alias send_to_client_on_channels send_to_clients_on_channels
    alias send_to_client_on_channel  send_to_clients_on_channels

    def show_connections
      hash = {
        :command  => :query,
        :type     => :show_connections
      }
      send_data(hash, true)
    end

    def send_data(hash, response = false)
      res = []
      hosts.each do |address|
        begin
          hash[:secret] = address[:secret] if address[:secret]
          scheme = (address[:secure] ? "wss" : "ws")
          @socket = WebSocket.new("#{scheme}://#{address[:host]}:#{address[:port]}/?admin=1")
          @socket.send(hash.to_json)
          res << @socket.receive if response
        ensure
          @socket.close if @socket
        end
      end
      res.collect {|r| ActiveSupport::JSON.decode(r) } if response
    end

    private

    def hosts
      CONFIG[:hosts]
    end

  end
end