class User < ActiveRecord::Base
  validates_presence_of :firstName, :lastName, :email, :crypted_password, :salt, :persistence_token, :login_count, :failed_login_count
  validates_uniqueness_of :email
  
  acts_as_authentic do |c|
    c.crypted_password_field = :crypted_password
    c.password_salt_field = :salt
  end
end
