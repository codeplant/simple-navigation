class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def render_dummy
    render :text => "Content", :layout => true
  end
  
end
