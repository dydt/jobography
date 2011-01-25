class FacebookContactsController < ApplicationController
  
  def index
    @user = current_user
    if @user
      render :json => @user.facebook_contacts.map {|c| {:id => c.id, :name => c.name}}
    else
      render :json => []
    end
  end
  
  def show
    @contact = FacebookContact.find(params[:id])
    if @contact.user != current_user
      render :json => {:error => "Not authorized"}
      return
    end
    
    if not @contact.retrieved_at
      @contact = @contact.user.retrieve_contact(@contact.facebook_id)
      @contact.retrieved_at = Time.now
      @contact.save
    end
    render :json => @contact.to_json(:include => 
      {:employments => {:except => [:contact_id, :contact_type, :created_at, :updated_at]}})
  end
end
