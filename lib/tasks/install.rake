namespace :kiosk do
  desc 'Install tasks'
  task install: :environment do
    Rake::Task['catalog:product:reset'].invoke
    Rake::Task['catalog:vendor:reset'].invoke
    Rake::Task['catalog:product:import'].invoke
    Rake::Task['catalog:category:copy_properties'].invoke
    Rake::Task['vendor:seed'].invoke
    Rake::Task['vendor:product:seed'].invoke
  end
end
