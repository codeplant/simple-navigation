module SimpleNavigation
  module Renderer
    
    # Renders an ItemContainer as a <ul> element and its containing items as <li> elements. 
    # It adds the 'selected' class to li element AND the link inside the li element that is currently active.
    # If the sub navigation should be included, it renders another <ul> containing the sub navigation inside the active <li> element.
    #
    # By default, the renderer sets the item's key as dom_id for the rendered <li> element unless the config option <tt>autogenerate_item_ids</tt> is set to false.
    # The id can also be explicitely specified by setting the id in the html-options of the 'item' method in the config/navigation.rb file.
    class List < Renderer::Base
      
      def render(item_container, include_sub_navigation=false)
        list_content = item_container.items.inject([]) do |list, item|
          html_options = item.html_options
          li_content = link_to(item.name, item.url, :class => item.selected_class, :method => item.method)
          if item.sub_navigation
            if SimpleNavigation.config.render_all_levels || (include_sub_navigation && item.selected?)
              li_content << (item.sub_navigation.render)
            end
          end  
          list << content_tag(:li, li_content, html_options)
        end
        content_tag(:ul, list_content.join, {:id => item_container.dom_id, :class => item_container.dom_class})
      end
      
    end
  end
end