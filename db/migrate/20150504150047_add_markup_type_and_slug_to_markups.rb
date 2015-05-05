class AddMarkupTypeAndSlugToMarkups < ActiveRecord::Migration
  def change
    add_column :markups, :slug, :string
    add_column :markups, :active, :boolean, default: false
    add_column :markups, :markup_type, :string
    remove_column :markups, :markupable_id, :integer
    remove_column :markups, :markupable_type, :string
    add_index :markups, :slug
    add_index :markups, :markup_type
  end
end
