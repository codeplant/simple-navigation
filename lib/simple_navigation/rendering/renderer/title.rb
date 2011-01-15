module SimpleNavigation
  module Renderer
    class Title < SimpleNavigation::Renderer::Base
      def render(item_container)
        ([options[:site_name]] + list(item_container)).compact.join(options[:join_with] || " ")
      end

      private

      def list(item_container)
        item_container.items.inject([]) do |array, item|
          if item.selected?
            array + [item.name] + (include_sub_navigation?(item) ? list(item.sub_navigation) : [])
          else
            array
          end
        end
      end

    end
  end
end
