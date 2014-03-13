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

        shared_examples 'creating sub navigation container' do
          it 'creates a sub navigation container with a level+1' do
            expect(item.sub_navigation.level).to eq 2
          end
        end

        context 'when a block is given' do
          it_behaves_like 'creating sub navigation container' do
            let(:item) { Item.new(*item_args) {} }
          end

          it 'calls the block' do
            ItemContainer.stub(new: subnav_container)

            expect{ |blk|
              Item.new(*item_args, &blk)
            }.to yield_with_args(subnav_container)
          end
        end

        context 'when no block is given' do
          context 'and items are given' do
            let(:items) { [] }

            it_behaves_like 'creating sub navigation container'

            it "sets the items on the subnav_container" do
              expect(item.sub_navigation.items).to eq items
            end
          end

          context 'and no items are given' do
            it "doesn't create a new ItemContainer" do
              item = Item.new(*item_args)
              expect(item.sub_navigation).to be_nil
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

      context 'when no :highlights_on option is given' do
        it "sets the item's highlights_on to nil" do
          expect(item.highlights_on).to be_nil
        end
      end

      context 'when an :highlights_on option is given' do
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

      context 'when no url nor options is specified' do
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

      context 'when the :container_id option is given' do
        let(:options) {{ container_id: 'c_id' }}

        it "sets the id on the item's container" do
          Item.new(*item_args)
          expect(item_container.dom_id).to eq 'c_id'
        end
      end

      context 'when the :container_class option is given' do
        let(:options) {{ container_class: 'c_class' }}

        it "sets the class on the item's container" do
          Item.new(*item_args)
          expect(item_container.dom_class).to eq 'c_class'
        end
      end

      context 'when the :container_attributes option is given' do
        let(:options) {{ container_attributes: { attr: true } }}

        it "sets the dom attributes on the item's container" do
          Item.new(*item_args)
          expect(item_container.dom_attributes).to include(attr: true)
        end
      end

      context 'when the :selected_class option is given' do
        let(:options) {{ selected_class: 'sel_class' }}

        it "sets the selected_class on the item's container" do
          Item.new(*item_args)
          expect(item_container.selected_class).to eq 'sel_class'
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
      context "when the item isn't selected" do
        before { adapter.stub(current_page?: false) }

        it 'returns false' do
          expect(item).not_to be_selected
        end
      end

      describe 'selectible by condition' do
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
              expect{ item.selected? }.to raise_error
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

              context 'when url is nil' do
                let(:url) { nil }

                it 'returns false' do
                  expect(item.selected?).to be_false
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

      describe 'selectible by sub navigation' do
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
          SimpleNavigation.config.stub(autogenerate_item_ids: generate_ids)
          item.stub(selected?: false, selected_by_condition?: false)
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
          SimpleNavigation.config.stub(autogenerate_item_ids: generate_ids)
          item.stub(selected?: false, selected_by_condition?: false)
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
  end
end
