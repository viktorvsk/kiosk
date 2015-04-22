namespace :catalog do

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
        print 'Deleting products...'
        t1 = Time.now
        Catalog::Product.destroy_all
        t2 = (Time.now - t1).round(2)
        print " Deleted in #{t2}.\n"
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
