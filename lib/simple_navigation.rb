# A plugin for generating a simple navigation. See README for resources on usage instructions.
module SimpleNavigation

  mattr_accessor :config_file
  
  # Reads the specified config_file and stores it for later evaluation.
  def self.load_config(config_file)
    self.config_file = IO.read(config_file)
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