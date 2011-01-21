class AddFbContactsToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.references :facebook_contacts
    end
  end

  def self.down
    remove_column :users, :facebook_contacts
  end
end
