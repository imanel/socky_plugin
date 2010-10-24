module Socky
  module JSON
    
    begin
      require 'json'
      self.extend ::JSON
      
      def self.decode(source, options = {})
        ::JSON.parse(source, options)
      end
    rescue LoadError
      begin
        require 'active_support'
        extend ActiveSupport::JSON
      rescue LoadError
        raise('You need either json gem or activesupport gem!')
      end
    end
    
  end
end

