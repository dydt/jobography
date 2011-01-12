class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)

    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
  
  def linked_in
    @user = User.find_for_linked_in_oauth(env["omniauth.auth"], current_user)

    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "LinkedIn"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.linked_in_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
  
  def after_omniauth_failure_path_for(scope)
    new_registration_path(scope)
  end
  
end