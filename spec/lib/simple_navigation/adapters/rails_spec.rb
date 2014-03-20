require 'spec_helper'

module SimpleNavigation
  module Adapters
    describe Rails do
      let(:action_controller) { ActionController::Base }
      let(:adapter) { SimpleNavigation::Adapters::Rails.new(context) }
      let(:context) { double(:context, controller: controller) }
      let(:controller) { double(:controller) }
      let(:request) { double(:request) }
      let(:simple_navigation) { SimpleNavigation }
      let(:template) { double(:template, request: request) }

      describe '.register' do
        before { action_controller.stub(:include) }

        it 'calls set_env' do
          expect(simple_navigation).to receive(:set_env).with('./', 'test')
          simple_navigation.register
        end

        it 'extends the ActionController::Base with the Helpers' do
          expect(action_controller).to receive(:include)
                                       .with(SimpleNavigation::Helpers)
          simple_navigation.register
        end

        it 'installs the helper methods in the controller' do
          expect(action_controller).to receive(:helper_method).with(:render_navigation)
          expect(action_controller).to receive(:helper_method).with(:active_navigation_item_name)
          expect(action_controller).to receive(:helper_method).with(:active_navigation_item_key)
          expect(action_controller).to receive(:helper_method).with(:active_navigation_item)
          expect(action_controller).to receive(:helper_method).with(:active_navigation_item_container)
          simple_navigation.register
        end
      end

      describe '#initialize' do
        context "when the controller's template is set" do
          before { controller.stub(instance_variable_get: template) }

          it "sets the adapter's request accordingly" do
            expect(adapter.request).to be request
          end
        end

        context "when the controller's template is not set" do
          before { controller.stub(instance_variable_get: nil) }

          it "sets the adapter's request to nil" do
            expect(adapter.request).to be_nil
          end
        end

        it "sets the adapter's controller to the context's controller" do
          expect(adapter.controller).to be controller
        end

        context "when the controller's template is stored as instance var (Rails2)" do
          context "when the controller's template is set" do
            before { controller.stub(instance_variable_get: template) }

            it "sets the adapter's template accordingly" do
              expect(adapter.template).to be template
            end
          end

          context "when the controller's template is not set" do
            before { controller.stub(instance_variable_get: nil) }

            it "set the adapter's template to nil" do
              expect(adapter.template).to be_nil
            end
          end
        end

        context "when the controller's template is stored as view_context (Rails3)" do
          context 'and the template is set' do
            before { controller.stub(view_context: template) }

            it "sets the adapter's template accordingly" do
              expect(adapter.template).to be template
            end
          end

          context 'and the template is not set' do
            before { controller.stub(view_context: nil) }

            it "sets the adapter's template to nil" do
              expect(adapter.template).to be_nil
            end
          end
        end
      end
  
      describe '#request_uri' do
        context "when the adapter's request is set" do
          before { adapter.stub(request: request) }

          context 'and request.fullpath is defined' do
            let(:request) { double(:request, fullpath: '/fullpath') }

            it "sets the adapter's request_uri to the request.fullpath" do
              expect(adapter.request_uri).to eq '/fullpath'
            end
          end

          context 'and request.fullpath is not defined' do
            let(:request) { double(:request, request_uri: '/request_uri') }

            before { adapter.stub(request: request) }

            it "sets the adapter's request_uri to the request.request_uri" do
              expect(adapter.request_uri).to eq '/request_uri'
            end
          end
        end

        context "when the adapter's request is not set" do
          before { adapter.stub(request: nil) }

          it "sets the adapter's request_uri to an empty string" do
            expect(adapter.request_uri).to eq ''
          end
        end
      end
  
      describe '#request_path' do
        context "when the adapter's request is set" do
          let(:request) { double(:request, path: '/request_path') }

          before { adapter.stub(request: request) }

          it "sets the adapter's request_path to the request.path" do
            expect(adapter.request_path).to eq '/request_path'
          end
        end

        context "when the adapter's request is not set" do
          before { adapter.stub(request: nil) }

          it "sets the adapter's request_path to an empty string" do
            expect(adapter.request_path).to eq ''
          end
        end
      end

      describe '#context_for_eval' do
        context "when the adapter's controller is set" do
          before { adapter.instance_variable_set(:@controller, controller) }

          context "and the adapter's template is set" do
            before { adapter.instance_variable_set(:@template, template) }

            it "sets the adapter's context_for_eval to the template" do
              expect(adapter.context_for_eval).to be template
            end
          end

          context "and the adapter's template is not set" do
            before { adapter.instance_variable_set(:@template, nil) }

            it "sets the adapter's context_for_eval to the controller" do
              expect(adapter.context_for_eval).to be controller
            end
          end
        end

        context "when the adapter's controller is not set" do
          before { adapter.instance_variable_set(:@controller, nil) }

          context "and the adapter's template is set" do
            before { adapter.instance_variable_set(:@template, template) }

            it "sets the adapter's context_for_eval to the template" do
              expect(adapter.context_for_eval).to be template
            end
          end

          context "and the adapter's template is not set" do
            before { adapter.instance_variable_set(:@template, nil) }

            it 'raises an exception' do
              expect{ adapter.context_for_eval }.to raise_error
            end
          end
        end
      end

      describe '#current_page?' do
        context "when the adapter's template is set" do
          before { adapter.stub(template: template) }

          it 'delegates the call to the template' do
            expect(template).to receive(:current_page?).with(:page)
            adapter.current_page?(:page)
          end
        end

        context "when the adapter's template is not set" do
          before { adapter.stub(template: nil) }

          it 'returns false' do
            expect(adapter).not_to be_current_page(:page)
          end
        end
      end

      describe '#link_to' do
        let(:options) { double(:options) }

        context "when the adapter's template is set" do
          before { adapter.stub(template: template, html_safe: 'safe_text') }

          context 'with considering item names as safe' do
            before { SimpleNavigation.config.consider_item_names_as_safe = true }
            after { SimpleNavigation.config.consider_item_names_as_safe = false }

            it 'delegates the call to the template (with html_safe text)' do
              expect(template).to receive(:link_to)
                                  .with('safe_text', 'url', options)
              adapter.link_to('text', 'url', options)
            end
          end

          context 'with considering item names as UNsafe (default)' do

            it 'delegates the call to the template (with html_safe text)' do
              expect(template).to receive(:link_to)
                                  .with('text', 'url', options)
              adapter.link_to('text', 'url', options)
            end
          end


        end

        context "when the adapter's template is not set" do
          before { adapter.stub(template: nil) }

          it 'returns nil' do
            expect(adapter.link_to('text', 'url', options)).to be_nil
          end
        end
      end

      describe '#content_tag' do
        let(:options) { double(:options) }

        context "when the adapter's template is set" do
          before { adapter.stub(template: template, html_safe: 'safe_text') }

          it 'delegates the call to the template (with html_safe text)' do
            expect(template).to receive(:content_tag)
                                .with(:div, 'safe_text', options)
            adapter.content_tag(:div, 'text', options)
          end
        end

        context "when the adapter's template is not set" do
          before { adapter.stub(template: nil) }

          it 'returns nil' do
            expect(adapter.content_tag(:div, 'text', options)).to be_nil
          end
        end
      end

      describe '#extract_controller_from' do
        context 'when context responds to controller' do
          it 'returns the controller' do
            expect(adapter.send(:extract_controller_from, context)).to be controller
          end
        end

        context 'when context does not respond to controller' do
          let(:context) { double(:context) }

          it 'returns the context' do
            expect(adapter.send(:extract_controller_from, context)).to be context
          end
        end
      end
  
      describe '#html_safe' do
        let(:input) { double(:input) }

        context 'when input responds to html_safe' do
          let(:safe) { double(:safe) }

          before { input.stub(html_safe: safe) }

          it 'returns the html safe version of the input' do
            expect(adapter.send(:html_safe, input)).to be safe
          end
        end

        context 'when input does not respond to html_safe' do
          it 'returns the input' do
            expect(adapter.send(:html_safe, input)).to be input
          end
        end
      end

      describe '#link_title' do
        let(:name) { double(:name, html_safe: safe) }
        let(:safe) { double(:safe) }

        context 'when config option consider_item_names_as_safe is true' do
          before { SimpleNavigation.config.consider_item_names_as_safe = true }
          after { SimpleNavigation.config.consider_item_names_as_safe = false }
          
          it 'uses the html_safe version of the name' do
            expect(adapter.send(:link_title, name)).to be safe
          end
        end

        # TODO: Does it make sense ?
        context 'when config option consider_item_names_as_safe is false (default)' do
          before do
            SimpleNavigation.config.consider_item_names_as_safe = false
            adapter.stub(template: template)
          end

          it 'uses the item name' do
            expect(adapter.send(:link_title, name)).to be name
          end
        end
      end
    end
  end
end
