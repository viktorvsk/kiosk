class CreateSeos < ActiveRecord::Migration
  def change
    create_table :seos do |t|
      t.string :title, null: false, default: ''
      t.string :keywords, null: false, default: ''
      t.string :description, null: false, default: ''
      t.references :seoable, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end

    add_index :seos, [:seoable_type, :seoable_id], unique: true, name: :seo_polymorphic_index
  end
end
