class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
         
  serialize :linked_in_access_token, OAuth::AccessToken
  
  has_many :facebook_contacts, :autosave => true, :dependent => :destroy
  has_many :employments, :as => :contact, :dependent => :destroy
  
  after_create :send_welcome_email
  after_save :sync_facebook

  # Setup accessible (or protected) attributes for your model
  attr_accessible  :name, :email, :password, :password_confirmation, :remember_me,
                    :facebook_contacts, :employments
  validates_presence_of :name
  validates_uniqueness_of :email
  
  def send_welcome_email()
    UserMailer.deliver_welcome_email(self)
  end
  
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
      end
    end
  end
  
  def sync_facebook
    if self.facebook_contacts == [] and self.employments == []
      import_facebook_data
    end
  end

  def import_facebook_data  
    token = "access_token=#{self.facebook_access_token}"
    
    user_resp = facebook_call("/#{self.facebook_id}?fields=work&" + token)
    
    self.employments = user_resp['work'].map {|e| parse_employment(e) } if user_resp['work']
    
    friends_list = facebook_call("/#{self.facebook_id}/friends?" + token)
    
    self.facebook_contacts = friends_list['data'].map do |f|
      FacebookContact.new(:facebook_id => f['id'], :name => f['name'])
    end
    
    self.save
  end
  handle_asynchronously :import_facebook_data
  
  def retrieve_contact(contact_facebook_id)
    path = "/#{contact_facebook_id}?fields=id,name,location,work&" +
            "access_token=#{self.facebook_access_token}"
    
    r = facebook_call(path)
    
    c = FacebookContact.find_by_facebook_id(contact_facebook_id)
    c.facebook_id = r['id']
    c.name = r['name']
    c.location = r['location']['name'] if r['location']
    c.employments = r['work'].map {|e| parse_employment(e) } if r['work']
    
    if c.location and c.location != ''
      r = geocode_call(c.location)
      if r['status'] == 'OK'
        begin
          latlng = r['results'][0]['geometry']['location']
          c.lat = latlng['lat']
          c.long = latlng['lng']
        rescue NoMethodError
          logger.error "Failed to parse geocode response: #{r}"
        end
      else
        logger.error "Failed to geocode contact #{c.name}: #{r['status']}"
      end
    end
    
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
    http = Net::HTTP.new('graph.facebook.com', 443)
    http.use_ssl = true

    resp = http.get(path)
    resp_text = resp.body
    
    jsonresp = JSON.parse(resp_text)
    return (jsonresp or [])
  end  
  
  def geocode_call(address)
    http = Net::HTTP.new('maps.googleapis.com', 80)

    resp = http.get("/maps/api/geocode/json?" +
              "region=us&language=en&sensor=false&address=#{URI::encode address}")
    resp_text = resp.body
    
    jsonresp = JSON.parse(resp_text)
    return (jsonresp or [])
  end
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    User.find_by_facebook_id(access_token['uid'])
  end
  
  def self.find_for_linked_in_oauth(access_token, signed_in_resource=nil)
    User.find_by_linked_in_id(access_token['uid'])
  end
  
end
