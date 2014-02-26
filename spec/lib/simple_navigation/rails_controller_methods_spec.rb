require 'spec_helper'
require 'simple_navigation/rails_controller_methods'

class TestController
  include SimpleNavigation::ControllerMethods

  def self.helper_method(*args)
    @helper_methods = args
  end

  def self.before_filter(*args)
    @before_filters = args
  end
end

module SimpleNavigation
  describe 'Explicit navigation in rails' do
    it 'enhances ActionController after loading the extensions' do
      methods = ActionController::Base.instance_methods.map(&:to_s)
      expect(methods).to include 'current_navigation'
    end
  end

  describe ControllerMethods do
    let(:controller) { TestController.new }

    before { SimpleNavigation::Configuration.stub(:load) }

    describe 'when the module is included' do
      it 'extends the ClassMethods module' do
        expect(controller.class).to respond_to(:navigation)
      end

      it "includes the InstanceMethods module" do
        expect(controller).to respond_to(:current_navigation)
      end
    end
  end

  module ControllerMethods
    describe ClassMethods do
      let(:controller) { TestController.new }

      describe '#navigation' do
        context 'when the navigation method is not called' do
          it "doesn't have any instance method called 'sn_set_navigation'" do
            has_method = controller.respond_to?(:sn_set_navigation, true)
            expect(has_method).to be_falsey
          end
        end

        context 'when the navigation method is called' do
          before do
            controller.class_eval { navigation(:primary, :secondary) }
          end

          it 'creates an instance method called "sn_set_navigation"' do
            has_method = controller.respond_to?(:sn_set_navigation, true)
            expect(has_method).to be_truthy
          end

          it 'does not create a public method' do
            methods = controller.public_methods.map(&:to_s)
            expect(methods).not_to include 'sn_set_navigation'
          end

          it 'creates a protected method' do
            methods = controller.protected_methods.map(&:to_s)
            expect(methods).to include 'sn_set_navigation'
          end

          it 'creates a method that calls current_navigation with the specified keys' do
            expect(controller).to receive(:current_navigation)
                                 .with(:primary, :secondary)
            controller.send(:sn_set_navigation)
          end
        end
      end
    end

    describe InstanceMethods do
      let(:controller) { TestController.new }

      describe '#current_navigation' do
        shared_examples 'setting the correct sn_current_navigation_args' do |args|
          it 'sets the sn_current_navigation_args as specified' do
            controller.current_navigation(*args)
            args = controller.instance_variable_get(:@sn_current_navigation_args)
            expect(args).to eq args
          end
        end

        it_behaves_like 'setting the correct sn_current_navigation_args', [:first]
        it_behaves_like 'setting the correct sn_current_navigation_args', [:first, :second]
      end
    end
  end

  describe 'SimpleNavigation module additions' do
    let(:adapter) { double(:adapter, controller: controller) }
    let(:controller) { double(:controller) }
    let(:simple_navigation) { SimpleNavigation }

    before { simple_navigation.stub(adapter: adapter) }

    describe '.handle_explicit_navigation' do
      def args(*args)
        keys = args.compact.empty? ? nil : args
        simple_navigation.stub(explicit_navigation_args: keys)
      end

      context 'when there is an explicit navigation set' do
        context 'and it is a list of navigations' do
          before { args :first, :second, :third }

          it 'sets the correct instance var in the controller' do
            expect(controller).to receive(:instance_variable_set)
                                 .with(:@sn_current_navigation_3, :third)
            simple_navigation.handle_explicit_navigation
          end
        end

        context 'and it is a single navigation' do
          context 'and the specified key is a valid navigation item' do
            let(:primary) { double(:primary, level_for_item: 2) }

            before do
              simple_navigation.stub(primary_navigation: primary)
              args :key
            end

            it 'sets the correct instance var in the controller' do
              expect(controller).to receive(:instance_variable_set)
                                    .with(:@sn_current_navigation_2, :key)
              simple_navigation.handle_explicit_navigation
            end
          end

          context 'and the specified key is an invalid navigation item' do
            let(:primary) { double(:primary, level_for_item: nil) }

            before do
              subject.stub(primary_navigation: primary)
              args :key
            end

            it 'raises an exception' do
              expect{ subject.handle_explicit_navigation }.to raise_error
            end
          end
        end

        context 'and the argument is a one-level hash' do
          before { args level_2: :key }

          it 'sets the correct instance var in the controller' do
            expect(controller).to receive(:instance_variable_set)
                                  .with(:@sn_current_navigation_2, :key)
            simple_navigation.handle_explicit_navigation
          end
        end

        context 'when the argument is a multiple levels hash' do
          before { args level_2: :key, level_1: :bla }

          it 'sets the correct instance var in the controller' do
            expect(controller).to receive(:instance_variable_set)
                                  .with(:@sn_current_navigation_2, :key)
            simple_navigation.handle_explicit_navigation
          end
        end
      end

      context 'when no explicit navigation is set' do
        before { args nil }

        it "doesn't set the current_navigation instance var in the controller" do
          expect(controller).not_to receive(:instance_variable_set)
          simple_navigation.handle_explicit_navigation
        end
      end
    end

    describe '#current_navigation_for' do
      it 'accesses the correct instance var in the controller' do
        expect(controller).to receive(:instance_variable_get)
                              .with(:@sn_current_navigation_1)
        simple_navigation.current_navigation_for(1)
      end
    end
  end

  describe Item do
    let(:item) { Item.new(item_container, :my_key, 'name', 'url', {}) }
    let(:item_container) { double(:item_container, level: 1) }
    let(:simple_navigation) { SimpleNavigation }

    before do
      item_container.stub(:dom_attributes=)
      simple_navigation.stub(current_navigation_for: navigation_key)
    end

    describe '#selected_by_config?' do
      context 'when the navigation explicitly set' do
        context 'when current matches the key' do
          let(:navigation_key) { :my_key }

          it 'selects the item' do
            expect(item).to be_selected_by_config
          end
        end

        context "when current doesn't match the key" do
          let(:navigation_key) { :other_key }

          it "doesn't select the item" do
            expect(item).not_to be_selected_by_config
          end
        end
      end

      context 'when the navigation is not explicitly set' do
        let(:navigation_key) { nil }

        it "doesn't select the item" do
          expect(item).not_to be_selected_by_config
        end
      end
    end
  end

  describe ItemContainer do
    describe '#selected_item' do
      let(:item_container) { SimpleNavigation::ItemContainer.new }
      let(:item_1) { double(:item, selected?: false) }
      let(:item_2) { double(:item, selected?: false) }

      before do
        SimpleNavigation.stub(:current_navigation_for)
        item_container.instance_variable_set(:@items, [item_1, item_2])
      end

      context 'when a navigation is explicitely set' do
        before { item_container.stub(:[] => item_1) }

        it 'returns the explicitely selected item' do
          expect(item_container.selected_item).to be item_1
        end
      end

      context 'when no navigation is explicitely set' do
        before { item_container.stub(:[] => nil) }

        context 'and no item is selected' do
          it 'returns nil' do
            expect(item_container.selected_item).to be_nil
          end
        end

        context 'and one item is selected' do
          before { item_1.stub(selected?: true) }

          it 'returns the selected item' do
            expect(item_container.selected_item).to be item_1
          end
        end
      end
    end
  end
end
