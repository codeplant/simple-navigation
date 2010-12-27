require 'spec_helper'

describe SimpleNavigation::ItemContainer do
  before(:each) do
    @item_container = SimpleNavigation::ItemContainer.new
  end
  describe 'initialize' do
    it "should set the renderer to the globally-configured renderer per default" do
      SimpleNavigation::Configuration.instance.should_receive(:renderer)
      @item_container = SimpleNavigation::ItemContainer.new
    end
    it "should have an empty items-array" do
      @item_container = SimpleNavigation::ItemContainer.new
      @item_container.items.should be_empty
    end
  end

  describe 'items=' do
    before(:each) do
      @item = stub(:item)
      @items = [@item]
      @item_adapter = stub(:item_adapter).as_null_object
      SimpleNavigation::ItemAdapter.stub(:new => @item_adapter)
      @item_container.stub!(:should_add_item? => true)
    end
    it "should wrap each item in an ItemAdapter" do
      SimpleNavigation::ItemAdapter.should_receive(:new)
      @item_container.items = @items
    end
    context 'item should be added' do
      before(:each) do
        @item_container.stub!(:should_add_item? => true)
        @simple_navigation_item = stub(:simple_navigation_item)
        @item_adapter.stub!(:to_simple_navigation_item => @simple_navigation_item)
      end
      it "should convert the item to a SimpleNavigation::Item" do
        @item_adapter.should_receive(:to_simple_navigation_item).with(@item_container)
        @item_container.items = @items
      end
      it "should add the item to the items-collection" do
        @item_container.items.should_receive(:<<).with(@simple_navigation_item)
        @item_container.items = @items
      end
    end
    context 'item should not be added' do
      before(:each) do
        @item_container.stub!(:should_add_item? => false)
      end
      it "should not convert the item to a SimpleNavigation::Item" do
        @item_adapter.should_not_receive(:to_simple_navigation_item)
        @item_container.items = @items
      end
      it "should not add the item to the items-collection" do
        @item_container.items.should_not_receive(:<<)
        @item_container.items = @items
      end
    end
  end

  describe 'selected?' do
    before(:each) do
      @item_1 = stub(:item, :selected? => false)
      @item_2 = stub(:item, :selected? => false)
      @item_container.instance_variable_set(:@items, [@item_1, @item_2])
    end
    it "should return nil if no item is selected" do
      @item_container.should_not be_selected
    end
    it "should return true if one item is selected" do
      @item_1.stub!(:selected? => true)
      @item_container.should be_selected
    end
  end

  describe 'selected_item' do
    before(:each) do
      SimpleNavigation.stub!(:current_navigation_for => :nav)
      @item_container.stub!(:[] => nil)
      @item_1 = stub(:item, :selected? => false)
      @item_2 = stub(:item, :selected? => false)
      @item_container.instance_variable_set(:@items, [@item_1, @item_2])
    end
    context 'navigation not explicitely set' do
      context 'no item selected' do
        it "should return nil" do
          @item_container.selected_item.should be_nil
        end
      end
      context 'one item selected' do
        before(:each) do
          @item_1.stub!(:selected? => true)
        end
        it "should return the selected item" do
          @item_container.selected_item.should == @item_1
        end
      end
    end
  end

  describe 'selected_sub_navigation?' do
    context 'with an item selected' do
      before(:each) do
        @selected_item = stub(:selected_item)
        @item_container.stub!(:selected_item => @selected_item)
      end
      context 'selected item has sub_navigation' do
        before(:each) do
          @sub_navigation = stub(:sub_navigation)
          @selected_item.stub!(:sub_navigation => @sub_navigation)
        end
        it {@item_container.send(:selected_sub_navigation?).should be_true}
      end
      context 'selected item does not have sub_navigation' do
        before(:each) do
          @selected_item.stub!(:sub_navigation => nil)
        end
        it {@item_container.send(:selected_sub_navigation?).should be_false}
      end
    end
    context 'without an item selected' do
      before(:each) do
        @item_container.stub!(:selected_item => nil)
      end
      it {@item_container.send(:selected_sub_navigation?).should be_false}
    end

  end

  describe 'active_item_container_for' do
    context "the desired level is the same as the container's" do
      it {@item_container.active_item_container_for(1).should == @item_container}
    end
    context "the desired level is different than the container's" do
      context 'with no selected subnavigation' do
        before(:each) do
          @item_container.stub!(:selected_sub_navigation? => false)
        end
        it {@item_container.active_item_container_for(2).should be_nil}
      end
      context 'with selected subnavigation' do
        before(:each) do
          @item_container.stub!(:selected_sub_navigation? => true)
          @sub_nav = stub(:sub_nav)
          @selected_item = stub(:selected_item)
          @item_container.stub!(:selected_item => @selected_item)
          @selected_item.stub!(:sub_navigation => @sub_nav)
        end
        it "should call recursively on the sub_navigation" do
          @sub_nav.should_receive(:active_item_container_for).with(2)
          @item_container.active_item_container_for(2)
        end
      end
    end
  end
  
  describe 'active_leaf_container' do
    context 'the current container has a selected subnavigation' do
      before(:each) do
        @item_container.stub!(:selected_sub_navigation? => true)
        @sub_nav = stub(:sub_nav)
        @selected_item = stub(:selected_item)
        @item_container.stub!(:selected_item => @selected_item)
        @selected_item.stub!(:sub_navigation => @sub_nav)
      end
      it "should call recursively on the sub_navigation" do
        @sub_nav.should_receive(:active_leaf_container)
        @item_container.active_leaf_container
      end
    end
    context 'the current container is the leaf already' do
      before(:each) do
        @item_container.stub!(:selected_sub_navigation? => false)
      end
      it "should return itsself" do
        @item_container.active_leaf_container.should == @item_container
      end
    end
  end

  describe 'item' do

    context 'unconditional item' do

      before(:each) do
        @item_container.stub!(:should_add_item?).and_return(true)
        @options = {}
      end

      context 'block given' do
        before(:each) do
          @sub_container = stub(:sub_container)
          SimpleNavigation::ItemContainer.stub!(:new).and_return(@sub_container)
        end

        it "should should yield an new ItemContainer" do
          @item_container.item('key', 'name', 'url', @options) do |container|
            container.should == @sub_container
          end
        end
        it "should create a new Navigation-Item with the given params and the specified block" do
          SimpleNavigation::Item.should_receive(:new).with(@item_container, 'key', 'name', 'url', @options, nil, &@proc)
          @item_container.item('key', 'name', 'url', @options, &@proc)
        end
        it "should add the created item to the list of items" do
          @item_container.items.should_receive(:<<)
          @item_container.item('key', 'name', 'url', @options) {}
        end
      end

      context 'no block given' do
        it "should create a new Navigation_item with the given params and nil as sub_navi" do
          SimpleNavigation::Item.should_receive(:new).with(@item_container, 'key', 'name', 'url', @options, nil)
          @item_container.item('key', 'name', 'url', @options)
        end
        it "should add the created item to the list of items" do
          @item_container.items.should_receive(:<<)
          @item_container.item('key', 'name', 'url', @options)
        end
      end

    end

    context 'conditions given for item' do

      context '"if" given' do

        before(:each) do
          @options = {:if => Proc.new {@condition}}
        end

        it "should remove if from options" do
          @item_container.item('key', 'name', 'url', @options)
          @options[:if].should be_nil
        end

        context 'if evals to true' do
          before(:each) do
            @condition = true
          end
          it "should create a new Navigation-Item" do
            SimpleNavigation::Item.should_receive(:new)
            @item_container.item('key', 'name', 'url', @options)
          end
        end

        context 'if evals to false' do
          before(:each) do
            @condition = false
          end
          it "should not create a new Navigation-Item" do
            SimpleNavigation::Item.should_not_receive(:new)
            @item_container.item('key', 'name', 'url', @options)
          end
        end

        context 'if is not a proc or method' do
          it "should raise an error" do
            lambda {@item_container.item('key', 'name', 'url', {:if => 'text'})}.should raise_error
          end
        end

        context '"unless" given' do

          before(:each) do
            @options = {:unless => Proc.new {@condition}}
          end


          it "should remove unless from options" do
            @item_container.item('key', 'name', 'url', @options)
            @options[:unless].should be_nil
          end

          context 'unless evals to false' do
            before(:each) do
              @condition = false
            end
            it "should create a new Navigation-Item" do
              SimpleNavigation::Item.should_receive(:new)
              @item_container.item('key', 'name', 'url', @options)
            end
          end

          context 'unless evals to true' do
            before(:each) do
              @condition = true
            end
            it "should not create a new Navigation-Item" do
              SimpleNavigation::Item.should_not_receive(:new)
              @item_container.item('key', 'name', 'url', @options)
            end
          end

        end
      end
    end
  end

  describe '[]' do

    before(:each) do
      @item_container.item(:first, 'first', 'bla')
      @item_container.item(:second, 'second', 'bla')
      @item_container.item(:third, 'third', 'bla')
    end

    it "should return the item with the specified navi_key" do
      @item_container[:second].name.should == 'second'
    end
    it "should return nil if no item exists for the specified navi_key" do
      @item_container[:invalid].should be_nil
    end
  end

  describe 'render' do
    before(:each) do
      @renderer_instance = stub(:renderer).as_null_object
      @renderer_class = stub(:renderer_class, :new => @renderer_instance)
    end
    context 'renderer specified as option' do
      context 'renderer-class specified' do
        it "should instantiate the passed renderer_class with the options" do
          @renderer_class.should_receive(:new).with(:renderer => @renderer_class)
        end
        it "should call render on the renderer and pass self" do
          @renderer_instance.should_receive(:render).with(@item_container)
        end
        after(:each) do
          @item_container.render(:renderer => @renderer_class)
        end
      end
      context 'renderer-symbol specified' do
        before(:each) do
          SimpleNavigation.registered_renderers = {:my_renderer => @renderer_class}
        end
        it "should instantiate the passed renderer_class with the options" do
          @renderer_class.should_receive(:new).with(:renderer => :my_renderer)
        end
        it "should call render on the renderer and pass self" do
          @renderer_instance.should_receive(:render).with(@item_container)
        end
        after(:each) do
          @item_container.render(:renderer => :my_renderer)
        end
      end
    end
    context 'no renderer specified' do
      before(:each) do
        @item_container.stub!(:renderer => @renderer_class)
        @options = {}
      end
      it "should instantiate the container's renderer with the options" do
        @renderer_class.should_receive(:new).with(@options)
      end
      it "should call render on the renderer and pass self" do
        @renderer_instance.should_receive(:render).with(@item_container)
      end
      after(:each) do
        @item_container.render(@options)
      end
    end
  end

  describe 'level_for_item' do
    before(:each) do
      @item_container.item(:p1, 'p1', 'p1')
      @item_container.item(:p2, 'p2', 'p2') do |p2|
        p2.item(:s1, 's1', 's1')
        p2.item(:s2, 's2', 's2') do |s2|
          s2.item(:ss1, 'ss1', 'ss1')
          s2.item(:ss2, 'ss2', 'ss2')
        end
        p2.item(:s3, 's3', 's3')
      end
      @item_container.item(:p3, 'p3', 'p3')
    end
    it {@item_container.level_for_item(:p1).should == 1}
    it {@item_container.level_for_item(:p3).should == 1}
    it {@item_container.level_for_item(:s1).should == 2}
    it {@item_container.level_for_item(:ss1).should == 3}
    it {@item_container.level_for_item(:x).should be_nil}

  end

  describe 'empty?' do
    it "should be empty if there are no items" do
      @item_container.instance_variable_set(:@items, [])
      @item_container.should be_empty
    end
    it "should not be empty if there are some items" do
      @item_container.instance_variable_set(:@items, [stub(:item)])
      @item_container.should_not be_empty
    end
  end

end
