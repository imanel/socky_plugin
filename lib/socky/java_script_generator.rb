module Socky
  class JavaScriptGenerator
    
    if defined?(ActionView)
      include ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods
    end

    def initialize(&block)
      @lines = []
      
      if defined?(Rails)
        case Rails::VERSION::MAJOR
        when 2
          @context = eval("self.instance_variable_get('@template')", block.binding)
          block.call(self)
          unless @context.nil?
            @context.controller.response.body = nil
            @context.controller.instance_variable_set("@performed_render",false)
          end
        when 3
          @context = eval("self.view_context", block.binding)
          block.call(self)
          @context.controller.instance_variable_set("@_response_body",nil) unless @context.nil?
        end
      else
        block.call(self)
      end
    end

  end
end