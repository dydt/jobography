class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible  :name, :email, :password, :password_confirmation, :remember_me
  validates_presence_of :name
  validates_uniqueness_of :email
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if (lidata = session["devise.linked_in_data"])
        user.name = lidata['user_info']['first_name'] + ' ' + lidata['user_info']['last_name']
        user.linked_in_uuid = lidata['uid']
      end
      
      # Facebook data takes precedence
      if (fbdata = session["devise.facebook_data"])
        user.name = fbdata['user_info']['name']
        user.email = fbdata['extra']['user_hash']['email']
        user.facebook_uuid = fbdata['uid']
      end
    end
  end
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    if user = User.find_by_facebook_uuid(access_token['uid'])
      user
    else
      return nil
    end
  end
  
  def self.find_for_linked_in_oauth(access_token, signed_in_resource=nil)
    # FIXME - there's no way to get the user's email through linkedIn.
    # Need to do an extra api call to get uid.
    return nil
  end
  
end
