ActiveAdmin.register Catalog::Taxon do
  actions :all, except: [:show]
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
  permit_params :name, :slug

  index :as => :sortable do
    label :name # item content
    actions
  end
end
