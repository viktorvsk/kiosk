namespace :kiosk do
  desc 'Install tasks'
  task install: :environment do
    Rake::Task.invoke['catalog:product:reset']
    Rake::Task.invoke['catalog:vendor:reset']
    Rake::Task.invoke['catalog:product:import']
    Rake::Task.invoke['catalog:category:copy_properties']
    Rake::Task.invoke['vendor:seed']
    Rake::Task.invoke['vendor:product:seed']
  end
end
