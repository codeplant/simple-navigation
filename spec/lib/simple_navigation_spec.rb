require 'spec_helper'

describe SimpleNavigation do
  before { subject.config_file_path = 'path_to_config' }

  describe 'config_file_name' do
    context 'when the navigation_context is :default' do
      it 'returns the name of the default config file' do
        expect(subject.config_file_name).to eq 'navigation.rb'
      end
    end

    context 'when the navigation_context is NOT :default' do
      it 'returns the name of the config file matching the specified context' do
        file_name = subject.config_file_name(:my_other_context)
        expect(file_name).to eq 'my_other_context_navigation.rb'
      end

      it 'converts camelcase-contexts to underscore' do
        file_name = subject.config_file_name(:WhyWouldYouDoThis)
        expect(file_name).to eq 'why_would_you_do_this_navigation.rb'
      end
    end
  end

  describe 'config_file_path=' do
    before { subject.config_file_paths = ['existing_path'] }

    it 'overrides the config_file_paths' do
      subject.config_file_path = 'new_path'
      expect(subject.config_file_paths).to eq ['new_path']
    end
  end

  describe 'config_file' do
    context 'when no config_file_paths are set' do
      before { subject.config_file_paths = [] }

      it 'returns nil' do
        expect(subject.config_file).to be_nil
      end
    end

    context 'when one config_file_path is set' do
      before { subject.config_file_paths = ['my_config_file_path'] }

      context 'and the requested config file exists' do
        before { File.stub(exist?: true) }

        it 'returns the path to the config_file' do
          expect(subject.config_file).to eq 'my_config_file_path/navigation.rb'
        end
      end

      context 'and the requested config file does not exist' do
        before { File.stub(exist?: false) }

        it 'returns nil' do
          expect(subject.config_file).to be_nil
        end
      end
    end

    context 'when multiple config_file_paths are set' do
      before { subject.config_file_paths = ['first_path', 'second_path'] }

      context 'and the requested config file exists' do
        before { File.stub(exist?: true) }

        it 'returns the path to the first matching config_file' do
          expect(subject.config_file).to eq 'first_path/navigation.rb'
        end
      end

      context 'and the requested config file does not exist' do
        before { File.stub(exist?: false) }

        it 'returns nil' do
          expect(subject.config_file).to be_nil
        end
      end
    end
  end

  describe '.config_file?' do
    context 'when config_file is present' do
      before { subject.stub(config_file: 'file') }

      it 'returns true' do
        expect(subject.config_file?).to be_truthy
      end
    end

    context 'when config_file is not present' do
      before { subject.stub(config_file: nil) }

      it 'returns false' do
        expect(subject.config_file?).to be_falsey
      end
    end
  end

  describe '.default_config_file_path' do
    before { subject.stub(root: 'root') }

    it 'returns the config file path according to :root setting' do
      expect(subject.default_config_file_path).to eq 'root/config'
    end
  end

  describe 'Regarding renderers' do
    it 'registers the builtin renderers by default' do
      expect(subject.registered_renderers).not_to be_empty
    end

    describe '.register_renderer' do
      let(:renderer) { double(:renderer) }

      it 'adds the specified renderer to the list of renderers' do
        subject.register_renderer(my_renderer: renderer)
        expect(subject.registered_renderers[:my_renderer]).to be renderer
      end
    end
  end

  describe '.set_env' do
    before do
      subject.config_file_paths = []
      subject.stub(default_config_file_path: 'default_path')
      subject.set_env('root', 'my_env')
    end

    it 'sets the root' do
      expect(subject.root).to eq 'root'
    end

    it 'sets the environment' do
      expect(subject.environment).to eq 'my_env'
    end

    it 'adds the default-config path to the list of config_file_paths' do
      expect(subject.config_file_paths).to eq ['default_path']
    end
  end

  describe '.load_config' do
    context 'when config_file_path is set' do
      before { subject.stub(config_file: 'path_to_config_file') }

      context 'and config_file exists' do
        before do
          subject.stub(config_file?: true)
          IO.stub(read: 'file_content')
        end

        it "doesn't raise any error" do
          expect{ subject.load_config }.not_to raise_error
        end

        it 'reads the specified config file from disc' do
          expect(IO).to receive(:read).with('path_to_config_file')
          subject.load_config
        end

        it 'stores the read content in the module (default context)' do
          expect(subject).to receive(:config_file).with(:default)
          subject.load_config
          expect(subject.config_files[:default]).to eq 'file_content'
        end

        it 'stores the content in the module (non default context)' do
          expect(subject).to receive(:config_file).with(:my_context)
          subject.load_config(:my_context)
          expect(subject.config_files[:my_context]).to eq 'file_content'
        end
      end

      context 'and config_file does not exist' do
        before { subject.stub(config_file?: false) }

        it 'raises an exception' do
        expect{ subject.load_config }.to raise_error
        end
      end
    end

    context 'when config_file_path is not set' do
      before { subject.config_file_path = nil }

      it 'raises an exception' do
        expect{ subject.load_config }.to raise_error
      end
    end

    describe 'Regarding caching of the config-files' do
      before do
        subject.config_file_path = 'path_to_config'
        IO.stub(:read).and_return('file_content')
        File.stub(exist?: true)
      end

      after { subject.config_files = {} }

      shared_examples 'loading config file' do |env, count|
        context "when environment is '#{env}'" do
          before { subject.stub(environment: env) }

          it "loads the config file #{count}" do
            expect(IO).to receive(:read).exactly(count)
            2.times { subject.load_config }
          end
        end
      end

      it_behaves_like 'loading config file', nil,           :twice
      it_behaves_like 'loading config file', 'production',  :once
      it_behaves_like 'loading config file', 'development', :twice
      it_behaves_like 'loading config file', 'test',        :twice
    end
  end

  describe '.config' do
    it 'returns the Configuration singleton instance' do
      expect(subject.config).to be SimpleNavigation::Configuration.instance
    end
  end

  describe '.active_item_container_for' do
    let(:primary) { double(:primary) }

    before { subject.config.stub(primary_navigation: primary) }

    context 'when level is :all' do
      it 'returns the primary_navigation' do
        nav = subject.active_item_container_for(:all)
        expect(nav).to be primary
      end
    end

    context 'when level is :leaves' do
      it 'returns the currently active leaf-container' do
        expect(primary).to receive(:active_leaf_container)
        subject.active_item_container_for(:leaves)
      end
    end

    context 'when level is a Range' do
      it 'takes the min of the range to lookup the active container' do
        expect(primary).to receive(:active_item_container_for).with(2)
        subject.active_item_container_for(2..3)
      end
    end

    context 'when level is an Integer' do
      it 'considers the Integer to lookup the active container' do
        expect(primary).to receive(:active_item_container_for).with(1)
        subject.active_item_container_for(1)
      end
    end

    context 'when level is something else' do
      it 'raises an exception' do
        expect{
          subject.active_item_container_for('something else')
        }.to raise_error
      end
    end
  end

  describe '.load_adapter' do
    shared_examples 'loading the right adapter' do |framework, adapter|
      context "when the context is #{framework}" do
        before do
          subject.stub(framework: framework)
          subject.load_adapter
        end

        it "returns the #{framework} adapter" do
          adapter_class = SimpleNavigation::Adapters.const_get(adapter)
          expect(subject.adapter_class).to be adapter_class
        end
      end
    end

    it_behaves_like 'loading the right adapter', :rails,   :Rails
    it_behaves_like 'loading the right adapter', :padrino, :Padrino
    it_behaves_like 'loading the right adapter', :sinatra, :Sinatra
  end

  describe '.init_adapter_from' do
    let(:adapter) { double(:adapter) }
    let(:adapter_class) { double(:adapter_class, new: adapter) }

    it 'sets the adapter to a new instance of adapter_class' do
      subject.adapter_class = adapter_class
      subject.init_adapter_from(:default)
      expect(subject.adapter).to be adapter
    end
  end
end
