module SimpleNavigation
  module Adapters
    class Sinatra
      
      def self.init_framework
      end
      
      def initialize(context)
        puts "XXXXX #{context.request}"
      end
      
      
    end
  end
end