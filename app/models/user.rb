class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
         
  serialize :linked_in_access_token, OAuth::AccessToken
  
  has_many :facebook_contacts, :autosave => true
  has_many :employments, :as => :contact

  # Setup accessible (or protected) attributes for your model
  attr_accessible  :name, :email, :password, :password_confirmation, :remember_me,
                    :facebook_contacts, :employments
  validates_presence_of :name
  validates_uniqueness_of :email

  
  def self.new_with_session(params, session)
    super.tap do |user|
      if (lidata = session["devise.linked_in_data"])
        user.name = lidata['user_info']['first_name'] + ' ' +
                    lidata['user_info']['last_name']
        user.linked_in_id = lidata['uid']
        user.linked_in_access_token = lidata['extra']['access_token']
      end
      
      # Facebook data takes precedence
      if (fbdata = session["devise.facebook_data"])
        user.name = fbdata['user_info']['name']
        user.email = fbdata['extra']['user_hash']['email']
        user.facebook_id = fbdata['uid']
        user.facebook_access_token = fbdata['credentials']['token']
        #Make delayed job that runs import_user_fb
      end
    end
  end


  def import_user_fb  
    token = "access_token=#{self.facebook_access_token}"

    user_resp = facebook_call("/#{self.facebook_id}?fields=work&" + token)
    
    self.employments = user_resp['work'].map {|e| parse_employment(e) } if user_resp['work']
  
    friends_list = facebook_call("/#{self.facebook_id}/friends?" + token)
    friends_paths = friends_list['data'].map do |f|
      "/#{f['id']}?fields=id,name,location,work&" + token
    end
    friend_resps = friends_paths.map { |p| facebook_call(p) }
    
    self.facebook_contacts = friend_resps.map {|r| parse_fb_contact(r) }
    
    self.save
  end
  
  def parse_fb_contact(r)
    c = FacebookContact.new
    c.facebook_id = r['id']
    c.name = r['name']
    c.location = r['location']['name'] if r['location']
    c.employments = r['work'].map {|e| parse_employment(e) } if r['work']
    return c
  end
  
  def parse_employment(r)
    e = Employment.new
    e.employer = r["employer"]["name"] if r["employer"]
    e.location = r["location"]["name"] if r["location"]
    e.title = r["position"]["name"] if r["position"]
    e.start_date = r["start date"]
    e.end_date = r["end_date"]
    return e
  end

  def facebook_call(path)
    puts path
    http = Net::HTTP.new('graph.facebook.com', 443)
    http.use_ssl = true

    resp = http.get(path)
    resp_text = resp.body
    
    print '-> Parsing response...'
    jsonresp = JSON.parse(resp_text)
    print " done\n"
    return (jsonresp or [])
  end  

  def import_user_li
    
  end
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    User.find_by_facebook_id(access_token['uid'])
  end
  
  def self.find_for_linked_in_oauth(access_token, signed_in_resource=nil)
    User.find_by_linked_in_id(access_token['uid'])
  end
  
end
