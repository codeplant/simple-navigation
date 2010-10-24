require 'cgi'

module SimpleNavigation
  module Adapters
    class Sinatra < Base
      
      def self.register
        SimpleNavigation.set_env(sinatra_root, sinatra_environment)
        ::Sinatra::Application.send(:helpers, SimpleNavigation::Helpers)
      end
      
      def initialize(context)
        @context = context
        @request = context.request
      end

      def context_for_eval
        raise 'no context set for evaluation the config file' unless context
        context
      end
      
      def request_uri
        request.fullpath
      end
      
      def request_path
        request.path
      end
      
      def current_page?(url)
        url_string = CGI.unescape(url)
        if url_string.index("?")
          uri = request_uri
        else
          uri = request_uri.split('?').first
        end
        if url_string =~ /^\w+:\/\//
          url_string == "#{request.protocol}#{request.host_with_port}#{uri}"
        else
          url_string == uri
        end        
      end
      
      def link_to(name, url, options={})
        "<a href='#{url}' #{to_attributes(options)}>#{name}</a>"
      end
      
      def content_tag(type, content, options={})
        "<#{type} #{to_attributes(options)}>#{content}</#{type}>"
      end
      
      protected
      
      def self.sinatra_root
        ::Sinatra::Application.root
      end
      
      def self.sinatra_environment
        ::Sinatra::Application.environment
      end
      
      def to_attributes(options)
        options.map {|k, v| "#{k}='#{v}'"}.join(' ')
      end
      
    end
  end
end
