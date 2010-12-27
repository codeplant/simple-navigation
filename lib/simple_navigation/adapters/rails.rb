module SimpleNavigation
  module Adapters
    class Rails < Base
            
      attr_reader :controller, :template

      def self.register
        SimpleNavigation.set_env(rails_root, rails_env)        
        ActionController::Base.send(:include, SimpleNavigation::Helpers)
        ActionController::Base.send(:helper_method, :render_navigation)
        ActionController::Base.send(:helper_method, :active_navigation_item_name)
      end
      
      def initialize(context)
        @controller = extract_controller_from context
        @template = template_from @controller
        @request = @template.request if @template
      end
      
      def request_uri
        return '' unless request
        return request.fullpath if request.respond_to?(:fullpath)
        request.request_uri
      end
      
      def request_path
        return '' unless request
        request.path
      end
      
      def context_for_eval
        raise 'no context set for evaluation the config file' unless template || controller
        template || controller
      end
      
      def current_page?(url)
        template.current_page?(url) if template
      end
      
      def link_to(name, url, options={})
        template.link_to(html_safe(name), url, options) if template
      end
      
      def content_tag(type, content, options={})
        template.content_tag(type, html_safe(content), options) if template
      end
      
      protected
      
      def self.rails_root
        rails3? ? ::Rails.root : ::RAILS_ROOT
      end
      
      def self.rails_env
        rails3? ? ::Rails.env : ::RAILS_ENV
      end
      
      def self.rails3?
        ::Rails::VERSION::MAJOR == 3
      end
      
      def template_from(controller)
        controller.respond_to?(:view_context) ? controller.view_context : controller.instance_variable_get(:@template)
      end
      
      # Marks the specified input as html_safe (for Rails3). Does nothing if html_safe is not defined on input. 
      #
      def html_safe(input)
        input.respond_to?(:html_safe) ? input.html_safe : input
      end
      
      # Extracts a controller from the context.
      def extract_controller_from(context)
        if context.respond_to? :controller
          context.controller
        else
          context
        end
      end
         
    end
  end
end

# Initializer for Rails3
if defined?(Rails) && Rails::VERSION::MAJOR == 3
  module SimpleNavigation                                                                                                
    class Railtie < Rails::Railtie                                                                                       
      initializer "simple_navigation.register" do |app|                                                             
        SimpleNavigation.register
      end                                                                                                                
    end                                                                                                                  
  end
end