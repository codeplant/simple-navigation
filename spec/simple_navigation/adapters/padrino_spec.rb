# frozen_string_literal: true

RSpec.describe SimpleNavigation::Adapters::Padrino do
  let(:adapter) { described_class.new(context) }
  let(:content) { double(:content) }
  let(:context) { double(:context, request: request) }
  let(:request) { double(:request) }

  describe '.register' do
    let(:padrino_module) { Module.new }
    let(:padrino_application) { Module.new }

    before do
      stub_const('Padrino', padrino_module)
      stub_const('Padrino::Application', padrino_application)
      allow(padrino_module).to receive_messages(root: '/padrino/root', env: 'production')
      allow(SimpleNavigation).to receive(:set_env)
      allow(padrino_application).to receive(:send)
    end

    it 'calls SimpleNavigation.set_env with Padrino root and env' do
      expect(SimpleNavigation).to receive(:set_env).with('/padrino/root', 'production')
      described_class.register(nil)
    end

    it 'includes SimpleNavigation::Helpers in Padrino::Application' do
      expect(padrino_application).to receive(:send).with(:helpers, SimpleNavigation::Helpers)
      described_class.register(nil)
    end
  end

  describe '#link_to' do
    it 'delegates to context' do
      expect(context).to receive(:link_to).with('name', 'url', { my_option: true })
      adapter.link_to('name', 'url', my_option: true)
    end
  end

  describe '#content_tag' do
    it 'delegates to context' do # rubocop:disable RSpec/MultipleExpectations
      expect(content).to receive(:html_safe).and_return('content') # rubocop:disable RSpec/StubbedMock
      expect(context).to receive(:content_tag).with('type', 'content', { my_option: true })
      adapter.content_tag('type', content, my_option: true)
    end
  end
end
