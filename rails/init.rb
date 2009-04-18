default_config_file_path = File.join(RAILS_ROOT, 'config', 'navigation.rb')
SimpleNavigation.config_file_path = default_config_file_path unless SimpleNavigation.config_file_path
SimpleNavigation.load_config
ActionController::Base.send(:include, SimpleNavigation::ControllerMethods)