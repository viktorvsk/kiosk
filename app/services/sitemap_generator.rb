class SitemapGenerator
  @queue = :common

  def self.perform
    categories = Catalog::Category.select(:id, :slug, :updated_at, :name)
    products = Catalog::Product.with_price.select(:id, :name, :slug, :updated_at).uniq
    pages = Markup.active.pages_and_articles.select(:id, :name, :slug, :updated_at)
    helps = Markup.active.helps.select(:id, :name, :slug, :updated_at)
    sitemap = ActionController::Base.new.render_to_string('catalog/sitemap',
                                                          locals: {
                                                            categories: categories,
                                                            products: products,
                                                            helps: helps,
                                                            pages: pages
                                                          })
    File.open(Rails.public_path.join('sitemap.xml'), 'w'){ |f| f.puts sitemap }
  end
end
