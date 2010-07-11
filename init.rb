require File.dirname(__FILE__) + '/lib/socky'
require File.dirname(__FILE__) + '/lib/socky/helper'

ActionView::Base.send(:include, Socky::Helper)

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :socky => ['socky/swfobject', 'socky/FABridge', 'socky/web_socket', 'socky/json2', 'socky']

if Rails::VERSION::MAJOR == 2
  require File.dirname(__FILE__) + '/lib/socky/render_extension'

  ActionController::Base.class_eval do
    alias_method :render_without_socky, :render
    include Socky::RenderExtension
    alias_method :render, :render_with_socky
  end

  ActionView::Base.class_eval do
    alias_method :render_without_socky, :render
    include Socky::RenderExtension
    alias_method :render, :render_with_socky
  end
end