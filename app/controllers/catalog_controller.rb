class CatalogController < ApplicationController
  def static_page
    @page = Markup.pages_and_articles.find(params[:id])
    render 'markups/_page', locals: { page: @page }
  end

  def help_pages
    @pages = Markup.active.helps
    @page = @pages.sample
    render 'markups/helps'
  end

  def show_help_page
    @pages = Markup.active.helps
    @page = Markup.active.helps.find(params[:id])
    render 'markups/helps'
  end

  def help_page
    render 'markups/_page', locals: { page: @page }
  end

  def robots
    render text: Conf['txt.robots']
  end

  def sitemap
    categories = Catalog::Category.select(:id, :slug, :updated_at, :name)
    products = Catalog::Product.bound.with_price.select(:id, :name, :slug, :updated_at).uniq
    pages = Markup.active.pages_and_articles.select(:id, :name, :slug, :updated_at)
    helps = Markup.active.helps.select(:id, :name, :slug, :updated_at)
    render 'catalog/sitemap.xml', layout: false, locals: { categories: categories, products: products, helps: helps, pages: pages }
  end

  def price
    categories = Catalog::Category.select(:id, :name).includes(:products)
    render 'catalog/price.xml', layout: false, locals: { categories: categories }
  end

end
