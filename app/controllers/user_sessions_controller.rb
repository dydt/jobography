class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:destroy]
  
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    @user_session.save do |result|
      if result
        redirect_to :root
      else
        render :action => :confirm
        return
        if @user_session.errors.on(:user)
          render :action => :confirm
        else
          render :action => :new
        end
      end
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to :root
  end

end
