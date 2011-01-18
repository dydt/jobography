class User < ActiveRecord::Base
  require 'net/https'
  require 'cgi'

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
         
  serialize :linked_in_access_token, OAuth::AccessToken

  # Setup accessible (or protected) attributes for your model
  attr_accessible  :name, :email, :password, :password_confirmation, :remember_me
  validates_presence_of :name
  validates_uniqueness_of :email

  
  def self.new_with_session(params, session)
    super.tap do |user|
      if (lidata = session["devise.linked_in_data"])
        user.name = lidata['user_info']['first_name'] + ' ' + lidata['user_info']['last_name']
        user.linked_in_id = lidata['uid']
        user.linked_in_access_token = lidata['extra']['access_token']
      end
      
      # Facebook data takes precedence
      if (fbdata = session["devise.facebook_data"])
        user.name = fbdata['user_info']['name']
        user.email = fbdata['extra']['user_hash']['email']
        user.facebook_id = fbdata['uid']
        user.facebook_access_token = fbdata['credentials']['token']
      end
    end
  end

  def import_fb_contacts  
    path = "/#{self.facebook_id}?access_token=#{self.facebook_access_token}"
    http = Net::HTTP.new('graph.facebook.com', 443)
    http.use_ssl = true

    resp = http.get(path)
    respText = resp.body
    
  end
    
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    User.find_by_facebook_id(access_token['uid'])
  end
  
  def self.find_for_linked_in_oauth(access_token, signed_in_resource=nil)
    User.find_by_linked_in_id(access_token['uid'])
  end
  
end
