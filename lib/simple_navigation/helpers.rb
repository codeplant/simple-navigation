module SimpleNavigation
  module Helpers
    
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

    def render_primary_navigation
      render_navigation(:primary)
    end
    
    def render_sub_navigation
      render_navigation(:secondary)
    end
    
  end
end