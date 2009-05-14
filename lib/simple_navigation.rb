# A plugin for generating a simple navigation. See README for resources on usage instructions.
module SimpleNavigation

  mattr_accessor :config_file
  mattr_accessor :config_file_path
  mattr_accessor :controller
  
  # Reads the specified config_file and stores it for later evaluation.
  def self.load_config
    raise "config_file_path is not set!" unless self.config_file_path
    raise "Config file '#{config_file_path}' does not exists!" unless File.exists?(self.config_file_path)
    self.config_file = IO.read(self.config_file_path)
  end

  # Returns the singleton instance of the SimpleNavigation::Configuration
  def self.config 
    Configuration.instance
  end
  
  # Returns the ItemContainer that contains the items for the primary navigation
  def self.primary_navigation
    config.primary_navigation
  end

end