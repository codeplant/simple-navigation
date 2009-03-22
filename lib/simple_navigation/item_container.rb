module SimpleNavigation
  class ItemContainer
    attr_reader :items
    attr_accessor :renderer, :dom_id
    def initialize
      @items = []
      @renderer = Configuration.instance.renderer
    end
    
    def item(key, name, url, html_options={}, &block)
      @items << Item.new(key, name, url, html_options, block)
    end

    def [](navi_key)
      items.find {|i| i.key == navi_key}
    end
  
    def render(current_navigation, include_sub_navigation=false, current_sub_navigation=nil)
      self.renderer.new(current_navigation, current_sub_navigation).render(self, include_sub_navigation)
    end
    
  end
  
end