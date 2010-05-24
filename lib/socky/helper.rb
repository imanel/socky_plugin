module Socky
  module Helper

    def socky(options = {})
      host = Socky::CONFIG[:hosts].first
      options = {
        :host                 => host[:host],
        :port                 => host[:port],
      }.merge(options)
      javascript_tag "socky('#{options.delete(:host)}', '#{options.delete(:port)}', '#{options.to_query}');"
    end

  end
end