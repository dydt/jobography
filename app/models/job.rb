class Job < ActiveRecord::Base
  validates_presence_of :title, :date, :source
  validates_uniqueness_of :orig_id
end