module SimpleNavigation
  
  # View helpers to render the navigation.
  #
  # Use render_navigation as following to render your navigation:
  # * call <tt>render_navigation</tt> without :level option to render your navigation as nested tree.
  # * call <tt>render_navigation(:level => x)</tt> to render a specific navigation level (e.g. :level => 1 to render your primary navigation, :level => 2 to render the sub navigation and so forth)
  # 
  # ==== Examples (using Haml)
  #   #primary_navigation= render_navigation(:level => 1)
  #   
  #   #sub_navigation= render_navigation(:level => 2)
  #
  #   #nested_navigation= render_navigation
  #
  # Please note that <tt>render_primary_navigation</tt> and <tt>render_sub_navigation</tt> still work, but have been deprecated and may be removed in a future release.
  module Helpers
    
    # Renders the navigation according to the specified options-hash. 
    #
    # The following options are supported:
    # * <tt>:level</tt> - defaults to :nested which renders the the sub_navigation for an active primary_navigation inside that active primary_navigation item. 
    #   Specify a specific level to only render that level of navigation (e.g. :level => 1 for primary_navigation etc...).
    # * <tt>:context</tt> - specifies the context for which you would render the navigation. Defaults to :default which loads the default navigation.rb (i.e. config/navigation.rb).
    #   If you specify a context then the plugin tries to load the configuration file for that context, e.g. if you call <tt>render_navigation(:context => :admin)</tt> the file config/admin_navigation.rb
    #   will be loaded and used for rendering the navigation.
    # * <tt>:all_open</tt> - setting this options to true means that all items are always open (ie. fully expanded tree). Same as setting render_all_levels option in the config-file.
    # * <tt>:items</tt> - you can specify the items directly (e.g. if items are dynamically generated from database). See SimpleNavigation::ItemsProvider for documentation on what to provide as items. 
    def render_navigation(*args)
      args = [Hash.new] if args.empty?
      options = extract_backwards_compatible_options(*args)
      options = {:context => :default, :level => :nested}.merge(options)
      SimpleNavigation.load_config(options[:context]) rescue nil
      SimpleNavigation::Configuration.eval_config(self, options[:context]) rescue nil
      SimpleNavigation.config.render_all_levels = options[:all_open] unless options[:all_open].nil?
      SimpleNavigation.config.items(options[:items]) if options[:items]
      SimpleNavigation.handle_explicit_navigation
      raise "no primary navigation defined, either use a navigation config file or pass items directly to render_navigation" unless SimpleNavigation.primary_navigation
      case options[:level]
      when Integer
        active_item_container = SimpleNavigation.active_item_container_for(options[:level])
        active_item_container.render if active_item_container
      when Range
        active_item_container = SimpleNavigation.active_item_container_for(options[:level].min)
        active_item_container.render(false, options[:level].max) if active_item_container
      when :nested
        SimpleNavigation.primary_navigation.render(true)
      else
        raise ArgumentError, "Invalid navigation level: #{options[:level]}"
      end
    end
    
    # Deprecated. Renders the primary_navigation with the configured renderer. Calling render_navigation(:level => 0) has the same effect.
    def render_primary_navigation(options = {})
      ActiveSupport::Deprecation.warn("SimpleNavigation::Helpers.render_primary_navigation has been deprected. Please use render_navigation(:level => 1) instead")
      render_navigation(options.merge(:level => 1))
    end
    
    # Deprecated. Renders the sub_navigation with the configured renderer. Calling render_navigation(:level => 1) has the same effect.
    def render_sub_navigation(options = {})
      ActiveSupport::Deprecation.warn("SimpleNavigation::Helpers.render_primary_navigation has been deprected. Please use render_navigation(:level => 2) instead")
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