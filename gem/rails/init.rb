if Rails::VERSION::MAJOR == 3
  SimpleNavigation::Initializer::Rails3.run
else
  SimpleNavigation::Initializer::Rails2.run
end