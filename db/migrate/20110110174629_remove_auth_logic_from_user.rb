class RemoveAuthLogicFromUser < ActiveRecord::Migration
  def self.up
    drop_table :sessions
    drop_table :access_tokens
    
    change_table :users do |t|
      t.remove :active_token_id
      t.remove :lastLogin, :salt, :persistence_token, :login_count, :failed_login_count,
                :last_request_at, :current_login_at, :last_login_at, :current_login_ip,
                :last_login_ip
    end
  end

  def self.down
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
    
    create_table :access_tokens do |t|
      t.integer :user_id
      t.string :type, :limit => 30
      t.string :key # how we identify the user, in case they logout and log back in
      t.string :token, :limit => 1024 # This has to be huge because of Yahoo's excessively large tokens
      t.string :secret
      t.boolean :active # whether or not it's associated with the account
      t.timestamps
    end
    add_index :access_tokens, :key, :unique
    
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
  end
end
