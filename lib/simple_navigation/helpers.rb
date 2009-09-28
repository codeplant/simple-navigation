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
      options = extract_backwards_compatible_options(*args)
      options = {:context => :default, :level => :nested}.merge(options)
      SimpleNavigation.load_config(options[:context])
      SimpleNavigation::Configuration.eval_config(self, options[:context])
      case options[:level]
      when Integer
        active_item_container = SimpleNavigation.active_item_container_for(options[:level])
        active_item_container.render if active_item_container
      when :nested
        SimpleNavigation.primary_navigation.render(true)
      else
        raise ArgumentError, "Invalid navigation level: #{options[:level]}"
      end
    end
    
    # Renders the primary_navigation with the configured renderer. Calling render_navigation(:level => 0) has the same effect.
    def render_primary_navigation(options = {})
      render_navigation(options.merge(:level => 1))
    end
    
    # Renders the sub_navigation with the configured renderer. Calling render_navigation(:level => 1) has the same effect.
    def render_sub_navigation(options = {})
      render_navigation(options.merge(:level => 2))
    end

    private

    def extract_backwards_compatible_options(*args)
      case args.first
      when Hash
        options = args.first
        options[:level] = 1 if options[:level] == :primary
        options[:level] = 2 if options[:level] == :secondary
      when Symbol
        raise ArgumentError, "Invalid arguments" unless [:primary, :secondary, :nested].include? args.first
        options = Hash.new
        options[:level] = args.first
        options[:level] = 1 if options[:level] == :primary
        options[:level] = 2 if options[:level] == :secondary
        options.merge!(args[1] || {})
      else
        raise ArgumentError, "Invalid arguments"
      end
      options
    end
    
  end
end