class FacebookContact < ActiveRecord::Base
  validates_presence_of :name, :facebook_id
  
  belongs_to :user
  has_many :employments, :as => :contact
end
