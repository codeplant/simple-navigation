require File.dirname(__FILE__) + '/../../spec_helper'

describe SimpleNavigation::Item do

  before(:each) do
    @item_container = stub(:item_container, :level => 1)
    @item = SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', {})
  end

  describe 'initialize' do
    context 'subnavigation' do
      before(:each) do
        @subnav_container = stub(:subnav_container, :null_object => true)
        SimpleNavigation::ItemContainer.stub!(:new => @subnav_container)
      end
      context 'block given' do
        it "should create a new ItemContainer with a level+1" do
          SimpleNavigation::ItemContainer.should_receive(:new).with(2)
          SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', {}) {}
        end
        it "should call the block" do
          @subnav_container.should_receive(:test)
          SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', {}) {|subnav| subnav.test}
        end
      end
      context 'no block given' do
        context 'items given' do
          before(:each) do
            @items = stub(:items)
          end
          it "should create a new ItemContainer with a level+1" do
            SimpleNavigation::ItemContainer.should_receive(:new).with(2)
            SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', {}, @items)
          end
          it "should set the items on the subnav_container" do
            @subnav_container.should_receive(:items=).with(@items)
            SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', {}, @items)
          end
        end
        context 'no items given' do
          it "should not create a new ItemContainer" do
            SimpleNavigation::ItemContainer.should_not_receive(:new)
            @item = SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', {})
          end
        end
      end
    end
    context 'method' do
      context 'defined' do
        before(:each) do
          @options = {:method => :delete}
          @item = SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', @options)
        end
        it 'should set the method as instance_var' do
          @item.method.should == :delete
        end
        it 'should set the html-options without the method' do
          @item.instance_variable_get(:@html_options).key?(:method).should be_false
        end
      end
      
      context 'undefined' do
        it 'should set the instance-var to nil' do
          @item.method.should be_nil
        end
      end
    end
  end
  
  describe 'selected?' do
    context 'explicitly selected' do
      before(:each) do
        @item.stub!(:selected_by_config? => true)
      end
      it {@item.should be_selected}
      it "should not evaluate the subnav or urls" do
        @item.should_not_receive(:selected_by_subnav?)
        @item.should_not_receive(:selected_by_url?)
        @item.selected?
      end
    end
    context 'not explicitly selected' do
      before(:each) do
        @item.stub!(:selected_by_config? => false)
      end
      context 'subnav is selected' do
        before(:each) do
          @item.stub!(:selected_by_subnav? => true)
        end
        it {@item.should be_selected}
      end
      context 'subnav is not selected' do
        before(:each) do
           @item.stub!(:selected_by_subnav? => false)
        end
        context 'selected by url' do
          before(:each) do
             @item.stub!(:selected_by_url? => true)
          end
          it {@item.should be_selected}
        end
        context 'not selected by url' do
          before(:each) do
            @item.stub!(:selected_by_url? => false)
          end
          it {@item.should_not be_selected}
        end
      end
    end
  end
  
  describe 'selected_class' do
    context 'item is selected' do
      before(:each) do
        @item.stub!(:selected? => true)
      end
      it {@item.instance_eval {selected_class.should == 'selected'}}
    end
    
    context 'item is not selected' do
      before(:each) do
        @item.stub!(:selected? => false)
      end
      it {@item.instance_eval {selected_class.should == nil}}
    end
  end
  
  describe 'html_options' do
    describe 'class' do
      context 'with classes defined in options' do
        before(:each) do
          @options = {:class => 'my_class'}
          @item = SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', @options)
        end
        context 'with item selected' do
          before(:each) do
            @item.stub!(:selected? => true)
          end
          it {@item.html_options[:class].should == 'my_class selected'}
        end
      
        context 'with item not selected' do
          before(:each) do
            @item.stub!(:selected? => false)
          end
          it {@item.html_options[:class].should == 'my_class'}
        end
      end
    
      context 'without classes in options' do
        before(:each) do
          @options = {}
          @item = SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', @options)
        end
        context 'with item selected' do
          before(:each) do
            @item.stub!(:selected? => true)
          end
          it {@item.html_options[:class].should == 'selected'}
        end
      
        context 'with item not selected' do
          before(:each) do
            @item.stub!(:selected? => false)
          end
          it {@item.html_options[:class].should be_blank}
        end
      end
    end
    
    describe 'id' do
      context 'with autogenerate_item_ids == true' do
        before(:each) do
          @item.stub!(:autogenerate_item_ids? => true)
          @item.stub!(:selected? => false)
        end
        context 'with id defined in options' do
          before(:each) do
            @item.html_options = {:id => 'my_id'}
          end
          it {@item.html_options[:id].should == 'my_id'}
        end
      
        context 'with no id definied in options (using default id)' do
          before(:each) do
            @item.html_options = {}
          end
          it {@item.html_options[:id].should == 'my_key'}
        end
      end

      context 'with autogenerate_item_ids == false' do
        before(:each) do
          @item.stub!(:autogenerate_item_ids? => false)
          @item.stub!(:selected? => false)
        end
        context 'with id defined in options' do
          before(:each) do
            @item.html_options = {:id => 'my_id'}
          end
          it {@item.html_options[:id].should == 'my_id'}
        end
      
        context 'with no id definied in options (using default id)' do
          before(:each) do
            @item.html_options = {}
          end
          it {@item.html_options[:id].should be_nil}
        end
     
      end

    end
        
  end

  describe 'selected_by_subnav?' do
    context 'item has subnav' do
      before(:each) do
        @sub_navigation = stub(:sub_navigation)
        @item.stub!(:sub_navigation => @sub_navigation)
      end
      it "should return true if subnav is selected" do
        @sub_navigation.stub!(:selected? => true)
        @item.should be_selected_by_subnav
      end
      it "should return false if subnav is not selected" do
        @sub_navigation.stub!(:selected? => false)
        @item.should_not be_selected_by_subnav
      end
    end
    context 'item does not have subnav' do
      before(:each) do
        @item.stub!(:sub_navigation => @sub_navigation)
      end
      it {@item.should_not be_selected_by_subnav}
    end
  end

  describe 'selected_by_config?' do
    context 'navigation explicitly set' do
      it "should return true if current matches key" do
        @item_container.stub!(:current_explicit_navigation => :my_key)
        @item.should be_selected_by_config
      end
      it "should return false if current does not match key" do
        @item_container.stub!(:current_explicit_navigation => :other_key)
        @item.should_not be_selected_by_config
      end
    end
    context 'navigation not explicitly set' do
      before(:each) do
        @item_container.stub!(:current_explicit_navigation => nil)
      end
      it {@item.should_not be_selected_by_config}
    end
  end

  describe 'selected_by_url?' do
    context 'auto_highlight is turned on' do
      before(:each) do
        @item.stub!(:auto_highlight? => true)
      end
      context 'root path matches' do
        before(:each) do
          @item.stub!(:root_path_match? => true)
        end
        it {@item.send(:selected_by_url?).should be_true}
      end
      context 'root path does not match' do
        before(:each) do
          @item.stub!(:root_path_match? => false)
        end
        context 'template is set' do
          before(:each) do
            @template = stub(:template)
            SimpleNavigation.stub!(:template => @template)
          end
          context 'current request url matches url' do
            before(:each) do
              @template.stub!(:current_page? => true)
            end
            it "should test with the item's url" do
              @template.should_receive(:current_page?).with('url')
              @item.send(:selected_by_url?)
            end
            it {@item.send(:selected_by_url?).should be_true}
          end
          context 'no match' do
            before(:each) do
              @template.stub!(:current_page? => false)
            end
            it {@item.send(:selected_by_url?).should be_false}
          end
        end
        context 'template is not set' do
          before(:each) do
            SimpleNavigation.stub!(:template => nil)
          end
          it {@item.send(:selected_by_url?).should be_false}
        end
      end
    end
    context 'auto_highlight is turned off' do
      before(:each) do
        @item.stub!(:auto_highlight? => false)
      end
      it {@item.send(:selected_by_url?).should be_false}
    end
  end

  describe 'root_path_match?' do
    before(:each) do
      @request = stub(:request)
      @controller = stub(:controller, :request => @request)
      SimpleNavigation.stub!(:controller => @controller)
    end
    it "should match if both url == /" do
      @request.stub!(:path => '/')
      @item.stub!(:url => '/')
      @item.send(:root_path_match?).should be_true
    end
    it "should not match if item url is not /" do
      @request.stub!(:path => '/')
      @item.stub!(:url => '/bla')
      @item.send(:root_path_match?).should be_false
    end
    it "should not match if request url is not /" do
      @request.stub!(:path => '/bla')
      @item.stub!(:url => '/')
      @item.send(:root_path_match?).should be_false
    end
    it "should not match if urls do not match" do
      @request.stub!(:path => '/bla')
      @item.stub!(:url => '/bli')
      @item.send(:root_path_match?).should be_false
    end
  end

  describe 'auto_highlight?' do
    before(:each) do
      @global = stub(:config)
      SimpleNavigation.stub!(:config => @global)
    end
    context 'global auto_highlight on' do
      before(:each) do
        @global.stub!(:auto_highlight => true)
      end
      context 'container auto_highlight on' do
        before(:each) do
          @item_container.stub!(:auto_highlight => true)
        end
        it {@item.send(:auto_highlight?).should be_true}
      end
      context 'container auto_highlight off' do
        before(:each) do
          @item_container.stub!(:auto_highlight => false)
        end
        it {@item.send(:auto_highlight?).should be_false}
      end
    end
    context 'global auto_highlight off' do
      before(:each) do
        @global.stub!(:auto_highlight => false)
      end
      context 'container auto_highlight on' do
        before(:each) do
          @item_container.stub!(:auto_highlight => true)
        end
        it {@item.send(:auto_highlight?).should be_false}
      end
      context 'container auto_highlight off' do
        before(:each) do
          @item_container.stub!(:auto_highlight => false)
        end
        it {@item.send(:auto_highlight?).should be_false}
      end
    end
  end

  describe 'autogenerated_item_id' do
    context 'calls' do
      before(:each) do
        @id_generator = stub(:id_generator)
        SimpleNavigation.config.stub!(:id_generator => @id_generator)
      end
      it "should call the configured generator with the key as param" do
        @id_generator.should_receive(:call).with(:my_key)
        @item.send(:autogenerated_item_id)
      end
    end
    context 'default generator' do
      it {@item.send(:autogenerated_item_id).should == 'my_key'}
    end
  end

end
