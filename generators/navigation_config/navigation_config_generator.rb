class NavigationConfigGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "config/navigation.rb", "config/navigation.rb"
      m.readme File.join(File.dirname(__FILE__), "../../README")
    end
  end
end