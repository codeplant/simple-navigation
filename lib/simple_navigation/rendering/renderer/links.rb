module SimpleNavigation
  module Renderer

    # Renders an ItemContainer as a <div> element and its containing items as <a> elements.
    # It adds the 'selected' class to the <a> element that is currently active.
    #
    # The Links renderer cannot be used to render nested navigations. If you would like it to use with nested navigations, you have to render each level separately.
    #
    # By default, the renderer sets the item's key as dom_id for the rendered <a> element unless the config option <tt>autogenerate_item_ids</tt> is set to false.
    # The id can also be explicitely specified by setting the id in the html-options of the 'item' method in the config/navigation.rb file.
    # The ItemContainer's dom_class and dom_id are applied to the surrounding <div> element.
    #
    class Links < SimpleNavigation::Renderer::Base

      def render(item_container)
        div_content = item_container.items.inject([]) do |list, item|
          list << link_to(item.name, item.url, {:method => item.method}.merge(item.html_options))
        end.join
        content_tag(:div, div_content, {:id => item_container.dom_id, :class => item_container.dom_class})
      end

    end

  end
end