ActiveAdmin.register Catalog::Taxon do
  actions :all, except: [:show]
  menu parent: 'Каталог'
  filter :name
  sortable tree: true,
           max_levels: 0,               # infinite indent levels
           protect_root: false,         # allow root items to be dragged
           sorting_attribute: :position,
           parent_method: :parent,
           children_method: :children,
           roots_method: :roots,
           roots_collection: nil,       # proc to specifiy retrieval of roots
           collapsible: true,          # show +/- buttons to collapse children
           start_collapsed: true
  permit_params :name, :slug, image_attributes: [:attachment]

  index :as => :sortable do
    label :name # item content
    actions
  end

  form do |f|
    inputs 'Детали' do
      input :name
      input :slug
    end
    f.object.build_image unless f.object.image
    f.has_many :image, heading: 'Изображение', allow_destroy: false, new_record: false do |i|
      i.input :attachment, as: :file, hint: image_tag(f.object.image.try(:attachment))
    end
    actions
  end
end
