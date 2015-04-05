namespace :catalog do
  namespace :product do

    desc 'Import products from JSON files from tmp/products_json/*.json'
    task import: :environment do
      files = Dir.glob Rails.root.join('tmp/products/*.json')
      files.each do |file|
        products = JSON.parse File.read file
        products.map!{ |product| Catalog::Product.new(product) rescue nil }.compact!
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
        Catalog::Product.destroy_all
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
