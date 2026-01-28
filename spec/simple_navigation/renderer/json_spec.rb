RSpec.describe SimpleNavigation::Renderer::Json do
  describe '#render' do
    let!(:navigation) { setup_navigation('nav_id', 'nav_class') }

    let(:item) { :invoices }
    let(:options) {{ level: :all }}
    let(:output) { renderer.render(navigation) }
    let(:parsed_output) { JSON.parse(output) }
    let(:renderer) { SimpleNavigation::Renderer::Json.new(options) }

    before { select_an_item(navigation[item]) if item }

    context 'when an item is selected' do

      it 'renders the selected page' do
        invoices_item = parsed_output.find { |item| item['name'] == 'Invoices' }
        expect(invoices_item).to include('selected' => true)
      end
    end

    context 'when the :as_hash option is true' do
      let(:options) {{ level: :all, as_hash: true }}

      it 'returns every item as a hash' do
        expect(output).to be_an Array

        output.each do |item|
          expect(item).to be_an Hash
        end
      end

      it 'renders the selected page' do
        invoices_item = output.find { |item| item[:name] == 'Invoices' }
        expect(invoices_item).to include(selected: true)
      end
    end

    context 'with options' do
      it 'should render options for each item' do
        parsed_output.each do |item|
          expect(item).to have_key('options')
        end
      end
    end

    context 'when a sub navigation item is selected' do
      let(:invoices_item) do
        parsed_output.find { |item| item['name'] == 'Invoices' }
      end
      let(:unpaid_item) do
        invoices_item['items'].find { |item| item['name'] == 'Unpaid' }
      end

      before do
        allow(navigation[:invoices]).to receive_messages(selected?: true)

        allow(navigation[:invoices].sub_navigation[:unpaid]).to \
          receive_messages(selected?: true, selected_by_condition?: true)
      end

      it 'marks all the parent items as selected' do
        expect(invoices_item).to include('selected' => true)
      end

      it 'marks the item as selected' do
        expect(unpaid_item).to include('selected' => true)
      end
    end
  end
end
