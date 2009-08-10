module SimpleNavigation
  
  # View helpers to render the navigation.
  #
  # Use render_primary_navigation to render your primary navigation with the configured renderer.
  # Use render_sub_navigation to render the sub navigation belonging to the active primary navigation.
  # Use render_navigation to render the primary navigation with the corresponding sub navigation rendered inside primary navigation item which is active.
  # 
  # ==== Examples (using Haml)
  #   #primary_navigation= render_primary_navigation
  #   
  #   #sub_navigation= render_sub_navigation
  #
  #   #main_navigation= render_navigation
  #
  module Helpers
    
    # Renders the navigation according to the specified options-hash. 
    #
    # The following options are supported:
    # * <tt>level</tt> - defaults to :nested which renders the the sub_navigation for an active primary_navigation inside that active primary_navigation item. 
    #   Other possible levels are :primary which only renders the primary_navigation (also see render_primary_navigation) and :secondary which only renders the sub_navigation (see render_sub_navigation).
    # * <tt>context</tt> - specifies the context for which you would render the navigation. Defaults to :default which loads the default navigation.rb (i.e. config/navigation.rb)
    #   if you specify a context then the plugin tries to load the configuration file for that context, e.g. if you call <tt>render_navigation(:context => :admin)</tt> the file config/admin_navigation.rb
    #   will be loaded and used for rendering the navigation.
    #   
    def render_navigation(*args)
      args = [Hash.new] if args.empty?
      default_options = {:context => :default, :level => :nested}
      level, navigation_context = case args.first 
      when Hash
        options = default_options.merge(args.first)
        [options[:level], options[:context]]
      when Symbol
        [args[0], default_options.merge(args[1] || {})[:context]]
      else
        raise ArgumentError, "Invalid arguments"
      end
      SimpleNavigation.load_config(navigation_context)
      SimpleNavigation::Configuration.eval_config(self, navigation_context)
      case level
      when :primary
        SimpleNavigation.primary_navigation.render(@current_primary_navigation)
      when :secondary
        primary = SimpleNavigation.primary_navigation[@current_primary_navigation]
        primary.sub_navigation.render(@current_secondary_navigation) if primary && primary.sub_navigation
      when :nested
        SimpleNavigation.primary_navigation.render(@current_primary_navigation, true, @current_secondary_navigation)
      else
        raise ArgumentError, "Invalid navigation level: #{level}"
      end
    end
    
    # Renders the primary_navigation with the configured renderer. Calling render_navigation(:level => :primary) has the same effect.
    def render_primary_navigation(options = {})
      render_navigation(options.merge(:level => :primary))
    end
    
    # Renders the sub_navigation with the configured renderer. Calling render_navigation(:level => :secondary) has the same effect.
    def render_sub_navigation(options = {})
      render_navigation(options.merge(:level => :secondary))
    end
    
  end
end