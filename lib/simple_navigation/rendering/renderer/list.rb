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
          li_options = item.html_options.reject {|k, v| k == :link}
          li_content = link_to(item.name, item.url, link_options_for(item))
          if include_sub_navigation?(item)
            li_content << render_sub_navigation_for(item)
          end
          list << content_tag(:li, li_content, li_options)
        end.join
        if skip_if_empty? && item_container.empty?
          ''
        else  
          content_tag(:ul, list_content, {:id => item_container.dom_id, :class => item_container.dom_class}) 
        end
      end
      
      protected
      
      # Extracts the options relevant for the generated link
      #
      def link_options_for(item)
        special_options = {:method => item.method, :class => item.selected_class}.reject {|k, v| v.nil? }
        link_options = item.html_options[:link]
        return special_options unless link_options
        opts = special_options.merge(link_options)
        opts[:class] = [link_options[:class], item.selected_class].flatten.compact.join(' ')
        opts.delete(:class) if opts[:class].nil? || opts[:class] == ''
        opts
      end
      
      
    end
  
  end
end
