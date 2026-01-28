# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_navigation/version'

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
  spec.require_paths    = ['lib']

  spec.rdoc_options     = ['--inline-source', '--charset=UTF-8']

  spec.add_dependency 'activesupport', '>= 2.3.2'
  spec.add_dependency 'ostruct'
end
