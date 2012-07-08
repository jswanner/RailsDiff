# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20120708031835) do

  create_table "diffs", :force => true do |t|
    t.string   "source"
    t.string   "target"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "diffs", ["source"], :name => "index_diffs_on_source"
  add_index "diffs", ["target"], :name => "index_diffs_on_target"

  create_table "file_diffs", :force => true do |t|
    t.integer  "diff_id"
    t.string   "file_path"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "file_diffs", ["diff_id"], :name => "index_file_diffs_on_diff_id"

  create_table "versions", :force => true do |t|
    t.string   "version"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
