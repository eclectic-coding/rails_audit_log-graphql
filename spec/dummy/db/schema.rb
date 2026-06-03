# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_03_000001) do
  create_table "audit_log_entries", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.json "metadata"
    t.json "object"
    t.json "object_changes"
    t.string "reason"
    t.string "tenant_id"
    t.string "whodunnit_snapshot"
    t.index ["actor_type", "actor_id"], name: "index_audit_log_entries_on_actor_type_and_actor_id"
    t.index ["created_at"], name: "index_audit_log_entries_on_created_at"
    t.index ["event"], name: "index_audit_log_entries_on_event"
    t.index ["item_type", "item_id"], name: "index_audit_log_entries_on_item_type_and_item_id"
    t.index ["tenant_id"], name: "index_audit_log_entries_on_tenant_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at"
    t.string "title", null: false
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at"
    t.string "name"
    t.datetime "updated_at"
  end
end
