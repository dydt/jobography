class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible  :name, :email, :password, :password_confirmation, :remember_me
  validates_presence_of :name
  validates_uniqueness_of :email
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    if user = User.find_by_email(data["email"])
      user
    else # Create an user with a stub password. 
      User.create!(:name => access_token['user_info']['name'],
                    :email => data["email"], 
                    :password => Devise.friendly_token[0,20]) 
    end
  end
  
  def self.find_for_linked_in_oauth(access_token, signed_in_resource=nil)
    # FIXME - there's no way to get the user's email through linkedIn.
    # Make something up for now.
    logger.warn access_token
    data = access_token['user_info']
    logger.warn data
    if false #user = User.find_by_email(data["email"])
      user
    else # Create an user with a stub password. 
      User.create!(:name => data['first_name'] + data['last_name'],
            :email => Devise.friendly_token[0,5] + '@example.com',
            :password => Devise.friendly_token[0,20]) 
    end
  end
  
end
