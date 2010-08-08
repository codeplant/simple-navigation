module SimpleNavigation
  module Adapters
    class Rails

      attr_reader :controller, :template

      def initialize(context)
        @controller = extract_controller_from context
        @template = @controller.instance_variable_get(:@template) || (@controller.respond_to?(:view_context) ? @controller.view_context : nil)
      end

      def request
        template.request if template
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

      # Returns the context in which the config file should be evaluated.
      # This is preferably the template, otherwise te controller
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