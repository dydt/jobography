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

ActiveRecord::Schema.define(:version => 20110107055507) do

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

  create_table "users", :force => true do |t|
    t.string    "firstName"
    t.string    "lastName"
    t.string    "email"
    t.string    "crypted_password"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "salt"
    t.string    "persistence_token"
    t.integer   "login_count",        :default => 0
    t.integer   "failed_login_count", :default => 0
    t.timestamp "last_request_at"
    t.timestamp "current_login_at"
    t.timestamp "last_login_at"
    t.string    "current_login_ip"
    t.string    "last_login_ip"
  end

end
