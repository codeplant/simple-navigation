module SimpleNavigation
  class Railtie < Rails::Railtie
    railtie_name :simple_navigation
    
    initializer "simple_navigation.init_rails" do |app|
      SimpleNavigation.rails_root = Rails.root
      SimpleNavigation.rails_env = Rails.env
      SimpleNavigation.init_rails
    end
  end
end