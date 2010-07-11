# Taken from Socky as temporary solution

module Socky
  module RenderExtension
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      # We can't protect these as ActionMailer complains

        def render_with_socky(options = nil, extra_options = {}, &block)
          if options == :socky or (options.is_a?(Hash) and options[:socky])
            begin
              if @template.respond_to?(:_evaluate_assigns_and_ivars, true)
                @template.send(:_evaluate_assigns_and_ivars)
              else
                @template.send(:evaluate_assigns)
              end

              generator = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(@template, &block)
              render_for_socky(generator.to_s, options.is_a?(Hash) ? options[:socky] : nil)
            ensure
              erase_render_results
              reset_variables_added_to_assigns
            end
          else
            render_without_socky(options, extra_options, &block)
          end
        end

        def render_socky(*args)
          socky_options = args.last.is_a?(Hash) ? args.pop : {}
          render_for_socky(render_to_string(*args), socky_options)
        end

        def render_for_socky(data, options = {})
          Socky.deprecation_warning "Using render :socky is depricated and will be removed before stable version. Please use Socky.send instead."
          if !options or !options.is_a?(Hash)
            return Socky.send(data)
          end

          case options[:type]
            when :send_to_all
              Socky.send(data)
            when :send_to_channels
              socky_needs options, :channels
              Socky.send(data, :to => {:channels => options[:channels]})
            when :send_to_channel
              socky_needs options, :channel
              Socky.send(data, :to => {:channels => options[:channel]})
            when :send_to_client
              socky_needs options, :client_id
              Socky.send(data, :to => {:clients => options[:client_id]})
            when :send_to_clients
              socky_needs options, :client_ids
              Socky.send(data, :to => {:clients => options[:client_ids]})
            when :send_to_client_on_channel
              socky_needs options, :client_id, :channel
              Socky.send(data, :to => {:clients => options[:client_id], :channels => options[:channel]})
            when :send_to_clients_on_channel
              socky_needs options, :client_ids, :channel
              Socky.send(data, :to => {:clients => options[:client_ids], :channels => options[:channel]})
            when :send_to_client_on_channels
              socky_needs options, :client_id, :channels
              Socky.send(data, :to => {:clients => options[:client_id], :channels => options[:channels]})
            when :send_to_clients_on_channels
              socky_needs options, :client_ids, :channels
              Socky.send(data, :to => {:clients => options[:client_ids], :channels => options[:channels]})
          end
        end

        def socky_needs(options, *args)
          args.each do |a|
            raise "You must specify #{a}" unless options[a]
          end
        end

    end
  end
end