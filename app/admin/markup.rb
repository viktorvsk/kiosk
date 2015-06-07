ActiveAdmin.register Markup do
  menu parent: 'Настройки'
  actions :all, except: [:show]
  permit_params :name, :active, :slug, :body, :markup_type, :position, seo_attributes: [:title, :description, :keywords]
  scope "Активные", :active
  Markup::TYPES.each do |m|
    scope I18n.t("activerecord.attributes.markup.types.#{m.pluralize}"), m.pluralize
  end

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :position
    column :active
    column :markup_type do |markup|
      t("activerecord.attributes.markup.types.#{markup.markup_type}")
    end
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    inputs "Детали" do
      f.input :name
      f.input :active
      f.input :slug
      f.input :position
      f.input :markup_type, as: :select, collection: Markup::TYPES.map{ |m| [t("activerecord.attributes.markup.types.#{m}"), m] }, include_blank: false
      f.input :body, as: :ckeditor, input_html: { ckeditor: { language: :ru } }
    end

    inputs "SEO" do
      f.object.build_seo unless f.object.seo
      f.has_many :seo, heading: 'Мета теги', allow_destroy: false, new_record: false do |i|
        i.input :title
        i.input :description
        i.input :keywords
      end
    end
    actions
  end
end
