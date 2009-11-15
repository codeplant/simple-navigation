module SimpleNavigation
  class ItemAdapter
    delegate :key, :name, :url, :to => :item
    
    attr_reader :item

    def initialize(item)
      @item = item
    end
        
    def options
      @item.respond_to?(:options) ? @item.options : {}
    end
    
    def items
      (@item.respond_to?(:items) && !(@item.items.nil? || @item.items.empty?)) ? @item.items : nil
    end
    
    def to_simple_navigation_item(item_container)
      SimpleNavigation::Item.new(item_container, key, name, url, options, items)
    end
    
  end
end