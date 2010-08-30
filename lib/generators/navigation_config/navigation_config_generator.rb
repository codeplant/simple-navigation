class NavigationConfigGenerator < Rails::Generators::Base
  def self.source_root
    @source_root ||= File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','generators','navigation_config', 'templates'))
  end

  desc 'Creates a template config file for the simple-navigation plugin. You will find the generated file in config/navigation.rb.'
  def navigation_config
    copy_file('config/navigation.rb', 'config/navigation.rb')    
    say File.read(File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','README')))
  end
  
end