require 'simple_navigation'
SimpleNavigation.load_config(File.join(RAILS_ROOT, 'config', 'navigation.rb'))
ActionController::Base.send(:include, SimpleNavigation::ControllerMethods)