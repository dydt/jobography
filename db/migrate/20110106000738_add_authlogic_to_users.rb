class AddAuthlogicToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.rename :password, :crypted_password
      t.remove :lastLogin
      t.string :salt
      t.string :persistence_token
      t.integer :login_count, :default => 0
      t.integer :failed_login_count, :default => 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip
    end
    
    User.update_all ["salt = ?", 'salt']
    User.update_all ["persistence_token = ?", 'tok']
    User.update_all ["login_count = ?", 0]
    User.update_all ["failed_login_count = ?", 0]
  end

  def self.down
    change_table :users do |t|
      t.remove :last_login_ip
      t.remove :current_login_ip
      t.remove :last_login_at
      t.remove :current_login_at
      t.remove :last_request_at
      t.remove :failed_login_count
      t.remove :login_count
      t.remove :persistence_token
      t.remove :salt
      t.timestamp :lastLogin
      t.rename :crypted_password, :password
    end
  end
end
