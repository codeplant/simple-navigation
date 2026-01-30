# frozen_string_literal: true

require_relative 'lib/simple_navigation/version'

Gem::Specification.new do |spec|
  spec.name             = 'simple-navigation'
  spec.version          = SimpleNavigation::VERSION
  spec.authors          = ['Andi Schacke', 'Mark J. Titorenko', 'Simon Courtois']
  spec.email            = ['andi@codeplant.ch']
  spec.description      = 'With the simple-navigation gem installed you can easily ' \
                          'create multilevel navigations for your Rails, Sinatra or ' \
                          'Padrino applications. The navigation is defined in a ' \
                          'single configuration file. It supports automatic as well ' \
                          'as explicit highlighting of the currently active ' \
                          'navigation through regular expressions.'
  spec.summary          = 'simple-navigation is a ruby library for creating navigations ' \
                          '(with multiple levels) for your Rails, Sinatra or ' \
                          'Padrino application.'
  spec.homepage         = 'http://github.com/codeplant/simple-navigation'
  spec.license          = 'MIT'

  spec.files            = `git ls-files -z`.split("\x0")

  spec.rdoc_options     = ['--inline-source', '--charset=UTF-8']

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_dependency 'activesupport', '>= 6.1.0'
  spec.add_dependency 'json'
  spec.add_dependency 'zeitwerk'
end
