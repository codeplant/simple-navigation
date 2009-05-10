require File.dirname(__FILE__) + '/../../spec_helper'

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

  describe 'item' do
    
    context 'unconditional item' do
    
      before(:each) do
        @item_container.stub!(:should_add_item?).and_return(true)
      end
    
      context 'block given' do    
        before(:each) do
          @sub_container = stub(:sub_container)
          SimpleNavigation::ItemContainer.stub!(:new).and_return(@sub_container)
        end
      
        it "should should yield an new ItemContainer" do
          @item_container.item('key', 'name', 'url', 'options') do |container|
            container.should == @sub_container
          end
        end
        it "should create a new Navigation-Item with the given params and the specified block" do
          SimpleNavigation::Item.should_receive(:new).with('key', 'name', 'url', 'options', @proc)
          @item_container.item('key', 'name', 'url', 'options', &@proc)
        end
        it "should add the created item to the list of items" do
          @item_container.items.should_receive(:<<)
          @item_container.item('key', 'name', 'url', 'options') {}
        end
      end
    
      context 'no block given' do
        it "should create a new Navigation_item with the given params and nil as sub_navi" do
          SimpleNavigation::Item.should_receive(:new).with('key', 'name', 'url', 'options', nil)
          @item_container.item('key', 'name', 'url', 'options')
        end
        it "should add the created item to the list of items" do
          @item_container.items.should_receive(:<<)
          @item_container.item('key', 'name', 'url', 'options')
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
      @renderer = stub(:renderer)
      @renderer_instance = stub(:renderer_instance, :null_object => true)
      @renderer.stub!(:new).and_return(@renderer_instance)
      @item_container.stub!(:renderer).and_return(@renderer)
      @items = stub(:items)
      @item_container.stub!(:items).and_return(@items)
    end
    it "should instatiate a renderer with the current_primary and current_secondary" do
      @renderer.should_receive(:new).with(:current_navigation, nil)
      @item_container.render(:current_navigation)
    end
    it "should call render on the renderer and pass self" do
      @renderer_instance.should_receive(:render).with(@item_container, anything)
      @item_container.render(:current_navigation)
    end
    it "should call render on the renderer and pass the include_sub_navigation option" do
      @renderer_instance.should_receive(:render).with(anything, true)
      @item_container.render(:current_navigation, true, :current_sub_navigation)
    end
    
  end
  
end
