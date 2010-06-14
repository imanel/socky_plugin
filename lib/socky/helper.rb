module Socky
  module Helper

    def socky(options = {})
      host = Socky.random_host
      options = {
        :host                 => (host[:secure] ? "wss://" : "ws://") + host[:host],
        :port                 => host[:port],
      }.merge(options)
      javascript_tag "socky('#{options.delete(:host)}', '#{options.delete(:port)}', '#{options.to_query}');"
    end

  end
end