# frozen_string_literal: true

RSpec.describe SimpleNavigation do
  subject(:simple_navigation) { described_class }

  before { simple_navigation.config_file_path = 'path_to_config' }

  describe 'config_file_path=' do
    before { simple_navigation.config_file_paths = ['existing_path'] }

    it 'overrides the config_file_paths' do
      simple_navigation.config_file_path = 'new_path'
      expect(simple_navigation.config_file_paths).to eq ['new_path']
    end
  end

  describe '.default_config_file_path' do
    before { allow(simple_navigation).to receive_messages(root: 'root') }

    it 'returns the config file path according to :root setting' do
      expect(simple_navigation.default_config_file_path).to eq 'root/config'
    end
  end

  describe 'Regarding renderers' do
    it 'registers the builtin renderers by default' do
      expect(simple_navigation.registered_renderers).not_to be_empty
    end

    describe '.register_renderer' do
      let(:renderer) { double(:renderer) }

      it 'adds the specified renderer to the list of renderers' do
        simple_navigation.register_renderer(my_renderer: renderer)
        expect(simple_navigation.registered_renderers[:my_renderer]).to be renderer
      end
    end
  end

  describe '.set_env' do
    before do
      simple_navigation.config_file_paths = []
      allow(simple_navigation).to receive_messages(default_config_file_path: 'default_path')
      simple_navigation.set_env('root', 'my_env')
    end

    it 'sets the root' do
      expect(simple_navigation.root).to eq 'root'
    end

    it 'sets the environment' do
      expect(simple_navigation.environment).to eq 'my_env'
    end

    it 'adds the default-config path to the list of config_file_paths' do
      expect(simple_navigation.config_file_paths).to eq ['default_path']
    end
  end

  describe '.load_config', :memfs do
    let(:paths) { ['/path/one', '/path/two'] }

    before do
      FileUtils.mkdir_p(paths)
      allow(simple_navigation).to receive_messages(config_file_paths: paths)
    end

    context 'when the config file for the context exists' do
      before do
        File.open('/path/two/navigation.rb', 'w') { |f| f.puts 'default content' }
        File.open('/path/one/other_navigation.rb', 'w') { |f| f.puts 'other content' }
      end

      context 'when no context is provided' do
        it 'stores the configuration in config_files for the default context' do
          simple_navigation.load_config
          expect(simple_navigation.config_files[:default]).to eq "default content\n"
        end
      end

      context 'when a context is provided' do
        it 'stores the configuration in config_files for the given context' do
          simple_navigation.load_config(:other)
          expect(simple_navigation.config_files[:other]).to eq "other content\n"
        end
      end

      context 'when environment is production' do
        before { allow(simple_navigation).to receive_messages(environment: 'production') }

        it 'loads the config file only for the first call' do
          simple_navigation.load_config
          File.open('/path/two/navigation.rb', 'w') { |f| f.puts 'new content' }
          simple_navigation.load_config
          expect(simple_navigation.config_files[:default]).to eq "default content\n"
        end
      end

      context "when environment isn't production" do
        it 'loads the config file for every call' do
          simple_navigation.load_config
          File.open('/path/two/navigation.rb', 'w') { |f| f.puts 'new content' }
          simple_navigation.load_config
          expect(simple_navigation.config_files[:default]).to eq "new content\n"
        end
      end
    end

    context "when the config file for the context doesn't exists" do
      it 'raises an exception' do
        expect do
          simple_navigation.load_config
        end.to raise_error(RuntimeError, /Config file 'navigation.rb' not found in path\(s\)/)
      end
    end
  end

  describe '.config' do
    it 'returns the Configuration singleton instance' do
      expect(simple_navigation.config).to be SimpleNavigation::Configuration.instance
    end
  end

  describe '.active_item_container_for' do
    let(:primary) { double(:primary) }

    before { allow(simple_navigation.config).to receive_messages(primary_navigation: primary) }

    context 'when level is :all' do
      it 'returns the primary_navigation' do
        nav = simple_navigation.active_item_container_for(:all)
        expect(nav).to be primary
      end
    end

    context 'when level is :leaves' do
      it 'returns the currently active leaf-container' do
        expect(primary).to receive(:active_leaf_container)
        simple_navigation.active_item_container_for(:leaves)
      end
    end

    context 'when level is a Range' do
      it 'takes the min of the range to lookup the active container' do
        expect(primary).to receive(:active_item_container_for).with(2)
        simple_navigation.active_item_container_for(2..3)
      end
    end

    context 'when level is an Integer' do
      it 'considers the Integer to lookup the active container' do
        expect(primary).to receive(:active_item_container_for).with(1)
        simple_navigation.active_item_container_for(1)
      end
    end

    context 'when level is something else' do
      it 'raises an exception' do
        expect do
          simple_navigation.active_item_container_for('something else')
        end.to raise_error(ArgumentError, 'Invalid navigation level: something else')
      end
    end
  end

  describe '.load_adapter' do
    shared_examples 'loading the right adapter' do |framework, adapter|
      context "when the context is #{framework}" do
        before do
          allow(simple_navigation).to receive_messages(framework: framework)
          simple_navigation.load_adapter
        end

        it "returns the #{framework} adapter" do
          adapter_class = SimpleNavigation::Adapters.const_get(adapter)
          expect(simple_navigation.adapter_class).to be adapter_class
        end
      end
    end

    it_behaves_like 'loading the right adapter', :rails,   :Rails
    it_behaves_like 'loading the right adapter', :padrino, :Padrino
    it_behaves_like 'loading the right adapter', :sinatra, :Sinatra
    it_behaves_like 'loading the right adapter', :nanoc,   :Nanoc
  end

  describe '.init_adapter_from' do
    let(:adapter) { double(:adapter) }
    let(:adapter_class) { double(:adapter_class, new: adapter) }

    it 'sets the adapter to a new instance of adapter_class' do
      simple_navigation.adapter_class = adapter_class
      simple_navigation.init_adapter_from(:default)
      expect(simple_navigation.adapter).to be adapter
    end
  end
end
