class ProductsController < CatalogController
  before_action :set_product, only: [:show]

  # GET /products
  # GET /products.json
  def index
    top_products = Catalog::Product.with_price.top_products
    @newest = top_products.select{ |p| p.newest == '1' }
    @homepage = top_products.select{ |p| p.homepage == '1' }
    @hit = top_products.select{ |p| p.hit == '1' }
  end

  def search
    params[:q].each_value { |v| v.strip! } if params[:q]
    @q = Catalog::Product.ransack(params[:q])
    @all_products = @q.result
    @products = @all_products.zeros_last.order('price ASC').page(params[:page])
    respond_to do |format|
      format.html do
        # TODO: hack the fuck
        @grouped_hash = @all_products.select('catalog_products.id').group('catalog_category_id').count
        @grouped_hash = @grouped_hash.map do |k,v|
          [Catalog::Category.select(:id, :name, :slug).find(k), v]
        end
      end
      format.js do
        @products = @products.limit(5)
        render text: render_to_string(partial: 'products/autocomplete_all', locals: { products: @products, query: params[:q]['main_search'] })
      end
    end

  end

  # GET /products/1
  # GET /products/1.json
  def show
    if params[:slug] != @product.slug
      redirect_to p_path(slug: @product.slug, id: @product), status: 301
    end
  end

  def add_comment
    product = Catalog::Product.find(params[:product_id])
    product.comments.create(comment_params)
    redirect_to :back, notice: 'Спасибо, Ваш отзыв успешно добавлен. Он будет отображен на сайте после проверки модератором'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Catalog::Product.find(params[:id])
    end

    def comment_params
      params[:catalog_comment].permit(:body)
    end

end
