class ProductsController < CatalogController
  before_action :set_product, only: [:show, :super_instant_checkout]

  def index
    top_products = Catalog::Product.with_price.top_products
    @newest = top_products.select{ |p| p.newest == '1' }
    @homepage = top_products.select{ |p| p.homepage == '1' }
    @hit = top_products.select{ |p| p.hit == '1' }
    @meta_title = Conf['kiosk_meta_title']
    @meta_keywords = Conf['kiosk_meta_description']
    @meta_description = Conf['kiosk_meta_keywords']
  end

  def search
    params[:q].each_value { |v| v.strip! } if params[:q]
    @q = Catalog::Product.ransack(params[:q])
    @all_products = @q.result.with_price.includes(:seo, :category, :brand)
    @products = @all_products.zeros_last.order('price ASC').page(params[:page])
    respond_to do |format|
      format.html do
        # TODO: hack the fuck
        @grouped_hash = @all_products.select('catalog_products.id').group('catalog_category_id').count
        @grouped_hash = @grouped_hash.map do |k,v|
          [Catalog::Category.select(:id, :name, :slug, :info).find(k), v]
        end
      end
      format.js do
        @products = @products.limit(5)
        render text: render_to_string(partial: 'products/lists/autocomplete', locals: { products: @products, query: params[:q]['main_search'] })
      end
    end

  end

  def show
    if params[:slug] != @product.slug
      redirect_to p_path(slug: @product.slug, id: @product), status: 301
      return
    end
    respond_to do |format|
      format.html do
        top_products = Catalog::Product.includes(:seo, :category, :brand).with_price.top_products
        @newest = top_products.select{ |p| p.newest == '1' }
        @homepage = top_products.select{ |p| p.homepage == '1' }
        @hit = top_products.select{ |p| p.hit == '1' }
        @meta_title = presents(@product).seo_meta_title
        @meta_keywords = @product.seo.try(:keywords)
        @meta_description = presents(@product).seo_meta_descr
        render layout: 'product_card'
      end
      format.js
    end
  end

  def add_comment
    product = Catalog::Product.find(params[:product_id])
    product.comments.create(comment_params)
    redirect_to :back, notice: 'Спасибо, Ваш отзыв успешно добавлен. Он будет отображен на сайте после проверки модератором'
  end

  private

    def set_product
      @product = Catalog::Product.find(params[:id])
    end

    def comment_params
      params[:catalog_comment].permit(:body)
    end

end
