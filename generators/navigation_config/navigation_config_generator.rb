class NavigationConfigGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "config/navigation.rb", "config/navigation.rb"
      m.readme "../../../README"
    end
  end
end