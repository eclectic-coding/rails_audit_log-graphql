ActiveRecord::Schema[8.1].define(version: 2026_06_03_000001) do
  create_table :audit_log_entries, force: :cascade do |t|
    t.string :event, null: false
    t.string :item_type, null: false
    t.bigint :item_id, null: false
    t.json :object_changes
    t.json :object
    t.json :metadata
    t.string :reason
    t.string :whodunnit_snapshot
    t.string :actor_type
    t.bigint :actor_id
    t.string :tenant_id
    t.datetime :created_at
  end

  add_index :audit_log_entries, [:item_type, :item_id]
  add_index :audit_log_entries, [:actor_type, :actor_id]
  add_index :audit_log_entries, :event
  add_index :audit_log_entries, :created_at
  add_index :audit_log_entries, :tenant_id

  create_table :posts, force: :cascade do |t|
    t.string :title, null: false
    t.text :body
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :users, force: :cascade do |t|
    t.string :name
    t.datetime :created_at
    t.datetime :updated_at
  end
end
