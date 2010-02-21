module SimpleNavigation
  
  # View helpers to render the navigation.
  #
  # Use render_navigation as following to render your navigation:
  # * call <tt>render_navigation</tt> without :level option to render your complete navigation as nested tree.
  # * call <tt>render_navigation(:level => x)</tt> to render a specific navigation level (e.g. :level => 1 to render your primary navigation, :level => 2 to render the sub navigation and so forth)
  # * call <tt>render_navigation(:level => 2..3)</tt> to render navigation levels 2 and 3). 
  #   For example, you could use render_navigation(:level => 1) to render your primary navigation as tabs and render_navigation(:level => 2..3) to render the rest of the navigation as a tree in a sidebar.
  # 
  # ==== Examples (using Haml)
  #   #primary_navigation= render_navigation(:level => 1)
  #   
  #   #sub_navigation= render_navigation(:level => 2)
  #
  #   #nested_navigation= render_navigation
  #
  #   #top_navigation= render_navigation(:level => 1..2)
  #   #sidebar_navigation= render_navigation(:level => 3)
  module Helpers
    
    # Renders the navigation according to the specified options-hash. 
    #
    # The following options are supported:
    # * <tt>:level</tt> - defaults to :all which renders the the sub_navigation for an active primary_navigation inside that active primary_navigation item. 
    #   Specify a specific level to only render that level of navigation (e.g. :level => 1 for primary_navigation etc...).
    #   Specifiy a Range of levels to render only those specific levels (e.g. :level => 1..2 to render both your first and second levels, maybe you want to render your third level somewhere else on the page)
    # * <tt>:expand_all</tt> - defaults to false. If set to true the all specified levels will be rendered as a fully expanded tree (always open). This is useful for javascript menus like Superfish.
    # * <tt>:context</tt> - specifies the context for which you would render the navigation. Defaults to :default which loads the default navigation.rb (i.e. config/navigation.rb).
    #   If you specify a context then the plugin tries to load the configuration file for that context, e.g. if you call <tt>render_navigation(:context => :admin)</tt> the file config/admin_navigation.rb
    #   will be loaded and used for rendering the navigation.
    # * <tt>:items</tt> - you can specify the items directly (e.g. if items are dynamically generated from database). See SimpleNavigation::ItemsProvider for documentation on what to provide as items. 
    def render_navigation(*args)
      args = [Hash.new] if args.empty?
      options = extract_backwards_compatible_options(*args)
      options = {:context => :default, :level => :all}.merge(options)
      ctx = options.delete(:context)
      SimpleNavigation.set_template_from self
      if SimpleNavigation.config_file?(ctx)
        SimpleNavigation.load_config(ctx) 
        SimpleNavigation::Configuration.eval_config(self, ctx) 
      end
      SimpleNavigation.config.items(options[:items]) if options[:items]
      SimpleNavigation.handle_explicit_navigation
      raise "no primary navigation defined, either use a navigation config file or pass items directly to render_navigation" unless SimpleNavigation.primary_navigation
      active_item_container = SimpleNavigation.active_item_container_for(options[:level])
      active_item_container.render(options) unless active_item_container.nil?
    end
    
    # Deprecated. Renders the primary_navigation with the configured renderer. Calling render_navigation(:level => 0) has the same effect.
    def render_primary_navigation(options = {})
      ActiveSupport::Deprecation.warn("SimpleNavigation::Helpers.render_primary_navigation has been deprecated. Please use render_navigation(:level => 1) instead")
      render_navigation(options.merge(:level => 1))
    end
    
    # Deprecated. Renders the sub_navigation with the configured renderer. Calling render_navigation(:level => 1) has the same effect.
    def render_sub_navigation(options = {})
      ActiveSupport::Deprecation.warn("SimpleNavigation::Helpers.render_primary_navigation has been deprecated. Please use render_navigation(:level => 2) instead")
      render_navigation(options.merge(:level => 2))
    end

    private

    def extract_backwards_compatible_options(*args)
      case args.first
      when Hash
        options = args.first
        options[:level] = options.delete(:levels) if options[:levels]
        deprecated_api! if options[:level] == :primary || options[:level] == :secondary || options[:level] == :nested
        options[:level] = 1 if options[:level] == :primary
        options[:level] = 2 if options[:level] == :secondary
        options[:level] = :all if options[:level] == :nested
      when Symbol
        deprecated_api!
        raise ArgumentError, "Invalid arguments" unless [:primary, :secondary, :nested].include? args.first
        options = Hash.new
        options[:level] = args.first
        options[:level] = :all if options[:level] == :nested
        options[:level] = 1 if options[:level] == :primary
        options[:level] = 2 if options[:level] == :secondary
        options.merge!(args[1] || {})
      else
        raise ArgumentError, "Invalid arguments"
      end
      if options[:all_open]
        options[:expand_all] = options.delete(:all_open)
        ActiveSupport::Deprecation.warn("render_navigation(:all_open => true) has been deprecated, please use render_navigation(:expand_all => true) instead")
      end
      options
    end
    
    def deprecated_api!
      ActiveSupport::Deprecation.warn("You are using a deprecated API of SimpleNavigation::Helpers.render_navigation, please check the documentation on http://wiki.github.com/andi/simple-navigation")
    end
      
  end
end