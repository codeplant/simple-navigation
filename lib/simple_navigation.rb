# A plugin for generating a simple navigation. See README for resources on usage instructions.
module SimpleNavigation

  mattr_accessor :config_files
  mattr_accessor :config_file_path
  mattr_accessor :controller
  self.config_files = {}
  
  # Reads the config_file for the specified navigation_context and stores it for later evaluation.
  def self.load_config(navigation_context = :default)
    raise "config_file_path is not set!" unless self.config_file_path
    raise "Config file '#{self.config_file_name}' does not exists!" unless File.exists?(self.config_file_name(navigation_context))
    if ::RAILS_ENV == 'production'
      self.config_files[navigation_context] ||= IO.read(self.config_file_name(navigation_context))
    else
      self.config_files[navigation_context] = IO.read(self.config_file_name(navigation_context))
    end
  end

  # Returns the singleton instance of the SimpleNavigation::Configuration
  def self.config 
    Configuration.instance
  end
  
  # Returns the ItemContainer that contains the items for the primary navigation
  def self.primary_navigation
    config.primary_navigation
  end
  
  # Returns the path to the config_file for the given navigation_context
  def self.config_file_name(navigation_context = :default)
    file_name = navigation_context == :default ? '' : "#{navigation_context.to_s.underscore}_"
    File.join(self.config_file_path, "#{file_name}navigation.rb")
  end

end