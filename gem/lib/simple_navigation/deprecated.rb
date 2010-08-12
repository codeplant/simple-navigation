module SimpleNavigation

  #deprecated
  mattr_accessor :controller, :template, :explicit_current_navigation

  class << self

    def explicit_navigation_args
      self.controller.instance_variable_get(:"@sn_current_navigation_args")
    end

    # Reads the current navigation for the specified level from the controller.
    # Returns nil if there is no current navigation set for level.
    def current_navigation_for(level)
      self.controller.instance_variable_get(:"@sn_current_navigation_#{level}")
    end

    # If any navigation has been explicitely set in the controller this method evaluates the specified args set in the controller and sets
    # the correct instance variable in the controller.
    def handle_explicit_navigation
      if SimpleNavigation.explicit_navigation_args
        begin
          level, navigation = parse_explicit_navigation_args
          self.controller.instance_variable_set(:"@sn_current_navigation_#{level}", navigation)
        rescue
          #we do nothing here
          #TODO: check if this is the right way to handle wrong explicit navigation
        end
      end
    end

    # TODO: refactor this ugly thing to make it nice and short
    def parse_explicit_navigation_args
      args = SimpleNavigation.explicit_navigation_args
      args = [Hash.new] if args.empty?
      if args.first.kind_of? Hash
        options = args.first
      else # args is a list of current navigation for several levels
        options = {}
        if args.size == 1 #only an navi-key has been specified, try to find out level
          level = SimpleNavigation.primary_navigation.level_for_item(args.first)
          options[:"level_#{level}"] = args.first if level
        else
          args.each_with_index {|arg, i| options[:"level_#{i + 1}"] = arg}
        end
      end
      #only the deepest level is relevant
      level = options.inject(0) do |max, kv|
        kv.first.to_s =~ /level_(\d)/
        max = $1.to_i if $1.to_i > max
        max
      end
      raise ArgumentError, "Invalid level specified or item key not found" if level == 0
      [level, options[:"level_#{level}"]]
    end
    
  end  
end