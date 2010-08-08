class GistController < ApplicationController

  def load
    render :partial => 'gist/load', :locals => {:gist => params[:gist]}, :layout => 'gist'
  end
  
end