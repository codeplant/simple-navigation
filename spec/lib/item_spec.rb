require File.dirname(__FILE__) + '/../spec_helper'

describe SimpleNavigation::Item do
  
  describe 'initialize' do
  
  end
  
  describe 'selected?' do
    before(:each) do
      @item = SimpleNavigation::Item.new(:my_key, 'name', 'url', {}, nil)
    end
    it {@item.selected?(:my_key).should be_true}
    it {@item.selected?(:my_other_key).should be_false}
  end
  
  describe 'selected_class' do
    before(:each) do
      @item = SimpleNavigation::Item.new(:my_key, 'name', 'url', {}, nil)
    end
    
    context 'item is selected' do
      before(:each) do
        @item.stub!(:selected?).and_return(true)
      end
      it {@item.instance_eval {selected_class(:bla).should == 'selected'}}
    end
    
    context 'item is not selected' do
      before(:each) do
        @item.stub!(:selected?).and_return(false)
      end
      it {@item.instance_eval {selected_class(:bla).should == nil}}
    end
  end
  
  describe 'html_options' do
    before(:each) do
      
    end
    context 'with classes defined in options' do
      before(:each) do
        @options = {:class => 'my_class'}
        @item = SimpleNavigation::Item.new(:my_key, 'name', 'url', @options, nil)
      end
      context 'with item selected' do
        before(:each) do
          @item.stub!(:selected?).and_return(true)
        end
        it {@item.html_options(:bla).should == {:class => 'my_class selected'}}
      end
      
      context 'with item not selected' do
        before(:each) do
          @item.stub!(:selected?).and_return(false)
        end
        it {@item.html_options(:bla).should.should == {:class => 'my_class'}}
      end
    end
    
    context 'without classes in options' do
      before(:each) do
        @options = {}
        @item = SimpleNavigation::Item.new(:my_key, 'name', 'url', @options, nil)
      end
      context 'with item selected' do
        before(:each) do
          @item.stub!(:selected?).and_return(true)
        end
        it {@item.html_options(:bla).should.should == {:class => 'selected'}}
      end
      
      context 'with item not selected' do
        before(:each) do
          @item.stub!(:selected?).and_return(false)
        end
        it {@item.html_options(:bla).should.should == {}}
      end
    end
  end
  

end
