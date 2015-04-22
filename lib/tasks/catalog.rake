namespace :catalog do

  desc 'Reset secondary data'
  task reset_secondary: :environment do
    Catalog::Filter.destroy_all
    puts 'Deleted all filters (including filter values and product filters and category filters and filter values)'
    Catalog::Property.destroy_all
    puts 'Deleted poperties, category properties, product properties and property values'
  end

  namespace :product do

    desc 'Import only filters'
    task import_filters: :environment do
      files = Dir.glob Rails.root.join('tmp/products/*.json')
      files.each do |file|
        products = JSON.parse File.read file
        products.map do |product|
          next unless product['filters'].present?
          begin
            Catalog::Product.where(name: product['name']).first.update(filters: product['filters'])
            print '+'
          rescue
            print '-'
          end

        end
      end
    end

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
