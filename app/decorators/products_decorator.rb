class ProductsDecorator
  def initialize(obj)
    @obj = obj
  end

  def update_properties
    return {'#catalog_product_slug': obj.slug} unless obj.seo
    {
      '#catalog_product_slug': obj.slug,
      '#catalog_product_seo_attributes_keywords': obj.seo.keywords,
      '#catalog_product_seo_attributes_description': obj.seo.description
    }
  end
  
  private
  attr_accessor :obj
end
