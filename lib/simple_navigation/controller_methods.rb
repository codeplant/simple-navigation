#TODO: add :except and :only options to navigation method
module SimpleNavigation
  
  # Methods for extending the controllers 
  module ControllerMethods
    def self.included(base) #:nodoc:
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
        helper SimpleNavigation::Helpers
      end
    end
  
    module ClassMethods

      # Sets the active navigation for all actions in this controller.
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
      # The specified symbols must match the keys for your navigation items in your config/navigation.rb file.
      # If you want to override the active navigation for a specific action, call current_navigation in that action.
      def navigation(primary_navigation, sub_navigation=nil)
        self.class_eval do
          define_method :set_navigation do
            current_navigation(primary_navigation, sub_navigation)
          end
          before_filter :set_navigation
        end
      end
    end
  
    module InstanceMethods
      
      # Sets the active navigation. Call this method in any action to override the controller-wide active navigation
      # specified by navigation().
      #
      # The specified symbols must match the keys for your navigation items in your config/navigation.rb file.
      def current_navigation(primary_navigation, sub_navigation=nil)
        @current_primary_navigation = primary_navigation
        @current_secondary_navigation = sub_navigation
      end
    end

  end
end