module SimpleNavigation
  module Renderer
    
    # Renders the navigation items as a object tree serialized as a json string, can also output raw ruby Hashes
    class Json < SimpleNavigation::Renderer::Base
      
      def render(item_container)
        results = hash_render(item_container)
        results = results.to_json unless options[:as_hash]
        results
      end

      private

      def hash_render(item_container)
        return nil if item_container.nil?
        item_container.items.map do |item|
          item_hash = { 
            :name => item.name, 
            :url => item.url, 
            :selected => item.selected?,
            :items => hash_render(item.sub_navigation)
          }
        end        
      end

    end
  end
end
