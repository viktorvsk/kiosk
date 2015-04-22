namespace :kiosk do
  desc 'Install tasks'
  task install: :environment do
    Rake::Task['catalog:product:reset'].invoke
    Rake::Task['vendor:reset'].invoke
    puts 'Destroying properties'
    Catalog::Property.destroy_all
    puts 'Destroying filters'
    Catalog::Filter.destroy_all
    puts 'Destroying categories'
    Catalog::Category.destroy_all
    puts 'Destroying taxons'
    Catalog::Taxon.destroy_all
    Rake::Task['catalog:product:import'].invoke
    Rake::Task['catalog:import_taxons'].invoke
    Rake::Task['catalog:import_categories'].invoke
    Rake::Task['catalog:category:copy_properties'].invoke
    Rake::Task['vendor:seed'].invoke
    Rake::Task['vendor:product:seed'].invoke
  end
end
