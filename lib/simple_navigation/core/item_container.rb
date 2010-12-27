module SimpleNavigation

  # Holds the Items for a navigation 'level'.
  class ItemContainer

    attr_reader :items, :level
    attr_accessor :renderer, :dom_id, :dom_class, :auto_highlight

    def initialize(level=1) #:nodoc:
      @level = level
      @items = []
      @renderer = SimpleNavigation.config.renderer
      @auto_highlight = true
    end

    # Creates a new navigation item.
    #
    # The <tt>key</tt> is a symbol which uniquely defines your navigation item in the scope of the primary_navigation or the sub_navigation.
    #
    # The <tt>name</tt> will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    #
    # The <tt>url</tt> is the address that the generated item points to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    #
    # The <tt>options</tt> can be used to specify the following things:
    # * <tt>any html_attributes</tt> - will be included in the rendered navigation item (e.g. id, class etc.)
    # * <tt>:if</tt> - Specifies a proc to call to determine if the item should
    #   be rendered (e.g. <tt>:if => Proc.new { current_user.admin? }</tt>). The
    #   proc should evaluate to a true or false value and is evaluated in the context of the view.
    # * <tt>:unless</tt> - Specifies a proc to call to determine if the item should not
    #   be rendered (e.g. <tt>:unless => Proc.new { current_user.admin? }</tt>). The
    #   proc should evaluate to a true or false value and is evaluated in the context of the view.
    # * <tt>:method</tt> - Specifies the http-method for the generated link - default is :get.
    # * <tt>:highlights_on</tt> - if autohighlighting is turned off and/or you want to explicitly specify
    #   when the item should be highlighted, you can set a regexp which is matched againstthe current URI.
    #
    # The <tt>block</tt> - if specified - will hold the item's sub_navigation.
    def item(key, name, url, options={}, &block)
      (@items << SimpleNavigation::Item.new(self, key, name, url, options, nil, &block)) if should_add_item?(options)
    end

    def items=(items)
      items.each do |item|
        item = SimpleNavigation::ItemAdapter.new(item)
        (@items << item.to_simple_navigation_item(self)) if should_add_item?(item.options)
      end
    end

    # Returns the Item with the specified key, nil otherwise.
    #
    def [](navi_key)
      items.find {|i| i.key == navi_key}
    end

    # Returns the level of the item specified by navi_key.
    # Recursively works its way down the item's sub_navigations if the desired item is not found directly in this container's items.
    # Returns nil item cannot be found.
    #
    def level_for_item(navi_key)
      my_item = self[navi_key]
      return self.level if my_item
      items.each do |i|
        if i.sub_navigation
          level = i.sub_navigation.level_for_item(navi_key)
          return level unless level.nil?
        end
      end
      return nil
    end

    # Renders the items in this ItemContainer using the configured renderer.
    #
    # The options are the same as in the view's render_navigation call (they get passed on)
    def render(options={})
      renderer_instance = if options[:renderer]
        if options[:renderer].instance_of?(Symbol) && SimpleNavigation.registered_renderers.key?(options[:renderer])
          SimpleNavigation.registered_renderers[options[:renderer]].new(options)
        else
          options[:renderer].new(options)
        end
      else
        self.renderer.new(options)
      end
      renderer_instance.render(self)
    end

    # Returns true if any of this container's items is selected.
    #
    def selected?
      items.any? {|i| i.selected?}
    end

    # Returns the currently selected item, nil if no item is selected.
    #
    def selected_item
      items.find {|i| i.selected?}
    end

    # Returns the active item_container for the specified level
    # (recursively looks up items in selected sub_navigation if level is deeper than this container's level).
    #
    def active_item_container_for(desired_level)
      return self if self.level == desired_level
      return nil unless selected_sub_navigation?
      return selected_item.sub_navigation.active_item_container_for(desired_level)
    end
    
    # Returns the deepest possible active item_container. 
    # (recursively searches in the sub_navigation if this container has a selected sub_navigation). 
    def active_leaf_container
      if selected_sub_navigation?
        selected_item.sub_navigation.active_leaf_container
      else
        self
      end
    end

    # Returns true if there are no items defined for this container.
    def empty?
      items.empty?
    end

    private

    def selected_sub_navigation?
      !!(selected_item && selected_item.sub_navigation)
    end

    # partially borrowed from ActionSupport::Callbacks
    def should_add_item?(options) #:nodoc:
      [options.delete(:if)].flatten.compact.all? { |m| evaluate_method(m) } &&
      ![options.delete(:unless)].flatten.compact.any? { |m| evaluate_method(m) }
    end

    # partially borrowed from ActionSupport::Callbacks
    def evaluate_method(method) #:nodoc:
      case method
        when Proc, Method
          method.call
        else
          raise ArgumentError, ":if or :unless must be procs or lambdas"
      end
    end

  end

end