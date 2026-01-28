# frozen_string_literal: true

appraise 'rails_3.2' do
  gem 'railties', '~> 3.2.0'
  gem 'rspec-rails'
end

appraise 'rails_4.1' do
  gem 'railties', '~> 4.1.0'
  gem 'rspec-rails'
end

appraise 'rails_4.2' do
  gem 'railties', '~> 4.2.0'
  gem 'rspec-rails'
end

appraise 'rails_5.2' do
  gem 'railties', '~> 5.2.0'
  gem 'rspec-rails'
end

appraise 'rails_6.0' do
  gem 'railties', '~> 6.0.0'
  gem 'rspec-rails'
  gem 'concurrent-ruby', '1.3.4'

  # Fix:
  # warning: drb was loaded from the standard library, but is not part of the default gems starting from Ruby 3.4.0.
  # You can add drb to your Gemfile or gemspec to silence this warning.
  install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0") }' do
    gem 'base64'
    gem 'drb'
    gem 'mutex_m'
  end

  install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("4.0.0") }' do
    gem 'benchmark'
  end
end

appraise 'rails_6.1' do
  gem 'railties', '~> 6.1.0'
  gem 'rspec-rails'
  gem 'concurrent-ruby', '1.3.4'

  # Fix:
  # warning: drb was loaded from the standard library, but is not part of the default gems starting from Ruby 3.4.0.
  # You can add drb to your Gemfile or gemspec to silence this warning.
  install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0") }' do
    gem 'base64'
    gem 'drb'
    gem 'mutex_m'
  end

  install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("4.0.0") }' do
    gem 'benchmark'
  end
end

appraise 'rails_7.0' do
  gem 'railties', '~> 7.0.0'
  gem 'rspec-rails'
end

appraise 'rails_7.1' do
  gem 'railties', '~> 7.1.0'
  gem 'rspec-rails'
end

appraise 'rails_7.2' do
  gem 'railties', '~> 7.2.0'
  gem 'rspec-rails'
end

appraise 'rails_8.0' do
  gem 'railties', '~> 8.0.0'
  gem 'rspec-rails'
end

appraise 'rails_8.1' do
  gem 'railties', '~> 8.1.0'
  gem 'rspec-rails'
end
