# frozen_string_literal: true

# Load ruby-warning gem
require 'warning'

Warning[:deprecated]   = true
Warning[:experimental] = true
Warning[:performance]  = true if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.3.0')

# Ignore all warnings in Gem dependencies
Gem.path.each do |path|
  Warning.ignore(//, path)
end

# Ignore method redefinitions
Warning.ignore(/warning: previous definition of/)
Warning.ignore(/warning: method redefined;/)

# Load simplecov
require 'simplecov'
require 'simplecov_json_formatter'

# Start SimpleCov
SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::JSONFormatter])
  add_filter 'spec/'
end

# Load test gems
require 'memfs'
require 'capybara/rspec'

# Define our own spec helper
module SimpleNavigationTest
  extend RSpec::Mocks::ExampleMethods

  module_function

  def setup_adapter_for(framework, context = double(:context))
    if framework == :rails
      # Rails 6.0 and 6.1 provide ActionView::Base.empty method that creates ActionView with an empty LookupContext.
      # The method is not available on older versions
      view_context = ActionView::Base.respond_to?(:empty) ? ActionView::Base.empty : ActionView::Base.new
      allow(context).to receive_messages(view_context: view_context)
    end

    allow(SimpleNavigation).to receive_messages(framework: framework)
    SimpleNavigation.load_adapter
    SimpleNavigation.init_adapter_from(context)
  end

  def select_an_item(item)
    allow(item).to receive_messages(selected?: true)
  end

  def setup_container(dom_id, dom_class)
    container = SimpleNavigation::ItemContainer.new(1)
    container.dom_id = dom_id
    container.dom_class = dom_class
    container
  end

  def setup_navigation(dom_id, dom_class)
    setup_adapter_for :rails
    container = setup_container(dom_id, dom_class)
    setup_items(container)
    container
  end

  # FIXME: adding the :link option for the list renderer messes up the other
  #        renderers
  def setup_items(container) # rubocop:disable Metrics/AbcSize
    container.item :users, 'Users', '/users', html: { id: 'users_id' }, link_html: { id: 'users_link_id' }
    container.item :invoices, 'Invoices', '/invoices' do |invoices|
      invoices.item :paid, 'Paid', '/invoices/paid'
      invoices.item :unpaid, 'Unpaid', '/invoices/unpaid'
    end
    container.item :accounts, 'Accounts', '/accounts', html: { style: 'float:right' }
    container.item :miscellany, 'Miscellany'

    container.items.each do |item|
      allow(item).to receive_messages(selected?: false, selected_by_condition?: false)

      item.sub_navigation&.items&.each do |item|
        allow(item).to receive_messages(selected?: false, selected_by_condition?: false)
      end
    end
  end
end

# Define our own matcher
RSpec::Matchers.define :have_css do |expected, times|
  match do |actual|
    selector = Nokogiri::HTML(actual).css(expected)

    if times
      expect(selector.size).to eq times
    else
      expect(selector.size).to be >= 1
    end
  end

  failure_message do |actual|
    "expected #{actual} to have #{times || 1} elements matching '#{expected}'"
  end

  failure_message_when_negated do |actual|
    "expected #{actual} not to have #{times || 1} elements matching '#{expected}'"
  end
end

# Configure RSpec
RSpec.configure do |config|
  config.include SimpleNavigationTest

  config.color = true
  config.fail_fast = false

  config.order = :random
  Kernel.srand config.seed

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://rspec.info/features/3-12/rspec-core/configuration/zero-monkey-patching-mode/
  config.disable_monkey_patching!

  config.raise_errors_for_deprecations!

  config.around(memfs: true) do |example|
    MemFs.activate { example.run }
  end
end

# Configure RSpec with Rails
begin
  require 'rails'
rescue LoadError # rubocop:disable Lint/SuppressedException
else
  require 'fake_app/rails_app'
  require 'rspec/rails'

  Capybara.app = RailsApp::Application

  RSpec.configure do |config|
    config.before do
      SimpleNavigation.config_files.clear
      SimpleNavigationTest.setup_adapter_for :rails
    end
  end
end

class ModifiedHash < Hash; end
