module SimpleNavigation
  module Initializer

    class Rails2
      def self.run
        SimpleNavigation.rails_root = RAILS_ROOT
        SimpleNavigation.rails_env = RAILS_ENV
        SimpleNavigation.init_rails
      end
    end
    
    class Rails3
      def self.run
        SimpleNavigation.rails_root = Rails.root
        SimpleNavigation.rails_env = Rails.env
        SimpleNavigation.init_rails
      end
    end
    
  end
end