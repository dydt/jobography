class UsersController < ApplicationController

  def show_fb_contacts
    if current_user
      render :json => current_user.facebook_contacts
    else 
      render :json => []
    end 
  end

end
