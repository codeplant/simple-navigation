if Rails::VERSION::MAJOR == 3
  require 'simple_navigation/initializer/rails_3'
else
  require 'simple_navigation/initializer/rails_2'
end