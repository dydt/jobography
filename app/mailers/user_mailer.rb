class UserMailer < ActionMailer::Base
  default :from => "jobography@mit.edu"
  
  def welcome_email(user)
    @user = user
    @url = "http://jobography.heroku.com/login"
    mail(:to => user.email, :subject => "Welcome to Jobography")
  end
  
end
