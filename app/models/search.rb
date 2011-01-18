class Search < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :query, :if => "location.blank?"
end
