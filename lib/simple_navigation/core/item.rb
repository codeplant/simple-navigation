module SimpleNavigation

  # Represents an item in your navigation. Gets generated by the item method in the config-file.
  class Item
    attr_reader :key, :url, :sub_navigation, :method, :highlights_on, :visible
    alias_method :visible?, :visible
    attr_writer :html_options

    # see ItemContainer#item
    #
    # The subnavigation (if any) is either provided by a block or passed in directly as <tt>items</tt>
    def initialize(container, key, name, url_or_options = {}, options_or_nil={}, visible = true, items=nil, &sub_nav_block)
      @container = container
      options = setup_url_and_options(url_or_options, options_or_nil)
      @container.dom_class = options.delete(:container_class) if options[:container_class]
      @container.dom_id = options.delete(:container_id) if options[:container_id]
      @container.selected_class = options.delete(:selected_class) if options[:selected_class]
      @key = key
      @method = options.delete(:method)
      @name = name
      @visible = visible
      if sub_nav_block || items
        @sub_navigation = ItemContainer.new(@container.level + 1)
        sub_nav_block.call @sub_navigation if sub_nav_block
        @sub_navigation.items = items if items
      end
    end

    # Returns the item's name. If option :apply_generator is set to true (default),
    # the name will be passed to the name_generator specified in the configuration.
    #
    def name(options = {})
      options.reverse_merge!(:apply_generator => true)
      if (options[:apply_generator])
        SimpleNavigation.config.name_generator.call(@name)
      else
        @name
      end
    end

    # Returns true if this navigation item should be rendered as 'selected'.
    # An item is selected if
    #
    # * it has been explicitly selected in a controller or
    # * it has a subnavigation and one of its subnavigation items is selected or
    # * its url matches the url of the current request (auto highlighting)
    #
    def selected?
      @selected = @selected || selected_by_config? || selected_by_subnav? || selected_by_condition?
    end

    # Returns the html-options hash for the item, i.e. the options specified for this item in the config-file.
    # It also adds the 'selected' class to the list of classes if necessary.
    def html_options
      default_options = self.autogenerate_item_ids? ? {:id => autogenerated_item_id} : {}
      options = default_options.merge(@html_options)
      options[:class] = [@html_options[:class], self.selected_class, self.active_leaf_class].flatten.compact.join(' ')
      options.delete(:class) if options[:class].nil? || options[:class] == ''
      options
    end

    # Returns the configured active_leaf_class if the item is the selected leaf,
    # nil otherwise
    def active_leaf_class
      !selected_by_subnav? && selected_by_condition? ? SimpleNavigation.config.active_leaf_class : nil
    end

    # Returns the configured selected_class if the item is selected,
    # nil otherwise
    def selected_class
      selected? ? (@container.selected_class || SimpleNavigation.config.selected_class) : nil
    end

    protected

    # Returns true if item has a subnavigation and the sub_navigation is selected
    def selected_by_subnav?
      sub_navigation && sub_navigation.selected?
    end

    def selected_by_config?
      false
    end

    # Returns true if the item's url matches the request's current url.
    def selected_by_condition?
      if highlights_on
        case highlights_on
        when Regexp
          SimpleNavigation.request_uri =~ highlights_on
        when Proc
          highlights_on.call
        when :subpath
          !!(SimpleNavigation.request_uri =~ /^#{Regexp.escape url_without_anchor}(\/|$|\?)/i)
        else
          raise ArgumentError, ':highlights_on must be a Regexp, Proc or :subpath'
        end
      elsif auto_highlight?
        !!(root_path_match? || (url_without_anchor && SimpleNavigation.current_page?(url_without_anchor)))
      else
        false
      end
    end

    # Returns true if both the item's url and the request's url are root_path
    def root_path_match?
      url == '/' && SimpleNavigation.request_path == '/'
    end

    # Returns true if the item's id should be added to the rendered output.
    def autogenerate_item_ids?
      SimpleNavigation.config.autogenerate_item_ids
    end

    # Returns the item's id which is added to the rendered output.
    def autogenerated_item_id
      SimpleNavigation.config.id_generator.call(key)
    end

    # Return true if auto_highlight is on for this item.
    def auto_highlight?
      SimpleNavigation.config.auto_highlight && @container.auto_highlight
    end

    def url_without_anchor
      url && url.split('#').first
    end

    private
    def setup_url_and_options(url_or_options, options_or_nil)
      options = options_or_nil
      url = url_or_options
      case url_or_options
      when Hash
        # url_or_options is options (there is no url)
        options = url_or_options
      when Proc
        @url = url.call
      else
        @url = url
      end
      @highlights_on = options.delete(:highlights_on)
      @html_options = options
    end
  end
end
