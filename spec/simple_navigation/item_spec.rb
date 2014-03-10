require 'spec_helper'

module SimpleNavigation
  describe Item do
    let!(:item_container) { ItemContainer.new }

    let(:adapter) { double(:adapter) }
    let(:item_args) { [item_container, :my_key, 'name', url, options, items] }
    let(:item) { Item.new(*item_args) }
    let(:items) { nil }
    let(:options) { Hash.new }
    let(:url) { 'url' }

    before { SimpleNavigation.stub(adapter: adapter) }

    describe '#initialize' do
      context 'when there is a sub_navigation' do
        let(:subnav_container) { double(:subnav_container).as_null_object }

        before { ItemContainer.stub(new: subnav_container) }

        context 'when a block is given' do
          it 'creates a new ItemContainer with a level+1' do
            expect(ItemContainer).to receive(:new).with(2)
            Item.new(*item_args) {}
          end

          it 'calls the block' do
            expect{ |blk|
              Item.new(*item_args, &blk)
            }.to yield_with_args(subnav_container)
          end
        end

        context 'when no block is given' do
          context 'and items are given' do
            let(:items) { double(:items) }

            it 'creates a new ItemContainer with a level+1' do
              expect(ItemContainer).to receive(:new).with(2)
              Item.new(*item_args)
            end

            it "sets the items on the subnav_container" do
              expect(subnav_container).to receive(:items=).with(items)
              Item.new(*item_args)
            end
          end

          context 'and no items are given' do
            it "doesn't create a new ItemContainer" do
              expect(ItemContainer).not_to receive(:new)
              Item.new(*item_args)
            end
          end
        end
      end

      context 'when a :method option is given' do
        let(:options) {{ method: :delete }}

        it "sets the item's method" do
          expect(item.method).to eq :delete
        end

        it 'sets the html options without the method' do
          meth = item.instance_variable_get(:@html_options).key?(:method)
          expect(meth).to be_false
        end
      end

      context 'when no :method option is given' do
        it "sets the item's method to nil" do
          expect(item.method).to be_nil
        end
      end

      context 'setting class and id on the container' do
        let!(:create) { item }

        let(:options) {{
          container_class: 'container_class',
          container_id: 'container_id',
          container_attributes: { 'ng-show' => 'false' }
        }}

        it "fills in the container's dom_attributes" do
          expect(item_container.dom_attributes).to eq({
            id: 'container_id',
            class: 'container_class',
            'ng-show' => 'false'
          })
        end
      end

      context 'when a :highlights_on option is given' do
        it "sets the item's highlights_on to nil" do
          expect(item.highlights_on).to be_nil
        end
      end

      context 'when no :highlights_on option is given' do
        let(:highlights_on) { double(:highlights_on) }
        let(:options) {{ highlights_on: highlights_on }}

        it "sets the item's highlights_on" do
          expect(item.highlights_on).to eq highlights_on
        end

        it 'sets the html options without the method' do
          html_options = item.instance_variable_get(:@html_options)
          expect(html_options).not_to have_key(:highlights_on)
        end
      end

      context 'when a url is given' do
        context 'and it is a string' do
          it "sets the item's url accordingly" do
            expect(item.url).to eq 'url'
          end
        end

        context 'and it is a proc' do
          let(:url) { proc{ "my_" + "url" } }

          it "sets the item's url accordingly" do
            expect(item.url).to eq 'my_url'
          end
        end

        context 'and it is nil' do
          let(:url) { nil }

          it "sets the item's url accordingly" do
            expect(item.url).to be_nil
          end
        end
      end

      describe 'Optional url and optional options' do
        context 'when no parameter is specified' do
          let(:item_args) { [item_container, :my_key, 'name'] }

          it "sets the item's url to nil" do
            expect(item.url).to be_nil
          end
        end

        context 'when only a url is given' do
          let(:item_args) { [item_container, :my_key, 'name', 'url'] }

          it "set the item's url accordingly" do
            expect(item.url).to eq 'url'
          end
        end

        context 'when only options are given' do
          let(:item_args) { [item_container, :my_key, 'name', { option: true }] }

          it "sets the item's url to nil" do
            expect(item.url).to be_nil
          end

          it "sets the item's html_options accordingly" do
            html_options = item.instance_variable_get(:@html_options)
            expect(html_options).to eq({ option: true })
          end
        end

        context 'when url and options are given' do
          let(:options) {{ option: true }}

          it "set the item's url accordingly" do
            expect(item.url).to eq 'url'
          end

          it "sets the item's html_options accordingly" do
            html_options = item.instance_variable_get(:@html_options)
            expect(html_options).to eq({ option: true })
          end
        end
      end
    end

    describe '#name' do
      before do
        SimpleNavigation.config.stub(
          name_generator: proc{ |name| "<span>#{name}</span>" })
      end

      context 'when no option is given' do
        context 'and the name_generator uses only the name' do
          it 'uses the default name_generator' do
            expect(item.name).to eq '<span>name</span>'
          end
        end

        context 'and the name_generator uses only the item itself' do
          before do
            SimpleNavigation.config.stub(
              name_generator: proc{ |name, item| "<span>#{item.key}</span>" })
          end

          it 'uses the default name_generator' do
            expect(item.name).to eq '<span>my_key</span>'
          end
        end
      end

      context 'when the :apply_generator is false' do
        it "returns the item's name" do
          expect(item.name(apply_generator: false)).to eq 'name'
        end
      end
    end

    describe '#selected?' do
      context 'when the item is explicitly selected' do
        before { item.stub(selected_by_config?: true) }

        it 'is selected' do
          expect(item).to be_selected
        end

        # FIXME: testing the implementation not the behavior here
        it "doesn't check for selection by sub navigation" do
          expect(item).not_to receive(:selected_by_subnav?)
          item.selected?
        end

        # FIXME: testing the implementation not the behavior here
        it "doesn't check for selection by highlighting condition" do
          expect(item).not_to receive(:selected_by_condition?)
          item.selected?
        end
      end

      context "when the item isn't explicitly selected" do
        before { item.stub(selected_by_config?: false) }

        context 'and it is selected by sub navigation' do
          before { item.stub(selected_by_subnav?: true) }

          it 'is selected' do
            expect(item).to be_selected
          end
        end

        context "and it isn't selected by sub navigation" do
          before { item.stub(selected_by_subnav?: false) }

          context 'and it is selected by a highlighting condition' do
            before { item.stub(selected_by_condition?: true) }

            it 'is selected' do
              expect(item).to be_selected
            end
          end

          context "and it isn't selected by any highlighting condition" do
            before { item.stub(selected_by_condition?: false) }

            it "isn't selected" do
              expect(item).not_to be_selected
            end
          end
        end
      end
    end

    describe '#selected_class' do
      context 'when the item is selected' do
        before { item.stub(selected?: true) }

        it 'returns the default selected_class' do
          expect(item.selected_class).to eq 'selected'
        end

        context 'and selected_class is defined in the context' do
          before { item_container.stub(selected_class: 'defined') }

          it "returns the context's selected_class" do
            expect(item.selected_class).to eq 'defined'
          end
        end
      end
  
      context 'when the item is not selected' do
        before { item.stub(selected?: false) }

        it 'returns nil' do
          expect(item.selected_class).to be_nil
        end
      end
    end

    describe ':html_options argument' do
      let(:selected_classes) { 'selected simple-navigation-active-leaf' }

      context 'when the :class option is given' do
        let(:options) {{ class: 'my_class' }}

        context 'and the item is selected' do
          before { item.stub(selected?: true, selected_by_condition?: true) }

          it "adds the specified class to the item's html classes" do
            expect(item.html_options[:class]).to include('my_class')
          end

          it "doesn't replace the default html classes of a selected item" do
            expect(item.html_options[:class]).to include(selected_classes)
          end
        end

        context "and the item isn't selected" do
          before { item.stub(selected?: false, selected_by_condition?: false) }

          it "sets the specified class as the item's html classes" do
            expect(item.html_options[:class]).to include('my_class')
          end
        end
      end

      context "when the :class option isn't given" do
        context 'and the item is selected' do
          before { item.stub(selected?: true, selected_by_condition?: true) }

          it "sets the default html classes of a selected item" do
            expect(item.html_options[:class]).to include(selected_classes)
          end
        end

        context "and the item isn't selected" do
           before { item.stub(selected?: false, selected_by_condition?: false) }

           it "doesn't set any html class on the item" do
             expect(item.html_options[:class]).to be_blank
           end
        end
      end

      shared_examples 'generating id' do |id|
        it "sets the item's html id to the specified id" do
          expect(item.html_options[:id]).to eq id
        end
      end

      describe 'when the :id option is given' do
        let(:options) {{ id: 'my_id' }}

        before do
          item.stub(selected?: false,
                    selected_by_condition?: false,
                    autogenerate_item_ids?: generate_ids)
        end

        context 'and :autogenerate_item_ids is true' do
          let(:generate_ids) { true }

          it_behaves_like 'generating id', 'my_id'
        end

        context 'and :autogenerate_item_ids is false' do
          let(:generate_ids) { false }

          it_behaves_like 'generating id', 'my_id'
        end
      end

      context "when the :id option isn't given" do
        before do
          item.stub(selected?: false,
                    selected_by_condition?: false,
                    autogenerate_item_ids?: generate_ids)
        end

        context 'and :autogenerate_item_ids is true' do
          let(:generate_ids) { true }

          it_behaves_like 'generating id', 'my_key'
        end

        context 'and :autogenerate_item_ids is false' do
          let(:generate_ids) { false }

          it "doesn't set any html id on the item" do
            expect(item.html_options[:id]).to be_blank
          end
        end
      end
    end

    describe '#selected_by_subnav?' do
      before { item.stub(sub_navigation: sub_navigation) }

      context 'the item has a sub_navigation' do
        let(:sub_navigation) { double(:sub_navigation) }

        context 'and an item of the sub_navigation is selected' do
          before do
            sub_navigation.stub(selected?: true, selected_by_condition?: true)
          end

          it 'returns true' do
            expect(item).to be_selected_by_subnav
          end
        end

        context 'and no item of the sub_navigation is selected' do
          before do
            sub_navigation.stub(selected?: false, selected_by_condition?: true)
          end

          it 'returns false' do
            expect(item).not_to be_selected_by_subnav
          end
        end
      end

      context "when the item doesn't have any sub_navigation" do
        let(:sub_navigation) { nil }

        it 'returns false' do
          expect(item).not_to be_selected_by_subnav
        end
      end
    end

    describe '#selected_by_condition?' do
      let(:current_url) { '' }

      before { adapter.stub(request_uri: current_url) }

      context 'when the :highlights_on option is set' do
        before { item.stub(highlights_on: /^\/matching/) }

        context 'and :highlights_on is a regexp' do
          context 'and it matches the current url' do
            let(:current_url) { '/matching_url' }

            it 'returns true' do
              expect(item).to be_selected_by_condition
            end
          end

          context "and it doesn't match current url" do
            let(:current_url) { '/other_url' }

            it 'returns false' do
              expect(item).not_to be_selected_by_condition
            end
          end
        end

        context 'and :highlights_on is a lambda' do
          context 'and it is truthy' do
            before { item.stub(highlights_on: ->{ true }) }

            it 'returns true' do
              expect(item).to be_selected_by_condition
            end
          end

          context 'falsey lambda results in no selection' do
            before { item.stub(highlights_on: ->{ false }) }

            it 'returns false' do
              expect(item).not_to be_selected_by_condition
            end
          end
        end

        context 'and :highlights_on is :subpath' do
          before { item.stub(url: '/path', highlights_on: :subpath) }

          context "and the current url is a sub path of the item's url" do
            let(:current_url) { '/path/sub-path' }

            it 'returns true' do
              expect(item).to be_selected_by_condition
            end
          end

          context "and the current url starts with item's url" do
            let(:current_url) { '/path_group/id' }

            it 'returns false' do
              expect(item).not_to be_selected_by_condition
            end
          end

          context "and the current url is totally different from the item's url" do
            let(:current_url) { '/other_path/id' }

            it 'returns false' do
              expect(item).not_to be_selected_by_condition
            end
          end
        end

        context 'when :highlights_on something else' do
          before { item.stub(highlights_on: 'nothing') }

          it 'raises an exception' do
            expect{ item.send(:selected_by_condition?) }.to raise_error
          end
        end
      end

      context 'when :auto_highlight is true' do
        before { item.stub(auto_highlight?: true) }

        context 'and root path matches' do
          before { item.stub(root_path_match?: true) }

          it 'returns true' do
            expect(item).to be_selected_by_condition
          end
        end

        context "and root path doesn't match" do
          before { item.stub(root_path_match?: false) }

          context "and the current url matches the item's url" do
            let(:url) { 'url#anchor' }

            before { adapter.stub(current_page?: true) }

            it 'returns true' do
              expect(item).to be_selected_by_condition
            end

            # FIXME: testing the implementation not the behavior here
            it "removes anchors before testing the item's url" do
              expect(adapter).to receive(:current_page?).with('url')
              item.send(:selected_by_condition?)
            end

            context 'when url is nil' do
              let(:url) { nil }

              it "doesn't check the url" do
                expect(adapter).not_to receive(:current_page?)
                item.send(:selected_by_condition?)
              end
            end
          end

          context "and the current url doesn't match the item's url" do
            before { adapter.stub(current_page?: false) }

            it 'returns false' do
              expect(item).not_to be_selected_by_condition
            end
          end
        end
      end

      context 'when :auto_highlight is false' do
        before { item.stub(auto_highlight?: false) }

        it 'returns false' do
          expect(item).not_to be_selected_by_condition
        end
      end
    end

    describe '#root_path_match?' do
      context "when current url is /" do
        before { adapter.stub(request_path: '/') }

        context "and the item's url is /" do
          let(:url) { '/' }

          it 'returns true' do
            expect(item.send(:root_path_match?)).to be_true
          end
        end

        context "and the item's url isn't /" do
          let(:url) { '/other' }

          it 'returns false' do
            expect(item.send(:root_path_match?)).to be_false
          end
        end
      end

      context "when current url isn't /" do
        before { adapter.stub(request_path: '/other') }

        context "and the item's url is /" do
          let(:url) { '/' }

          it 'returns false' do
            expect(item.send(:root_path_match?)).to be_false
          end
        end

        context "and the item's url is nil" do
          let(:url) { nil }

          it 'returns false' do
            expect(item.send(:root_path_match?)).to be_false
          end
        end
      end

      context "when current url doesn't match the item's url" do
        let(:url) { '/path' }

        before { adapter.stub(request_path: '/other') }

        it 'returns false' do
          expect(item.send(:root_path_match?)).to be_false
        end
      end

      context "when current url doesn't match the item's url" do
        let(:url) { nil }

        before { adapter.stub(request_path: '/other') }

        it 'returns false' do
          expect(item.send(:root_path_match?)).to be_false
        end
      end
    end

    describe '#auto_highlight?' do
      let(:global) { double(:config) }

      before { SimpleNavigation.stub(config: global) }

      context 'when :auto_highlight is globally true' do
        before { global.stub(auto_highlight: true) }

        context "and container's :auto_highlight is true" do
          before { item_container.stub(auto_highlight: true) }

          it 'returns true' do
            expect(item.send(:auto_highlight?)).to be_true
          end
        end

        context "and container's :auto_highlight is false" do
          before { item_container.stub(auto_highlight: false) }

          it 'returns false' do
            expect(item.send(:auto_highlight?)).to be_false
          end
        end
      end

      context 'when :auto_highlight is globally false' do
        before { global.stub(auto_highlight: false) }

        context 'when :auto_highlight is globally true' do
          before { item_container.stub(auto_highlight: true) }

          it 'returns false' do
            expect(item.send(:auto_highlight?)).to be_false
          end
        end

        context "and container's :auto_highlight is false" do
          before { item_container.stub(auto_highlight: false) }

          it 'returns false' do
            expect(item.send(:auto_highlight?)).to be_false
          end
        end
      end
    end

    describe '#autogenerated_item_id' do
      context 'when no generator is configured' do
        let(:id_generator) { double(:id_generator) }

        before { SimpleNavigation.config.stub(id_generator: id_generator) }

        it 'calls the globally configured id generator' do
          expect(id_generator).to receive(:call).with(:my_key)
          item.send(:autogenerated_item_id)
        end
      end

      context 'when no generator is configured' do
        it 'uses the default generator' do
          expect(item.send(:autogenerated_item_id)).to eq 'my_key'
        end
      end
    end
  end
end
