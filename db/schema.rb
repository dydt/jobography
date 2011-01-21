# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110121014752) do

  create_table "employments", :force => true do |t|
    t.string   "employer"
    t.string   "title"
    t.string   "location"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_type"
  end

  create_table "facebook_contacts", :force => true do |t|
    t.string   "facebook_id"
    t.string   "name"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "jobs", :force => true do |t|
    t.string    "title"
    t.string    "company"
    t.float     "pay"
    t.timestamp "date"
    t.string    "source"
    t.string    "desc"
    t.float     "lat"
    t.float     "long"
    t.string    "state"
    t.string    "city"
    t.string    "zip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "job_type"
    t.string    "orig_id"
  end

  create_table "searches", :force => true do |t|
    t.string   "query"
    t.string   "location"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["created_at"], :name => "index_searches_on_created_at"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_id"
    t.string   "linked_in_id"
    t.string   "facebook_access_token"
    t.text     "linked_in_access_token", :limit => 255
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"
  add_index "users", ["linked_in_id"], :name => "index_users_on_linked_in_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
