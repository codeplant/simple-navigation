module SimpleNavigation
  module Renderer
    class List < Renderer::Base
      
      def render(item_container, include_sub_navigation=false)
        list_content = item_container.items.inject([]) do |list, item|
          html_options = item.html_options(current_navigation)
          li_content = link_to(item.name, item.url)
          li_content << (item.sub_navigation.render(current_sub_navigation)) if include_sub_navigation && item.sub_navigation && item.selected?(current_navigation)
          list << content_tag(:li, li_content, html_options)
        end
        content_tag(:ul, list_content, {:id => item_container.dom_id})
      end
      
    end
  end
end