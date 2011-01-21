class FixEmploymentReferences < ActiveRecord::Migration
  def self.up
    add_column :employments, :contact_type, :string
  end

  def self.down
    remove_column :employments, :contact_type
  end
end
