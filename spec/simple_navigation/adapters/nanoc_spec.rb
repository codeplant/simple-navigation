# frozen_string_literal: true

# NOTE: This adapter is deprecated. It supports Nanoc3 (circa 2011-2012) which is obsolete.
# These tests are maintained for backward compatibility only.
RSpec.describe SimpleNavigation::Adapters::Nanoc do
  let(:adapter) { described_class.new(context) }
  let(:context) { double(:context, item: item) }
  let(:item) { double(:item, path: '/test/path/') }

  describe '.register' do
    let(:nanoc_context) { double(:nanoc_context) }

    before do
      stub_const('Nanoc3::Context', nanoc_context)
      allow(SimpleNavigation).to receive(:set_env)
      allow(nanoc_context).to receive(:include)
    end

    it 'calls SimpleNavigation.set_env with root and development environment' do
      expect(SimpleNavigation).to receive(:set_env).with('/root/path', 'development')
      described_class.register('/root/path')
    end

    it 'includes SimpleNavigation::Helpers in Nanoc3::Context' do
      expect(nanoc_context).to receive(:include).with(SimpleNavigation::Helpers)
      described_class.register('/root/path')
    end
  end

  describe '#initialize' do
    it 'sets the context' do
      expect(adapter.instance_variable_get(:@context)).to eq context
    end
  end

  describe '#context_for_eval' do
    it 'returns the context' do
      expect(adapter.context_for_eval).to eq context
    end
  end

  describe '#current_page?' do
    context 'when the path matches the url (after chomping the trailing slash)' do
      it 'returns true' do
        expect(adapter.current_page?('/test/path')).to be true
      end
    end

    context 'when the path does not match the url' do
      it 'returns false' do
        expect(adapter.current_page?('/other/path')).to be false
      end
    end

    context 'when path is nil' do
      let(:item) { double(:item, path: nil) }

      it 'returns nil' do
        expect(adapter.current_page?('/test/path')).to be_nil
      end
    end
  end

  describe '#link_to' do
    it 'returns a link with the correct attributes' do
      link = adapter.link_to('Test Link', '/url', class: 'nav-link', id: 'link1')
      expect(link).to eq "<a href='/url' class='nav-link' id='link1'>Test Link</a>"
    end

    it 'handles options without values' do
      link = adapter.link_to('Test', '/url', {})
      expect(link).to eq "<a href='/url' >Test</a>"
    end

    it 'filters out nil values' do
      link = adapter.link_to('Test', '/url', class: 'nav', id: nil)
      expect(link).to eq "<a href='/url' class='nav'>Test</a>"
    end
  end

  describe '#content_tag' do
    it 'returns a tag with the correct type, content and attributes' do
      tag = adapter.content_tag(:div, 'Content', class: 'container', id: 'main')
      expect(tag).to eq "<div class='container' id='main'>Content</div>"
    end

    it 'handles tags without attributes' do
      tag = adapter.content_tag(:span, 'Text', {})
      expect(tag).to eq '<span >Text</span>'
    end

    it 'filters out nil values from attributes' do
      tag = adapter.content_tag(:p, 'Paragraph', class: 'text', id: nil)
      expect(tag).to eq "<p class='text'>Paragraph</p>"
    end
  end
end
