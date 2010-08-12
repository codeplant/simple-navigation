module SimpleNavigation                                                                                                
  class Railtie < Rails::Railtie                                                                                       
    initializer "simple_navigation.init_framework" do |app|
      #SimpleNavigation::Initializer::Rails3.run
      SimpleNavigation.init_framework
    end                                                                                                                
  end                                                                                                                  
end
