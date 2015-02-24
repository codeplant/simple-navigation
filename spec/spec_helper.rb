require 'initializers/have_css_matcher'
require 'initializers/memfs'
require 'rails'
require 'action_controller'
require 'rails-dom-testing'
require 'coveralls'
require 'action_view'

Coveralls.wear!

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = :random

  config.before do
    SimpleNavigation.config_files.clear
    setup_adapter_for :rails
  end
end

unless defined?(Rails)
  module ::Rails
    def self.root; './'; end
    def self.env; 'test'; end

    class Railtie
      def self.initializer(*args); end
    end
  end
end

require 'simple_navigation'

def setup_adapter_for(framework, context = double(:context))
  if framework == :rails
    allow(context).to receive_messages(view_context: ActionView::Base.new)
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
def setup_items(container)
  container.item :users, 'Users', '/users', html: { id: 'users_id' }, link_html: { id: 'users_link_id' }
  container.item :invoices, 'Invoices', '/invoices' do |invoices|
    invoices.item :paid, 'Paid', '/invoices/paid'
    invoices.item :unpaid, 'Unpaid', '/invoices/unpaid'
  end
  container.item :accounts, 'Accounts', '/accounts', html: { style: 'float:right' }
  container.item :miscellany, 'Miscellany'

  container.items.each do |item|
    allow(item).to receive_messages(selected?: false, selected_by_condition?: false)

    if item.sub_navigation
      item.sub_navigation.items.each do |item|
        allow(item).to receive_messages(selected?: false, selected_by_condition?: false)
      end
    end
  end
end
