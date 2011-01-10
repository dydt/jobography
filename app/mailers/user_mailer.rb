class UserMailer < ActionMailer::Base
  default :from => "mboyd@mit.edu"
  
  def welcome_email(user)
    @user = user
    @url = "http://six470.heroku.com/login"
    mail(:to => user.email, :subject => "Welcome to six470")
  end
  
end
