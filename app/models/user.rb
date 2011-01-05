class User < ActiveRecord::Base
  validates_presence_of :firstName, :lastName, :email, :password
  validates_uniqueness_of :email
end
