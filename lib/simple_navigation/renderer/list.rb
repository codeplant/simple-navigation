module SimpleNavigation
  module Renderer
    
    # Renders an ItemContainer as a <ul> element and its containing items as <li> elements. 
    # It adds the 'selected' class to li element AND the link inside the li element that is currently active.
    #
    # If the sub navigation should be included (based on the level and expand_all options), it renders another <ul> containing the sub navigation inside the active <li> element.
    #
    # By default, the renderer sets the item's key as dom_id for the rendered <li> element unless the config option <tt>autogenerate_item_ids</tt> is set to false.
    # The id can also be explicitely specified by setting the id in the html-options of the 'item' method in the config/navigation.rb file.
    class List < SimpleNavigation::Renderer::Base

      def render(item_container)
        list_content = item_container.items.inject([]) do |list, item|
          html_options = item.html_options
          li_content = link_to(html_safe(item.name), item.url, :class => item.selected_class, :method => item.method)
          if include_sub_navigation?(item)
            li_content << render_sub_navigation_for(item)
          end  
          list << content_tag(:li, li_content, html_options)
        end.join
        content_tag(:ul, html_safe(list_content), {:id => item_container.dom_id, :class => item_container.dom_class})
      end
    end
    
  end
end
