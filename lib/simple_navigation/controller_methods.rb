#TODO: add :except and :only options to navigation method
module SimpleNavigation
  
  # Adds methods for explicitely setting the current 'active' navigation to the controllers.
  # Since version 2.0.0 the simple_navigation plugin determines the active navigation based on the current url by default (auto highlighting),
  # so explicitely defining the active navigation in the controllers is only needed for edge cases where automatic highlighting does not work.
  # 
  # On the controller class level, use the <tt>navigation</tt> method to set the active navigation for all actions in the controller.
  # Let's assume that we have a primary navigation item :account which in turn has a sub navigation item :settings.
  # 
  # ==== Examples
  #   class AccountController << ActionController
  #     navigation :account
  #     ...
  #   end
  #
  #   class AccountSettingsController << ActionController
  #     navigation :settings
  #     ...
  #   end
  #
  # The first example sets the current primary navigation to :account for all actions. No active sub_navigation.
  # The second example sets the current sub navigation to :settings and since it is a child of :account the current primary navigation is set to :account.
  # 
  # On the controller instance level, use the <tt>current_navigation</tt> method to define the active navigation for a specific action. 
  # The navigation item that is set in <tt>current_navigation</tt> overrides the one defined on the controller class level (see <tt>navigation</tt> method).
  # Thus if you have an :account primary item with a :special sub navigation item:
  #
  # ==== Example
  #   class AccountController << ActionController
  #     navigation :account
  #     
  #     def your_special_action
  #       ...
  #       current_navigation :special
  #     end
  #   end
  #
  # The code above still sets the active primary navigation to :account for all actions, but sets the sub_navigation to :account -> :special for 'your_special_action'.
  #
  # Note 1: As you can see above you just have to set the navigation item of your 'deepest' navigation level as active and all its parents are marked as active, too.
  #
  # Note 2: The specified symbols must match the keys for your navigation items in your config/navigation.rb file.
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
      # The specified symbol must match the keys for your navigation items in your config/navigation.rb file.  
      def navigation(*args)
        self.class_eval do
          define_method :sn_set_navigation do
            current_navigation(*args)
          end
          protected :sn_set_navigation
          before_filter :sn_set_navigation
        end
      end
    end
  
    module InstanceMethods
      # Sets the active navigation. Call this method in any action to override the controller-wide active navigation
      # specified by navigation.
      #
      # The specified symbol must match the keys for your navigation items in your config/navigation.rb file.
      def current_navigation(*args)
        @sn_current_navigation_args = args
      end
    end

  end
end