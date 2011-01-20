class User < ActiveRecord::Base

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


  def import_user_fb  
    token = "access_token=#{self.facebook_access_token}"

    user_path = "/#{self.facebook_id}?" + token
    
    user_resp = facebook_call(user_path)
    
    if user_resp.has_key?("work")
      return user_resp["work"].map do |e|
        f = Employment.new
        f.employer = e["employer"]["name"] if e['employer']
        f.location = e['location']["name"] if e['location']
        f.title = e["position"]["name"] if e['position']
        f.start_date = e["start date"]
        f.end_date = e["end_date"]

        f
      end     
    end
  
    get_friend_path = "/#{self.facebook_id}/friends?" + token

    friends_list = facebook_call(get_friend_path)
    friends_ids = friends_list["data"].map {|f| f["id"]}
    friends_paths = friends_ids.map {|id| "/#{id}?" + token}
    friend_resp = friends_paths.map do |p| 
      facebook_call(p)
    end
    friend_resp = friend_resp.each.select {|h| h.has_key?("work")}
    friend_resp.map do |fs|
      fs["work"].map do |f|
        e = Employment.new
        e.employer = f["employer"]["name"] if f["employer"]
        e.location = f["location"]["name"] if f["location"]
        e.title = f["position"]["name"] if f["position"]
        e.start_date = f["start date"]
        e.end_date = f["end_date"]
    
        e
      end
    end
  end

  def facebook_call(path)
    puts path
    http = Net::HTTP.new('graph.facebook.com', 443)
    http.use_ssl = true

    resp = http.get(path)
    resp_text = resp.body
    
    jsonresp = JSON.parse(resp_text)
    return [] unless jsonresp

    jsonresp
  end  
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    User.find_by_facebook_id(access_token['uid'])
  end
  
  def self.find_for_linked_in_oauth(access_token, signed_in_resource=nil)
    User.find_by_linked_in_id(access_token['uid'])
  end
  
end
