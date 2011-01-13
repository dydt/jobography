class ChangeOauthTokenToText < ActiveRecord::Migration
  def self.up
    change_column :users, :linked_in_access_token, :text
  end

  def self.down
    change_column :users, :linked_in_access_token, :string
  end
end
