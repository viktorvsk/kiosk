namespace :catalog do

  desc 'Update Sitemap nad Site pricelist'
  task :hourly_update => :environment do
    Rake::Task['catalog:update_sitemap'].invoke
    Rake::Task['catalog:auto_update_prices'].invoke
  end

  desc 'Update Sitemap'
  task :update_sitemap => :environment do
    categories = Catalog::Category.select(:id, :slug, :updated_at, :name)
    products = Catalog::Product.with_price.select(:id, :name, :slug, :updated_at).uniq
    pages = Markup.active.pages_and_articles.select(:id, :name, :slug, :updated_at)
    helps = Markup.active.helps.select(:id, :name, :slug, :updated_at)
    sitemap = ActionController::Base.new.render_to_string("catalog/sitemap", locals: { categories: categories, products: products, helps: helps, pages: pages })
    File.open(Rails.public_path.join('sitemap.xml'), 'w'){ |f| f.puts sitemap }
  end

  desc 'Update Pricelist'
  task update_pricelist: :environment do
    warranty_id = Catalog::Property.warranty.try(:id)
    pricelist = ActionController::Base.new.render_to_string("catalog/price", locals: {
                                                                                categories: Catalog::Category.pricelist_association,
                                                                                warranty_id: warranty_id,
                                                                                offer_available: 'true',
                                                                                price_multiplier: 1.00
                                                                              })
    File.open(Rails.public_path.join('price_full.xml'), 'w'){ |f| f.puts pricelist }

    # Repeat for Yandex Market
    pricelist = ActionController::Base.new.render_to_string("catalog/price", locals: {
                                                                                categories: Catalog::Category.pricelist_association.yandex_market,
                                                                                warranty_id: warranty_id,
                                                                                offer_available: 'false',
                                                                                price_multiplier: 1.00
                                                                              })
    File.open(Rails.public_path.join('price_yandex.xml'), 'w'){ |f| f.puts pricelist }

  end

  desc 'Auto update prices'
  task auto_update_prices: :environment do
    merchants = Vendor::Merchant.auto_updateable
    merchants.each do |m|
      klass = "#{m.parser_class}Parser".classify.constantize
      klass.auto_update(m.id)
      puts "Done #{m.name}"
    end
  end

  namespace :product do

    desc 'Match vendor category to catalog category'
    task :vendor_category => :environment do
      categories = Catalog::Category.joins(:aliases).includes(:aliases).all.to_a
      products = Catalog::Product.where("(info->'vendor_category') IS NOT NULL")
      products.map do |product|
        category = categories.detect do |c|
          aliases = c.aliases.map{ |a| a.name.mb_chars.downcase.to_s.strip } + [c.name.mb_chars.downcase.to_s.strip]
          product.vendor_category.mb_chars.downcase.strip.to_s.in?(aliases)
        end
        if category
          product.category = category
        end
        product
      end
      Catalog::Product.transaction do
        products.map(&:save)
      end
    end
  end

  namespace :category do

    desc 'Create category properties from product properties'
    task copy_properties: :environment do
      puts 'started'
      t1 = Time.now
      products = Catalog::Product
                     .joins(:properties, :category)
                     .includes(category: :properties)
                     .uniq
                     .find_each do |product|
        product.copy_properties_to_category
        print '+'
      end
      puts = "Finished in #{(Time.now - t1).round(2)} seconds"
    end
  end
end
