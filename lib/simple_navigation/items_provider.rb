module SimpleNavigation
  class ItemsProvider
    
    attr_reader :provider
    
    def initialize(provider)
      @provider = provider
    end
    
    def items
      if provider.instance_of?(Symbol)
        SimpleNavigation.config.context_for_eval.send(provider)
      elsif provider.respond_to?(:items)
        provider.items
      else
        raise "items_provider either must be a symbol specifying the helper-method to call or an object with an items-method defined"
      end
    end
    
  end
end