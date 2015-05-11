namespace :catalog do

  desc 'Update Sitemap nad Site pricelist'
  task :hourly_update => :environment do
    Rake::Task['catalog:update_sitemap'].invoke
    Rake::Task['catalog:update_pricelist'].invoke
    Rake::Task['catalog:auto_update_prices'].invoke
  end

  desc 'Update Sitemap'
  task :update_sitemap => :environment do
    categories = Catalog::Category.select(:id, :slug, :updated_at, :name)
    products = Catalog::Product.bound.with_price.select(:id, :name, :slug, :updated_at).uniq
    pages = Markup.active.pages_and_articles.select(:id, :name, :slug, :updated_at)
    helps = Markup.active.helps.select(:id, :name, :slug, :updated_at)
    sitemap = ActionController::Base.new.render_to_string("catalog/sitemap", locals: { categories: categories, products: products, helps: helps, pages: pages })
    File.open(Rails.public_path.join('sitemap.xml'), 'w'){ |f| f.puts sitemap }
  end

  desc 'Update Pricelist'
  task update_pricelist: :environment do
    categories = Catalog::Category.select(:id, :name).includes(:products)
    pricelist = ActionController::Base.new.render_to_string("catalog/price", locals: { categories: categories })
    File.open(Rails.public_path.join('price.xml'), 'w'){ |f| f.puts pricelist }
  end

  desc 'Auto upadte prices'
  task auto_update_prices: :environment do
    merchants = Vendor::Merchant.auto_updateable
    merchants.each do |m|
      klass = "#{m.parser_class}Parser".classify.constantize
      klass.auto_update(m.id)
      puts "Done #{m.name}"
    end
  end

  desc 'Reset secondary data'
  task reset_secondary: :environment do
    Catalog::Filter.destroy_all
    puts 'Deleted all filters (including filter values and product filters and category filters and filter values)'
    Catalog::Property.destroy_all
    puts 'Deleted poperties, category properties, product properties and property values'
  end

  desc 'Import Taxons from JSON file'
  task import_taxons: :environment do
    taxons = JSON.parse File.read Rails.root.join('tmp', 'taxons.json')
    taxons.each do |taxon|
      parent = if taxon['parent'].present?
        Catalog::Taxon.where(name: taxon['parent']).first_or_create!
      end
      Catalog::Taxon.where(name: taxon['name']).first_or_create.update(parent: parent)
      print '+'
    end
    print "\n"
  end

  desc 'Import Images from JSON file'
  task import_images: :environment do
    files = Dir.glob Rails.root.join('tmp/products/*.json')
    files.each do |file|
      products = JSON.parse File.read file
      products.select{ |p| p['images'].present? }.each do |product|
        prod = Catalog::Product.where(name: product['name']).first
        if prod.present? && prod.images.blank?
          begin
            prod.update!(evotex_images: product['images'])
            print '+'
          rescue
            print '-'
          end
        end
      end

    end
    print "\n"
  end

  desc 'Import Categories from JSON file'
  task import_categories: :environment do
    categories = JSON.parse File.read Rails.root.join('tmp', 'prototypes.json')
    categories.each do |category|
      cat = Catalog::Category.where(name: category['name']).first_or_create
      if category['taxon'].present?
        category['catalog_taxon_id'] = Catalog::Taxon.find_by_name(category['taxon']).id
      end
      cat.update(category.except('taxon', 'seo'))
      cat.build_seo unless cat.seo
      cat.seo.update(category['seo']) rescue nil
      print '+'
    end
    print "\n"
  end


  desc 'Import only filters'
  task import_filters: :environment do
    files = Dir.glob Rails.root.join('tmp/products/*.json')
    files.each do |file|
      products = JSON.parse File.read file
      products.map do |product|
        next unless product['filters'].present?
        begin
          p = Catalog::Product.where(name: product['name']).first
          if p.present?
            p.update(filters: product['filters'])
            print '+'
          else
            print '.'
          end
        rescue
          print '-'
        end
      end
    end
  end

  namespace :product do

    desc 'Import products from JSON files from tmp/products_json/*.json'
    task import: :environment do
      files = Dir.glob Rails.root.join('tmp/products/*.json')
      files.each do |file|
        products = JSON.parse File.read file
        products.map! do |product|
          if product['images'].present?
            product['evotex_images'] = product['images']
            product.delete('images')
          end
          Catalog::Product.new(product)
        end
        t1 = Time.now
        invalid = 0
        Catalog::Product.transaction do
          products.each do |product|
            begin
              product.save!
            rescue ActiveRecord::RecordInvalid
              invalid += 1
            end
            print '+'
          end

        end
        puts "\nImported #{products.count - invalid} products in #{(Time.now - t1).to_i } seconds\n"


      end
    end



    desc 'Reset catalog'
    task reset: :environment do

      Catalog::Product.transaction do
        puts 'Destroying products'
        Catalog::Product.destroy_all
        puts 'Destroying properties'
        Catalog::Property.destroy_all
        puts 'Destroying filters'
        Catalog::Filter.destroy_all
        puts 'Destroying categories'
        Catalog::Category.destroy_all
        puts 'Destroying taxons'
        Catalog::Taxon.destroy_all
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
