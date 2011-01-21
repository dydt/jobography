class Employment < ActiveRecord::Base
  validates_presence_of :employer, :if => "location.blank?"
  validates_presence_of :location, :if => "employer.blank?"
  
  belongs_to :contact, :polymorphic => true
end
