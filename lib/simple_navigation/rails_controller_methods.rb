module SimpleNavigation
  def self.explicit_navigation_args
    adapter.controller.instance_variable_get(:'@sn_current_navigation_args')
  end

  # Reads the current navigation for the specified level from the controller.
  # Returns nil if there is no current navigation set for level.
  def self.current_navigation_for(level)
    adapter.controller.instance_variable_get(:"@sn_current_navigation_#{level}")
  end

  # If any navigation has been explicitely set in the controller this method
  # evaluates the specified args set in the controller and sets the correct
  # instance variable in the controller.
  def self.handle_explicit_navigation
    return unless explicit_navigation_args
    level, navigation = parse_explicit_navigation_args
    navigation_level = :"@sn_current_navigation_#{level}"
    adapter.controller.instance_variable_set(navigation_level, navigation)
  end

  def self.parse_explicit_navigation_args
    args = if explicit_navigation_args.empty?
             [{}]
           else
             explicit_navigation_args
           end
    indexed_args = args_indexed_by_level(args)
    deepest = deepest_level_and_item(indexed_args)

    if deepest.first.zero?
      fail ArgumentError, 'Invalid level specified or item key not found'
    end

    deepest
  end

  private

  def self.deepest_level_and_item(navigation_args)
    navigation_args.map { |k, v| [k.to_s[/level_(\d)/, 1].to_i, v] }
                   .max
  end

  def self.args_indexed_by_level(navigation_args)
    if navigation_args.first.is_a?(Hash)
      navigation_args.first
    elsif navigation_args.size == 1
      level = primary_navigation.level_for_item(navigation_args.first)
      level ? { :"level_#{level}" => navigation_args.first } : {}
    else
      navigation_args.each_with_index
                     .with_object({}) do |(arg, i), h|
                       h[:"level_#{i + 1}"] = arg
                     end
    end
  end

  # Adds methods for explicitely setting the current 'active' navigation to
  # the controllers.
  # Since version 2.0.0 the simple_navigation plugin determines the active
  # navigation based on the current url by default (auto highlighting),
  # so explicitely defining the active navigation in the controllers is only
  # needed for edge cases where automatic highlighting does not work.
  #
  # On the controller class level, use the <tt>navigation</tt> method to set the
  # active navigation for all actions in the controller.
  # Let's assume that we have a primary navigation item :account which in turn
  # has a sub navigation item :settings.
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
  # The first example sets the current primary navigation to :account for all
  # actions. No active sub_navigation.
  # The second example sets the current sub navigation to :settings and since
  # it is a child of :account the current primary navigation is set to :account.
  #
  # On the controller instance level, use the <tt>current_navigation</tt> method
  # to define the active navigation for a specific action.
  # The navigation item that is set in <tt>current_navigation</tt> overrides the
  # one defined on the controller class level (see <tt>navigation</tt> method).
  # Thus if you have an :account primary item with a :special
  # sub navigation item:
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
  # The code above still sets the active primary navigation to :account for all
  # actions, but sets the sub_navigation to :account -> :special for
  # 'your_special_action'.
  #
  # Note 1: As you can see above you just have to set the navigation item of
  #         your 'deepest' navigation level as active and all its parents are
  #         marked as active, too.
  #
  # Note 2: The specified symbols must match the keys for your navigation
  #         items in your config/navigation.rb file.
  module ControllerMethods
    def self.included(base) #:nodoc:
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      # Sets the active navigation for all actions in this controller.
      #
      # The specified symbol must match the keys for your navigation items
      # in your config/navigation.rb file.
      def navigation(*args)
        class_eval do
          define_method :sn_set_navigation do
            current_navigation(*args)
          end
          protected :sn_set_navigation
          before_filter :sn_set_navigation
        end
      end
    end

    module InstanceMethods
      # Sets the active navigation. Call this method in any action to override
      # the controller-wide active navigation specified by navigation.
      #
      # The specified symbol must match the keys for your navigation items in
      # your config/navigation.rb file.
      def current_navigation(*args)
        @sn_current_navigation_args = args
      end
    end
  end

  class Item
    def selected_by_config?
      key == SimpleNavigation.current_navigation_for(container.level)
    end
  end

  class ItemContainer
    def selected_item
      self[SimpleNavigation.current_navigation_for(level)] ||
      items.find(&:selected?)
    end
  end
end

ActionController::Base.send(:include, SimpleNavigation::ControllerMethods)
