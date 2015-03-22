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
            rescue Exception
              invalid += 1
            end
          end

        end
        puts "Imported #{products.count - invalid} products in #{(Time.now - t1).to_i } seconds"


      end
    end

    desc 'Reset catalog'
    task reset: :environment do
      Catalog::Product.destroy_all
    end

  end
end
