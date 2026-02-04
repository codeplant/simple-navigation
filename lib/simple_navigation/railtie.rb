# frozen_string_literal: true

module SimpleNavigation
  class Railtie < ::Rails::Railtie
    initializer 'simple_navigation.register' do |_app|
      SimpleNavigation.register
    end
  end
end
