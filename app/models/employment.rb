class Employment < ActiveRecord::Base
  validates_presence_of :employer, :if => "location.nil?"
  validates_presence_of :location, :if => "employer.nil?"
  
  belongs_to :contact
end
