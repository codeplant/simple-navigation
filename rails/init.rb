default_config_file_path = File.join(RAILS_ROOT, 'config')
SimpleNavigation.config_file_path = default_config_file_path unless SimpleNavigation.config_file_path
ActionController::Base.send(:include, SimpleNavigation::ControllerMethods)