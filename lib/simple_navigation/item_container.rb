module SimpleNavigation
  
  # Holds the Items for a navigation 'level' (either the primary_navigation or a sub_navigation).
  class ItemContainer
    
    attr_reader :items
    attr_accessor :renderer, :dom_id
    
    def initialize #:nodoc:
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
    # The <tt>html_options</tt> can be used to specify any attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #
    # The <tt>block</tt> - if specified - will hold the item's sub_navigation defined.
    def item(key, name, url, html_options={}, &block)
      @items << Item.new(key, name, url, html_options, block)
    end

    # Returns the Item with the specified key, nil otherwise.
    def [](navi_key)
      items.find {|i| i.key == navi_key}
    end
  
    # Renders the items in this ItemContainer using the configured renderer.
    #
    # Set <tt>include_sub_navigation</tt> to true if you want to nest the sub_navigation into the active primary_navigation
    def render(current_navigation, include_sub_navigation=false, current_sub_navigation=nil)
      self.renderer.new(current_navigation, current_sub_navigation).render(self, include_sub_navigation)
    end
    
  end
  
end