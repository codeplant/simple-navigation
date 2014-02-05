module SimpleNavigation
  module Adapters
    class Rails < Base
            
      attr_reader :controller, :template

      def self.register
        SimpleNavigation.set_env(rails_root, rails_env)        
        ActionController::Base.send(:include, SimpleNavigation::Helpers)
        SimpleNavigation::Helpers.instance_methods.each do |m|
          ActionController::Base.send(:helper_method, m.to_sym)
        end
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
        template.link_to(link_title(name), url, options) if template
      end
      
      def content_tag(type, content, options={})
        template.content_tag(type, html_safe(content), options) if template
      end
      
      protected
      
      def self.rails_root
        gte_rails3? ? ::Rails.root : ::RAILS_ROOT
      end
      
      def self.rails_env
        gte_rails3? ? ::Rails.env : ::RAILS_ENV
      end
      
      def self.gte_rails3?
        ::Rails::VERSION::MAJOR >= 3
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
        context.respond_to?(:controller) ?
          context.controller || context :
          context
      end

      def link_title name
        SimpleNavigation.config.consider_item_names_as_safe ? html_safe(name) : name
      end
         
    end
  end
end

# Initializer for Rails3
if defined?(Rails) && SimpleNavigation::Adapters::Rails.gte_rails3?
  module SimpleNavigation                                                                                                
    class Railtie < Rails::Railtie                                                                                       
      initializer "simple_navigation.register" do |app|                                                             
        SimpleNavigation.register
      end                                                                                                                
    end                                                                                                                  
  end
end
