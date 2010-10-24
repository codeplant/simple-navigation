require 'spec_helper'

describe SimpleNavigation::ItemsProvider do

  before(:each) do
    @provider = stub(:provider)
    @items_provider = SimpleNavigation::ItemsProvider.new(@provider)
  end

  describe 'initialize' do
    it "should set the provider" do
      @items_provider.provider.should == @provider
    end
  end

  describe 'items' do
    before(:each) do
      @items = stub(:items)
    end
    context 'provider is symbol' do
      before(:each) do
        @items_provider.instance_variable_set(:@provider, :provider_method)
        @context = stub(:context, :provider_method => @items)
        SimpleNavigation.stub!(:context_for_eval => @context)
      end
      it "should call the method specified by symbol on the context" do
        @context.should_receive(:provider_method)
        @items_provider.items
      end
      it "should return the items returned by the helper method" do
        @items_provider.items.should == @items
      end
    end
    context 'provider responds to items' do
      before(:each) do
        @provider.stub!(:items => @items)
      end
      it "should get the items from the items_provider" do
        @provider.should_receive(:items)
        @items_provider.items
      end
      it "should return the items of the provider" do
        @items_provider.items.should == @items
      end
    end
    context 'provider is a collection' do
      before(:each) do
        @items_collection = []
        @items_provider.instance_variable_set(:@provider, @items_collection)
      end
      it "should return the collection itsself" do
        @items_provider.items.should == @items_collection
      end
    end
    context 'neither symbol nor items_provider.items nor collection' do
      it {lambda {@items_provider.items}.should raise_error}
    end
  end

end