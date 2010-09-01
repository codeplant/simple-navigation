module SimpleNavigation
  module Adapters
    class Padrino < Sinatra
      
      def self.register
        SimpleNavigation.set_env(PADRINO_ROOT, PADRINO_ENV)
        ::Padrino::Application.send(:helpers, SimpleNavigation::Helpers)
      end
            
      def link_to(name, url, options={})
        context.link_to name, url, options
      end
      
      def content_tag(type, content, options={})
        context.content_tag type, content, options
      end
      
    end
  end
end