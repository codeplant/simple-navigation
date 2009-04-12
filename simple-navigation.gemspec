# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{simple-navigation}
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andi Schacke"]
  s.date = %q{2009-04-12}
  s.description = %q{Simple Navigation is a ruby library for creating a navigation (optionally with sub navigation) for your rails app.}
  s.email = %q{andreas.schacke@gmail.com}
  s.files = ["README", "CHANGELOG", "Rakefile", "generators/navigation_config/navigation_config_generator.rb", "generators/navigation_config/templates/config/navigation.rb", "generators/navigation_config/USAGE", "init.rb", "install.rb", "lib/simple_navigation/configuration.rb", "lib/simple_navigation/controller_methods.rb", "lib/simple_navigation/helpers.rb", "lib/simple_navigation/item.rb", "lib/simple_navigation/item_container.rb", "lib/simple_navigation/renderer/base.rb", "lib/simple_navigation/renderer/list.rb", "lib/simple_navigation.rb", "rails/init.rb", "spec/lib/configuration_spec.rb", "spec/lib/controller_methods_spec.rb", "spec/lib/helpers_spec.rb", "spec/lib/item_container_spec.rb", "spec/lib/item_spec.rb", "spec/lib/renderer/base_spec.rb", "spec/lib/renderer/list_spec.rb", "spec/spec_helper.rb", "uninstall.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/andi/simple-navigation}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Simple Navigation is a ruby library for creating a navigation (optionally with sub navigation) for your rails app.}
end
