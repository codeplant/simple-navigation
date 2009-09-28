#TODO: add :except and :only options to navigation method
module SimpleNavigation
  
  # Adds methods for explicitely setting the current 'active' navigation to the controllers.
  # Since version 2.0.0 the simple_navigation plugin determines the active navigation based on the current url by default,
  # so explicitely defining the active navigation in the controllers is only needed for edge cases where automatic highlighting does not work.
  # 
  # On the controller class level, use the navigation method to set the active navigation for all actions in the controller.
  # 
  # ==== Examples
  #   class AccountController << ActionController
  #     navigation :account
  #     ...
  #   end
  #
  #   class AccountSettingsController << ActionController
  #     navigation :account, :settings
  #     ...
  #   end
  #
  # The first example sets the current_primary_navigation to :account for all actions. No active sub_navigation.
  # The second example sets the current_primary_navigation to :account and the current_sub_navigation to :settings.
  # 
  # On the controller instance level, use the current_navigation method to define the active navigation for a specific action. 
  # The navigation item that is set in current_navigation overrides the one defined on the controller class level (see navigation method).
  #
  # ==== Example
  #   class AccountController << ActionController
  #     navigation :account
  #     
  #     def your_special_action
  #       ...
  #       current_navigation :account, :special
  #     end
  #   end
  #
  # The code above still sets the active primary navigation to :account but also sets the sub_navigation to :special for 'your_special_action'.
  #
  # Note: The specified symbols must match the keys for your navigation items in your config/navigation.rb file.
  module ControllerMethods
    def self.included(base) #:nodoc:
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
        include SimpleNavigation::Helpers
        base.helper_method :render_navigation, :render_primary_navigation, :render_sub_navigation
      end
    end
  
    module ClassMethods
      # Sets the active navigation for all actions in this controller.
      #
      # The specified symbols must match the keys for your navigation items in your config/navigation.rb file.  
      def navigation(primary_navigation, sub_navigation=nil)
        self.class_eval do
          define_method :sn_set_navigation do
            current_navigation(primary_navigation, sub_navigation)
          end
          before_filter :sn_set_navigation
        end
      end
    end
  
    module InstanceMethods
      
      # Sets the active navigation. Call this method in any action to override the controller-wide active navigation
      # specified by navigation.
      #
      # The specified symbols must match the keys for your navigation items in your config/navigation.rb file.
      def current_navigation(primary_navigation, sub_navigation=nil)
        @sn_current_navigation_1 = primary_navigation
        @sn_current_navigation_2 = sub_navigation
      end
    end

  end
end