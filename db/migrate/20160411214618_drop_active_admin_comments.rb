class DropActiveAdminComments < ActiveRecord::Migration
  def up
    drop_table :active_admin_comments
  end

  def down
    create_table "active_admin_comments", force: :cascade do |t|
      t.string   "namespace"
      t.text     "body"
      t.string   "resource_id",   null: false
      t.string   "resource_type", null: false
      t.integer  "author_id"
      t.string   "author_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "active_admin_comments", ["author_id", "author_type"], name: "index_active_admin_comments_on_author_id_and_author_type", using: :btree
    add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    add_index "active_admin_comments", ["resource_id", "resource_type"], name: "index_active_admin_comments_on_resource_id_and_resource_type", using: :btree
    add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end
end
