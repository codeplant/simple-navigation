module SimpleNavigation
  class Railtie < Rails::Railtie
    railtie_name :simple_navigation
    
    initializer "simple_navigation.init" do |app|
      SimpleNavigation.init
    end
  end
end