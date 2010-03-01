module SimpleNavigation                                                                                                
  class Railtie < Rails::Railtie                                                                                       
    railtie_name :simple_navigation                                                                                    
                                                                                                                       
    initializer "simple_navigation.init_rails" do |app|                                                                
      SimpleNavigation::Initializer::Rails3.run
    end                                                                                                                
  end                                                                                                                  
end