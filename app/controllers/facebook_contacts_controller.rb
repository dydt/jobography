class FacebookContactsController < ApplicationController
  
  def index
    @user = User.find(params[:user_id])
    render :json => @user.facebook_contacts.map {|c| {:id => c.id, :name => c.name}}
  end
  
  def show
    @contact = FacebookContact.find(params[:id])
    if not @contact.retrieved_at
      @contact = @contact.user.retrieve_contact(@contact.facebook_id)
      @contact.retrieved_at = Time.now
      @contact.save
    end
    render :json => @contact
  end
end
