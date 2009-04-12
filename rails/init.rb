config_file_path = File.join(RAILS_ROOT, 'config', 'navigation.rb')
SimpleNavigation.load_config(config_file_path) if File.exists?(config_file_path)
ActionController::Base.send(:include, SimpleNavigation::ControllerMethods)