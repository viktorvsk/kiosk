class Admin::PropertiesController < Admin::BaseController
  before_action :check_content_manager_permissions
  before_action :set_category, only: [:destroy_category_property, :create_category_property]
  before_action :set_product, only: [:update_product_property, :destroy_product_property, :create_product_property]
  before_action :set_property, only: [:edit, :update, :destroy]

  def reorder_category
    @category = Catalog::Category.includes(:category_properties).find(params[:category_id])
    if @category.reorder(params[:properties])
      head 200
    else
      head 400
    end
  end

  def reorder_product
    @product = Catalog::Product.includes(:product_properties).find(params[:product_id])
    if @product.reorder(params[:properties])
      current_user.record!(@product, 'Отредактировал', "Переместил характеристику")

      head 200
    else
      head 400
    end
  end

  def reorder_category_all
    @category.reorder_all
  end

  def destroy_category_property
    if @category.category_properties.find(params[:id]).destroy
      head 200
    else
      head 400
    end
  end

  def create_category_property
    property = Catalog::Property.where(name: params[:catalog_property][:name]).first_or_create
    cat_prop = @category.category_properties.where(property: property).first_or_initialize
    if cat_prop.new_record? && cat_prop.save
      @property = cat_prop
    else
      head 400 and return
    end
  end

  def update_product_property
    p_p = @product.product_properties.find(params[:id])
    if p_p.modify!(params[:catalog_product_property][:property_name], params[:catalog_product_property][:name])
      @id = p_p.reload.property.id.to_s
      current_user.record!(@product, 'Отредактировал', "Характеристика <b>#{p_p.property_name}</b>: #{p_p.name}")
    else
      head 400
    end
  end

  def create_product_property
    if @property = @product.product_properties.create(product_property_params)
    else
      head 400
    end
  end

  def destroy_product_property
    if @product.product_properties.find(params[:id]).destroy
      head 200
    else
      head 400
    end
  end

  def index
    @properties = Catalog::Property.all.page(params[:page])
  end

  def new
    @property = Catalog::Property.new
  end

  def create
    @property = Catalog::Property.create(catalog_property_params)
    if @property.save
      redirect_to admin_properties_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @property.update(catalog_property_params)
      redirect_to admin_properties_path
    else
      render 'edit'
    end
  end

  def destroy
    @property.destroy
    redirect_to admin_properties_path
  end
  
  private

  def set_category
    @category = Catalog::Category.find(params[:category_id])
  end

  def set_product
    @product = Catalog::Product.find(params[:product_id])
  end

  def set_property
    @property = Catalog::Property.find(params[:id])
  end

  def product_property_params
    params.require(:catalog_product_property).permit(:name, :property_name)
  end

  def catalog_property_params
    params.require(:catalog_property).permit(:name)
  end
end
