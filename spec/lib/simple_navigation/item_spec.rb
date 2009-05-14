require File.dirname(__FILE__) + '/../../spec_helper'

describe SimpleNavigation::Item do
  
  describe 'initialize' do
    context 'method' do
      context 'defined' do
        before(:each) do
          @options = {:method => :delete}
          @item = SimpleNavigation::Item.new(:my_key, 'name', 'url', @options, nil)          
        end
        it 'should set the method as instance_var' do
          @item.method.should == :delete
        end
        it 'should set the html-options without the method' do
          @item.instance_variable_get(:@html_options).key?(:method).should be_false
        end
      end
      
      context 'undefined' do
        before(:each) do
          @item = SimpleNavigation::Item.new(:my_key, 'name', 'url', {}, nil)          
        end
        it 'should set the instance-var to nil' do
          @item.method.should be_nil
        end
      end
    end
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
    describe 'class' do
      context 'with classes defined in options' do
        before(:each) do
          @options = {:class => 'my_class'}
          @item = SimpleNavigation::Item.new(:my_key, 'name', 'url', @options, nil)
        end
        context 'with item selected' do
          before(:each) do
            @item.stub!(:selected?).and_return(true)
          end
          it {@item.html_options(:bla)[:class].should == 'my_class selected'}
        end
      
        context 'with item not selected' do
          before(:each) do
            @item.stub!(:selected?).and_return(false)
          end
          it {@item.html_options(:bla)[:class].should == 'my_class'}
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
          it {@item.html_options(:bla)[:class].should == 'selected'}
        end
      
        context 'with item not selected' do
          before(:each) do
            @item.stub!(:selected?).and_return(false)
          end
          it {@item.html_options(:bla)[:class].should be_blank}
        end
      end
    end
    
    describe 'id' do
      context 'with id defined in options' do
        before(:each) do
          @options = {:id => 'my_id'}
          @item = SimpleNavigation::Item.new(:my_key, 'name', 'url', @options, nil)
        end
        it {@item.html_options(:bla)[:id].should == 'my_id'}
      end
      
      context 'with no id definied in options (using default id)' do
        before(:each) do
          @options = {}
          @item = SimpleNavigation::Item.new(:my_key, 'name', 'url', @options, nil)
        end
        it {@item.html_options(:bla)[:id].should == 'my_key'}
      end
    end
        
  end
  

end
