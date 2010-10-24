require 'spec_helper'

describe SimpleNavigation::ItemAdapter, 'when item is an object' do

  before(:each) do
    @item = stub(:item)
    @item_adapter = SimpleNavigation::ItemAdapter.new(@item)
  end

  describe 'key' do
    it "should delegate key to item" do
      @item.should_receive(:key)
      @item_adapter.key
    end
  end

  describe 'url' do
    it "should delegate url to item" do
      @item.should_receive(:url)
      @item_adapter.url
    end
  end

  describe 'name' do
    it "should delegate name to item" do
      @item.should_receive(:name)
      @item_adapter.name
    end
  end

  describe 'initialize' do
    it "should set the item" do
      @item_adapter.item.should == @item
    end
  end

  describe 'options' do
    context 'item does respond to options' do
      before(:each) do
        @options = stub(:options)
        @item.stub!(:options => @options)
      end
      it "should return the item's options'" do
        @item_adapter.options.should == @options
      end
    end
    context 'item does not respond to options' do
      it "should return an empty hash" do
        @item_adapter.options.should == {}
      end
    end
  end

  describe 'items' do
    context 'item does respond to items' do
      context 'items is nil' do
        before(:each) do
          @item.stub!(:items => nil)
        end
        it "should return nil" do
          @item_adapter.items.should be_nil
        end
      end
      context 'items is not nil' do
        context 'items is empty' do
          before(:each) do
            @item.stub!(:items => [])
          end
          it "should return nil" do
            @item_adapter.items.should be_nil
          end
        end
        context 'items is not empty' do
          before(:each) do
            @items = stub(:items, :empty? => false)
            @item.stub!(:items => @items)
          end
          it "should return the items" do
            @item_adapter.items.should == @items
          end
        end
      end
    end
    context 'item does not respond to items' do
      it "should return nil" do
        @item_adapter.items.should be_nil
      end
    end
  end

  describe 'to_simple_navigation_item' do
    before(:each) do
      @container = stub(:container)
      @item.stub!(:url => 'url', :name => 'name', :key => 'key', :options => {}, :items => [])
    end
    it "should create a SimpleNavigation::Item" do
      SimpleNavigation::Item.should_receive(:new).with(@container, 'key', 'name', 'url', {}, nil)
      @item_adapter.to_simple_navigation_item(@container)
    end
  end

end

describe SimpleNavigation::ItemAdapter, 'when item is a hash' do

  before(:each) do
    @item = {:key => 'key', :url => 'url', :name => 'name'}
    @item_adapter = SimpleNavigation::ItemAdapter.new(@item)
  end

  describe 'key' do
    it "should delegate key to item" do
      @item_adapter.item.should_receive(:key)
      @item_adapter.key
    end
  end

  describe 'url' do
    it "should delegate url to item" do
      @item_adapter.item.should_receive(:url)
      @item_adapter.url
    end
  end

  describe 'name' do
    it "should delegate name to item" do
      @item_adapter.item.should_receive(:name)
      @item_adapter.name
    end
  end

  describe 'initialize' do
    it "should set the item" do
      @item_adapter.item.should_not be_nil
    end
    it "should have converted the item into an object" do
      @item_adapter.item.should respond_to(:url)
    end
  end

  describe 'options' do
    context 'item does respond to options' do
      before(:each) do
        @item = {:key => 'key', :url => 'url', :name => 'name', :options => {:my => :options}}
        @item_adapter = SimpleNavigation::ItemAdapter.new(@item)
      end
      it "should return the item's options'" do
        @item_adapter.options.should == {:my => :options}
      end
    end
    context 'item does not respond to options' do
      it "should return an empty hash" do
        @item_adapter.options.should == {}
      end
    end
  end

  describe 'items' do
    context 'item does respond to items' do
      context 'items is nil' do
        before(:each) do
          @item = {:key => 'key', :url => 'url', :name => 'name', :items => nil}
          @item_adapter = SimpleNavigation::ItemAdapter.new(@item)
        end
        it "should return nil" do
          @item_adapter.items.should be_nil
        end
      end
      context 'items is not nil' do
        context 'items is empty' do
          before(:each) do
            @item = {:key => 'key', :url => 'url', :name => 'name', :items => []}
            @item_adapter = SimpleNavigation::ItemAdapter.new(@item)
          end
          it "should return nil" do
            @item_adapter.items.should be_nil
          end
        end
        context 'items is not empty' do
          before(:each) do
            @item = {:key => 'key', :url => 'url', :name => 'name', :items => ['not', 'empty']}
            @item_adapter = SimpleNavigation::ItemAdapter.new(@item)
          end
          it "should return the items" do
            @item_adapter.items.should == ['not', 'empty']
          end
        end
      end
    end
    context 'item does not respond to items' do
      it "should return nil" do
        @item_adapter.items.should be_nil
      end
    end
  end

  describe 'to_simple_navigation_item' do
    before(:each) do
      @container = stub(:container)
      @item = {:key => 'key', :url => 'url', :name => 'name', :items => [], :options => {}}
      @item_adapter = SimpleNavigation::ItemAdapter.new(@item)
    end
    it "should create a SimpleNavigation::Item" do
      SimpleNavigation::Item.should_receive(:new).with(@container, 'key', 'name', 'url', {}, nil)
      @item_adapter.to_simple_navigation_item(@container)
    end
  end

end