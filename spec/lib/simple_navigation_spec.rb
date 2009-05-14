require File.dirname(__FILE__) + '/../spec_helper'

describe SimpleNavigation do
  
  describe 'load_config' do
    context 'config_file_path is set' do
      before(:each) do
        SimpleNavigation.config_file_path = 'path_to_config'
      end
      
      context 'config_file does exist' do
        before(:each) do
          File.stub!(:exists?).and_return(true)
          IO.stub!(:read).and_return('file_content')
        end
        it "should not raise an error" do
          lambda{SimpleNavigation.load_config}.should_not raise_error
        end
        it "should read the config file from disc" do
          IO.should_receive(:read).with('path_to_config')
          SimpleNavigation.load_config
        end
        it "should store the read content in the module" do
          SimpleNavigation.should_receive(:config_file=).with('file_content')
          SimpleNavigation.load_config
        end
      end
      
      context 'config_file does not exist' do
        before(:each) do
          File.stub!(:exists?).and_return(false)
        end
        it {lambda{SimpleNavigation.load_config}.should raise_error}
      end
    end
    
    context 'config_file_path is not set' do
      before(:each) do
        SimpleNavigation.config_file_path = nil
      end
      it {lambda{SimpleNavigation.load_config}.should raise_error}
    end
  end
  
  describe 'config' do
    it {SimpleNavigation.config.should == SimpleNavigation::Configuration.instance}
  end
  
end