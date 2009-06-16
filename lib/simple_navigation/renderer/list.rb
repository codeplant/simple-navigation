module SimpleNavigation
  module Renderer
    
    # Renders an ItemContainer as a <ul> element and its containing items as <li> elements. 
    # It adds the 'selected' class to li element AND the link inside the li element that is currently active.
    # If the sub navigation should be included, it renders another <ul> containing the sub navigation inside the active <li> element.
    #
    # By default, the renderer sets the item's key as dom_id for the rendered <li> element. The id can be explicitely specified by setting
    # the id in the html-options of the 'item' method in the config/navigation.rb file.
    class List < Renderer::Base
      
      def render(item_container, include_sub_navigation=false)
        list_content = item_container.items.inject([]) do |list, item|
          html_options = item.html_options(current_navigation)
          li_content = link_to(item.name, item.url, :class => item.selected_class(current_navigation), :method => item.method)
          if item.sub_navigation
            if SimpleNavigation.config.render_all_levels
              li_content << (item.sub_navigation.render(current_sub_navigation))
            else
              li_content << (item.sub_navigation.render(current_sub_navigation)) if include_sub_navigation && item.selected?(current_navigation)
            end
          end  
          list << content_tag(:li, li_content, html_options)
        end
        content_tag(:ul, list_content, {:id => item_container.dom_id, :class => item_container.dom_class})
      end
      
    end
  end
end