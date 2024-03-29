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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160412130358) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_trgm"

  create_table "aliases", force: :cascade do |t|
    t.string   "name",           null: false
    t.integer  "aliasable_id",   null: false
    t.string   "aliasable_type", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "aliases", ["aliasable_type", "aliasable_id"], name: "index_aliases_on_aliasable_type_and_aliasable_id", using: :btree
  add_index "aliases", ["name", "aliasable_type", "aliasable_id"], name: "index_aliases_on_name_and_aliasable_type_and_aliasable_id", unique: true, using: :btree
  add_index "aliases", ["name"], name: "index_aliases_on_name", using: :btree

  create_table "callbacks", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.text     "body"
    t.integer  "user_id"
    t.boolean  "active",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "callbacks", ["user_id"], name: "index_callbacks_on_user_id", using: :btree

  create_table "catalog_brands", force: :cascade do |t|
    t.string   "name",       default: "", null: false
    t.hstore   "info"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "catalog_brands", ["name"], name: "index_catalog_brands_on_name", unique: true, using: :btree

  create_table "catalog_categories", force: :cascade do |t|
    t.string   "name",             default: "",    null: false
    t.string   "slug",             default: "",    null: false
    t.hstore   "info"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "catalog_taxon_id"
    t.boolean  "active",           default: true,  null: false
    t.boolean  "ym_active",        default: false
  end

  add_index "catalog_categories", ["active"], name: "index_catalog_categories_on_active", using: :btree
  add_index "catalog_categories", ["catalog_taxon_id"], name: "index_catalog_categories_on_catalog_taxon_id", using: :btree
  add_index "catalog_categories", ["name"], name: "index_catalog_categories_on_name", using: :btree
  add_index "catalog_categories", ["slug"], name: "index_catalog_categories_on_slug", using: :btree
  add_index "catalog_categories", ["ym_active"], name: "index_catalog_categories_on_ym_active", using: :btree

  create_table "catalog_category_brands", force: :cascade do |t|
    t.integer  "catalog_category_id",             null: false
    t.integer  "catalog_brand_id",                null: false
    t.integer  "position",            default: 0, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "catalog_category_brands", ["catalog_brand_id"], name: "index_catalog_category_brands_on_catalog_brand_id", using: :btree
  add_index "catalog_category_brands", ["catalog_category_id", "catalog_brand_id"], name: "category_brands_index", unique: true, using: :btree
  add_index "catalog_category_brands", ["catalog_category_id"], name: "index_catalog_category_brands_on_catalog_category_id", using: :btree

  create_table "catalog_category_filters", force: :cascade do |t|
    t.integer  "catalog_category_id",             null: false
    t.integer  "catalog_filter_id",               null: false
    t.integer  "position",            default: 0, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "catalog_category_filters", ["catalog_category_id", "catalog_filter_id"], name: "category_filters_index", unique: true, using: :btree
  add_index "catalog_category_filters", ["catalog_category_id"], name: "index_catalog_category_filters_on_catalog_category_id", using: :btree
  add_index "catalog_category_filters", ["catalog_filter_id"], name: "index_catalog_category_filters_on_catalog_filter_id", using: :btree

  create_table "catalog_category_properties", force: :cascade do |t|
    t.integer  "catalog_category_id",             null: false
    t.integer  "catalog_property_id",             null: false
    t.integer  "position",            default: 0, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "catalog_category_properties", ["catalog_category_id", "catalog_property_id"], name: "category_properties_index", unique: true, using: :btree
  add_index "catalog_category_properties", ["catalog_category_id"], name: "index_catalog_category_properties_on_catalog_category_id", using: :btree
  add_index "catalog_category_properties", ["catalog_property_id"], name: "index_catalog_category_properties_on_catalog_property_id", using: :btree

  create_table "catalog_filter_values", force: :cascade do |t|
    t.string   "name",              null: false
    t.integer  "catalog_filter_id", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "display_name"
    t.integer  "position"
  end

  add_index "catalog_filter_values", ["catalog_filter_id"], name: "index_catalog_filter_values_on_catalog_filter_id", using: :btree
  add_index "catalog_filter_values", ["name", "catalog_filter_id"], name: "index_catalog_filter_values_on_name_and_catalog_filter_id", unique: true, using: :btree

  create_table "catalog_filters", force: :cascade do |t|
    t.string   "name",         default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "display_name"
  end

  create_table "catalog_product_filter_values", force: :cascade do |t|
    t.integer  "catalog_product_id",      null: false
    t.integer  "catalog_filter_value_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "catalog_filter_id",       null: false
  end

  add_index "catalog_product_filter_values", ["catalog_filter_id"], name: "index_catalog_product_filter_values_on_catalog_filter_id", using: :btree
  add_index "catalog_product_filter_values", ["catalog_filter_value_id"], name: "index_catalog_product_filter_values_on_catalog_filter_value_id", using: :btree
  add_index "catalog_product_filter_values", ["catalog_product_id", "catalog_filter_value_id"], name: "product_filter_values_index", unique: true, using: :btree
  add_index "catalog_product_filter_values", ["catalog_product_id"], name: "index_catalog_product_filter_values_on_catalog_product_id", using: :btree

  create_table "catalog_product_properties", force: :cascade do |t|
    t.string   "name",                default: "", null: false
    t.integer  "catalog_product_id",               null: false
    t.integer  "catalog_property_id",              null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "position",            default: 0
  end

  add_index "catalog_product_properties", ["catalog_product_id", "catalog_property_id"], name: "product_properties_index", unique: true, using: :btree
  add_index "catalog_product_properties", ["catalog_product_id"], name: "index_catalog_product_properties_on_catalog_product_id", using: :btree
  add_index "catalog_product_properties", ["catalog_property_id"], name: "index_catalog_product_properties_on_catalog_property_id", using: :btree

  create_table "catalog_products", force: :cascade do |t|
    t.string   "name",                default: "",    null: false
    t.string   "slug",                default: ""
    t.string   "model",               default: ""
    t.integer  "catalog_category_id",                 null: false
    t.integer  "catalog_brand_id"
    t.boolean  "fixed_price",         default: false
    t.integer  "price",               default: 0
    t.hstore   "info"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "catalog_products", ["catalog_brand_id"], name: "index_catalog_products_on_catalog_brand_id", using: :btree
  add_index "catalog_products", ["catalog_category_id"], name: "index_catalog_products_on_catalog_category_id", using: :btree
  add_index "catalog_products", ["fixed_price"], name: "index_catalog_products_on_fixed_price", using: :btree
  add_index "catalog_products", ["name"], name: "index_catalog_products_on_name", using: :btree
  add_index "catalog_products", ["price"], name: "index_catalog_products_on_price", using: :btree

  create_table "catalog_properties", force: :cascade do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "catalog_taxons", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "position"
    t.string   "ancestry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "catalog_taxons", ["ancestry"], name: "index_catalog_taxons_on_ancestry", using: :btree

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_id", "assetable_type"], name: "index_ckeditor_assets_on_assetable_id_and_assetable_type", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "name"
    t.text     "body"
    t.boolean  "active",           default: false
    t.integer  "user_id"
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "attachment"
    t.integer  "imageable_id",               null: false
    t.string   "imageable_type",             null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "position",       default: 0
  end

  add_index "images", ["imageable_id", "imageable_type"], name: "index_images_on_imageable_id_and_imageable_type", using: :btree
  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree

  create_table "line_items", force: :cascade do |t|
    t.integer  "quantity",           default: 1, null: false
    t.integer  "price",              default: 0, null: false
    t.integer  "vendor_price",       default: 0, null: false
    t.integer  "catalog_product_id",             null: false
    t.integer  "order_id",                       null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.json     "info"
  end

  add_index "line_items", ["catalog_product_id", "order_id"], name: "line_items_order_product_index", unique: true, using: :btree
  add_index "line_items", ["catalog_product_id"], name: "index_line_items_on_catalog_product_id", using: :btree
  add_index "line_items", ["order_id"], name: "index_line_items_on_order_id", using: :btree
  add_index "line_items", ["vendor_price"], name: "index_line_items_on_vendor_price", using: :btree

  create_table "markups", force: :cascade do |t|
    t.string   "name",        default: "",    null: false
    t.text     "body",                        null: false
    t.hstore   "info"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "slug"
    t.boolean  "active",      default: false
    t.string   "markup_type"
    t.integer  "position",    default: 0
  end

  add_index "markups", ["markup_type"], name: "index_markups_on_markup_type", using: :btree
  add_index "markups", ["name"], name: "index_markups_on_name", unique: true, using: :btree
  add_index "markups", ["slug"], name: "index_markups_on_slug", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.hstore   "info"
    t.datetime "completed_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "state",        default: "in_cart"
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "seos", force: :cascade do |t|
    t.string   "title",        default: "", null: false
    t.string   "keywords",     default: "", null: false
    t.string   "description",  default: "", null: false
    t.integer  "seoable_id",                null: false
    t.string   "seoable_type",              null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "seos", ["seoable_id", "seoable_type"], name: "index_seos_on_seoable_id_and_seoable_type", using: :btree
  add_index "seos", ["seoable_type", "seoable_id"], name: "index_seos_on_seoable_type_and_seoable_id", using: :btree
  add_index "seos", ["seoable_type", "seoable_id"], name: "seo_polymorphic_index", unique: true, using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "user_product_actions", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "action_type"
    t.integer  "user_id"
    t.text     "action"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "user_product_actions", ["action_type"], name: "index_user_product_actions_on_action_type", using: :btree
  add_index "user_product_actions", ["product_id"], name: "index_user_product_actions_on_product_id", using: :btree
  add_index "user_product_actions", ["user_id"], name: "index_user_product_actions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   default: "",         null: false
    t.string   "phone",                  default: "",         null: false
    t.string   "email",                  default: "",         null: false
    t.string   "encrypted_password",     default: "",         null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                   default: "customer", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role"], name: "index_users_on_role", using: :btree

  create_table "vendor_merchants", force: :cascade do |t|
    t.string   "name",       null: false
    t.json     "settings"
    t.hstore   "info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "vendor_merchants", ["name"], name: "index_vendor_merchants_on_name", unique: true, using: :btree

  create_table "vendor_products", force: :cascade do |t|
    t.text     "name",                               null: false
    t.string   "articul",            default: "",    null: false
    t.integer  "vendor_merchant_id",                 null: false
    t.integer  "catalog_product_id"
    t.json     "info"
    t.integer  "price",              default: 0,     null: false
    t.boolean  "in_stock",           default: true,  null: false
    t.boolean  "is_rrc",             default: false, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "trashed",            default: false
    t.boolean  "current_price",      default: true
  end

  add_index "vendor_products", ["articul"], name: "index_vendor_products_on_articul", using: :btree
  add_index "vendor_products", ["catalog_product_id", "vendor_merchant_id"], name: "vendor_products_product_merchant", using: :btree
  add_index "vendor_products", ["catalog_product_id"], name: "index_vendor_products_on_catalog_product_id", using: :btree
  add_index "vendor_products", ["current_price"], name: "index_vendor_products_on_current_price", using: :btree
  add_index "vendor_products", ["in_stock"], name: "index_vendor_products_on_in_stock", using: :btree
  add_index "vendor_products", ["is_rrc"], name: "index_vendor_products_on_is_rrc", using: :btree
  add_index "vendor_products", ["price"], name: "index_vendor_products_on_price", using: :btree
  add_index "vendor_products", ["updated_at"], name: "index_vendor_products_on_updated_at", using: :btree
  add_index "vendor_products", ["vendor_merchant_id"], name: "index_vendor_products_on_vendor_merchant_id", using: :btree

  add_foreign_key "comments", "users"
end
