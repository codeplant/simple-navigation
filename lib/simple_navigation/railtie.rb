module SimpleNavigation                                                                                                
  class Railtie < Rails::Railtie                                                                                       
    initializer "simple_navigation.init_rails" do |app|                                                                
      SimpleNavigation::Initializer::Rails3.run
    end                                                                                                                
  end                                                                                                                  
end
