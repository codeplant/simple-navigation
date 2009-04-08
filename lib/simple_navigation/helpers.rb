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
    
    # Renders the navigation according to the specified <tt>level</tt>. 
    # 
    # The <tt>level</tt> defaults to :nested which renders the the sub_navigation for an active primary_navigation inside that active primary_navigation item. 
    # 
    # Other possible levels are 
    # 
    # :primary which only renders the primary_navigation (also see render_primary_navigation) and :secondary which only renders the sub_navigation (see render_sub_navigation).
    def render_navigation(level = :nested)
      SimpleNavigation::Configuration.eval_config(self) unless SimpleNavigation.config.loaded?
      case level
      when :primary:
        SimpleNavigation.primary_navigation.render(@current_primary_navigation)
      when :secondary:
        primary = SimpleNavigation.primary_navigation[@current_primary_navigation]
        primary.sub_navigation.render(@current_secondary_navigation) if primary && primary.sub_navigation
      when :nested:
        SimpleNavigation.primary_navigation.render(@current_primary_navigation, true, @current_secondary_navigation)
      else
        raise ArgumentError, "Invalid navigation level: #{level}"
      end
    end
    
    # Renders the primary_navigation with the configured renderer. Calling render_navigation(:primary) has the same effect.
    def render_primary_navigation
      render_navigation(:primary)
    end
    
    # Renders the sub_navigation with the configured renderer. Calling render_navigation(:secondary) has the same effect.
    def render_sub_navigation
      render_navigation(:secondary)
    end
    
  end
end