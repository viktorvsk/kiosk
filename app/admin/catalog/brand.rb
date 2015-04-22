ActiveAdmin.register Catalog::Brand do
  actions :all, except: [:show]
  filter :name
  menu parent: 'Каталог'
  permit_params :name, :slug, :description, image_attributes: [:attachment]

  index do
    selectable_column
    column :name
    actions
  end

  form do |f|
    inputs 'Детали' do
      input :name
      input :slug
      input :description, as: :text
    end
    f.object.build_image unless f.object.image
    f.has_many :image, heading: 'Изображение', allow_destroy: false, new_record: false do |i|
      i.input :attachment, as: :file, hint: image_tag(f.object.image.try(:attachment))
    end
    actions
  end
end
