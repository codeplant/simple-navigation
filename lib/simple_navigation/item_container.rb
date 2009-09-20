module SimpleNavigation
  
  # Holds the Items for a navigation 'level' (either the primary_navigation or a sub_navigation).
  class ItemContainer
    
    attr_reader :items, :level
    attr_accessor :renderer, :dom_id, :dom_class
    
    def initialize(level=0) #:nodoc:
      @level = level
      @items = []
      @renderer = Configuration.instance.renderer
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
    # * <tt>html_attributes</tt> - will be included in the rendered navigation item (e.g. id, class etc.)
    # * <tt>:if</tt> - Specifies a proc to call to determine if the item should
    #   be rendered (e.g. <tt>:if => Proc.new { current_user.admin? }</tt>). The
    #   proc should evaluate to a true or false value and is evaluated in the context of the view.
    # * <tt>:unless</tt> - Specifies a proc to call to determine if the item should not
    #   be rendered (e.g. <tt>:unless => Proc.new { current_user.admin? }</tt>). The
    #   proc should evaluate to a true or false value and is evaluated in the context of the view.
    #
    # The <tt>block</tt> - if specified - will hold the item's sub_navigation.
    def item(key, name, url, options={}, &block)
      (@items << Item.new(self, key, name, url, options, block)) if should_add_item?(options)
    end

    # Returns the Item with the specified key, nil otherwise.
    def [](navi_key)
      items.find {|i| i.key == navi_key}
    end
  
    # Renders the items in this ItemContainer using the configured renderer.
    #
    # Set <tt>include_sub_navigation</tt> to true if you want to nest the sub_navigation into the active primary_navigation
    def render(include_sub_navigation=false)
      self.renderer.new.render(self, include_sub_navigation)
    end

    def selected?
      items.any? {|i| i.selected?}
    end

    def selected_item
      self[current_navigation] || items.find {|i| i.selected?}
    end

    def current_navigation
      SimpleNavigation.current_navigation_for(level)
    end

    private
    
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