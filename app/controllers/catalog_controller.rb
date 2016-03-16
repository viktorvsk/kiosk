class CatalogController < ApplicationController
  before_action :set_comparing_products

  def static_page
    @page = Markup.pages_and_articles.find(params[:id])
    @meta_title = @page.seo.try(:title)
    @meta_keywords = @page.seo.try(:keywords)
    @meta_description = @page.seo.try(:description)
    render 'markups/_page', locals: { page: @page }
  end

  def help_pages
    @pages = Markup.active.helps
    @page = @pages.sample
    @meta_title = @page.seo.try(:title)
    @meta_keywords = @page.seo.try(:keywords)
    @meta_description = @page.seo.try(:description)
    render 'markups/helps'
  end

  def show_help_page
    @pages = Markup.active.helps
    @page = Markup.active.helps.find(params[:id])
    @meta_title = @page.seo.try(:title)
    @meta_keywords = @page.seo.try(:keywords)
    @meta_description = @page.seo.try(:description)
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
    categories = Catalog::Category.pricelist_association
    warranty_id = Catalog::Property.warranty.try(:id)
    render 'catalog/price.xml', layout: false, locals: { categories: categories, warranty_id: warranty_id, 
                                                                                 products_count: products_count }
  end

  def set_comparing_products
    @comparing_products = session[:comparing_ids].to_s.split.map(&:to_s)
  end

end
