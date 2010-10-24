require 'spec_helper'

describe SimpleNavigation::Renderer::Base do
  before(:each) do
    @options = stub(:options).as_null_object
    @adapter = stub(:adapter)
    SimpleNavigation.stub!(:adapter => @adapter)
    @base_renderer = SimpleNavigation::Renderer::Base.new(@options)
  end
  
  describe 'delegated methods' do
    it {@base_renderer.should respond_to(:link_to)}
    it {@base_renderer.should respond_to(:content_tag)}
  end

  describe 'initialize' do
    it {@base_renderer.adapter.should == @adapter}
    it {@base_renderer.options.should == @options}
  end
    
  describe 'render' do
    it "be subclass responsability" do
      lambda {@base_renderer.render(:container)}.should raise_error('subclass responsibility')
    end
  end
    
  describe 'expand_all?' do
    context 'option is set' do
      context 'expand_all is true' do
        before(:each) do
          @base_renderer.stub!(:options => {:expand_all => true})
        end
        it {@base_renderer.expand_all?.should be_true}
      end
      context 'expand_all is false' do
        before(:each) do
          @base_renderer.stub!(:options => {:expand_all => false})
        end
        it {@base_renderer.expand_all?.should be_false}
      end
    end
    context 'option is not set' do
      before(:each) do
        @base_renderer.stub!(:options => {})
      end
      it {@base_renderer.expand_all?.should be_false}
    end
  end

  describe 'skip_if_empty?' do
    context 'option is set' do
      context 'skip_if_empty is true' do
        before(:each) do
          @base_renderer.stub!(:options => {:skip_if_empty => true})
        end
        it {@base_renderer.skip_if_empty?.should be_true}
      end
      context 'skip_if_empty is false' do
        before(:each) do
          @base_renderer.stub!(:options => {:skip_if_empty => false})
        end
        it {@base_renderer.skip_if_empty?.should be_false}
      end
    end
    context 'option is not set' do
      before(:each) do
        @base_renderer.stub!(:options => {})
      end
      it {@base_renderer.skip_if_empty?.should be_false}
    end
  end

  describe 'level' do
    context 'options[level] is set' do
      before(:each) do
        @base_renderer.stub!(:options => {:level => 1})
      end
      it {@base_renderer.level.should == 1}
    end
    context 'options[level] is not set' do
      before(:each) do
        @base_renderer.stub!(:options => {})
      end
      it {@base_renderer.level.should == :all}
    end
  end

  describe 'consider_sub_navigation?' do
    before(:each) do
      @item = stub(:item)
    end
    context 'item has no subnavigation' do
      before(:each) do
        @item.stub!(:sub_navigation => nil)
      end
      it {@base_renderer.send(:consider_sub_navigation?, @item).should be_false}
    end
    context 'item has subnavigation' do
      before(:each) do
        @sub_navigation = stub(:sub_navigation)
        @item.stub!(:sub_navigation => @sub_navigation)
      end
      context 'level is something unknown' do
        before(:each) do
          @base_renderer.stub!(:level => 'unknown')
        end
        it {@base_renderer.send(:consider_sub_navigation?, @item).should be_false}
      end
      context 'level is :all' do
        before(:each) do
          @base_renderer.stub!(:level => :all)
        end
        it {@base_renderer.send(:consider_sub_navigation?, @item).should be_true}
      end
      context 'level is an Integer' do
        before(:each) do
          @base_renderer.stub!(:level => 2)
        end
        it {@base_renderer.send(:consider_sub_navigation?, @item).should be_false}
      end
      context 'level is a Range' do
        before(:each) do
          @base_renderer.stub!(:level => 2..3)
        end
        context 'subnavs level > range.max' do
          before(:each) do
            @sub_navigation.stub!(:level => 4)
          end
          it {@base_renderer.send(:consider_sub_navigation?, @item).should be_false}
        end
        context 'subnavs level = range.max' do
          before(:each) do
            @sub_navigation.stub!(:level => 3)
          end
          it {@base_renderer.send(:consider_sub_navigation?, @item).should be_true}

        end
        context 'subnavs level < range.max' do
          before(:each) do
            @sub_navigation.stub!(:level => 2)
          end
          it {@base_renderer.send(:consider_sub_navigation?, @item).should be_true}
        end
      end
    end
  end

  describe 'include_sub_navigation?' do
    before(:each) do
      @item = stub(:item)
    end
    context 'consider_sub_navigation? is true' do
      before(:each) do
        @base_renderer.stub!(:consider_sub_navigation? => true)
      end
      context 'expand_sub_navigation? is true' do
        before(:each) do
          @base_renderer.stub!(:expand_sub_navigation? => true)
        end
        it {@base_renderer.include_sub_navigation?(@item).should be_true}
      end
      context 'expand_sub_navigation? is false' do
        before(:each) do
          @base_renderer.stub!(:expand_sub_navigation? => false)
        end
        it {@base_renderer.include_sub_navigation?(@item).should be_false}
      end
    end
    context 'consider_sub_navigation is false' do
      before(:each) do
        @base_renderer.stub!(:consider_sub_navigation? => false)
      end
      context 'expand_sub_navigation? is true' do
        before(:each) do
          @base_renderer.stub!(:expand_sub_navigation? => true)
        end
        it {@base_renderer.include_sub_navigation?(@item).should be_false}
      end
      context 'expand_sub_navigation? is false' do
        before(:each) do
          @base_renderer.stub!(:expand_sub_navigation? => false)
        end
        it {@base_renderer.include_sub_navigation?(@item).should be_false}
      end
    end
  end

  describe 'render_sub_navigation_for' do
    before(:each) do
      @sub_navigation = stub(:sub_navigation)
      @item = stub(:item, :sub_navigation => @sub_navigation)
    end
    it "should call render on the sub_navigation (passing the options)" do
      @sub_navigation.should_receive(:render).with(@options)
      @base_renderer.render_sub_navigation_for(@item)
    end
  end

end
