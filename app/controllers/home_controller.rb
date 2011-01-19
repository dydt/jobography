class HomeController < ApplicationController

  def home
    @recent_searches = Search.order('created_at DESC').limit(10)
  end
  
  def wrapper
    render :layout => false
  end

end
