class Search < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :query, :location
end
