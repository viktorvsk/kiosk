namespace :vendor do

  desc 'Reset and Seed Vendors and Vendor Products'
  task reseed: :environment do
    Rake::Task['vendor:reset'].invoke
    Rake::Task['vendor:seed'].invoke
    Rake::Task['vendor:product:seed'].invoke
  end

  desc 'Create default Vendors'
  task seed: :environment do
    vendors_params = [
      {
        name: 'DC-link',
        email: 'email@dclink.com',
        format: 'xlsx',
        f_start: '1',
        f_model: '9',
        f_name: '3',
        f_code: '11',
        f_usd: '5',
        f_uah: '6',
        f_not_in_stock: '8',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json

      },
      {
        name: 'Brain',
        email: 'email@brain.com',
        format: 'xlsx',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json,
        f_start: '1',
        f_model: '7',
        f_name: '7',
        f_code: '2',
        f_usd: '9',
        f_not_in_stock: '16'
      },
      {
        name: 'MTI',
        email: 'email@mti.com',
        format: 'xlsx',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json,
        f_start: '1',
        f_model: '3',
        f_name: '4',
        f_code: '2',
        f_category: '1',
        f_warranty: '7',
        f_brand: '6',
        f_usd: '9',
        f_uah: '8'

      },
      {
        name: 'ERC',
        email: 'email@erc.com',
        format: 'xml',
        encoding: 'windows-1251',
        parser_class: 'Erc',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json,
        f_start: '//goods',
        f_model: 'code/text()',
        f_name: 'gname/text()',
        f_code: 'code/text()',
        f_usd: 'sprice/text()',
        f_uah: 'rprce/text()',
        f_warranty: 'warr/text()',
        f_not_in_stock: 'swh/text()',
        f_monitor: 'monitor/text()',
        f_ddp: 'ddp/text()'

      },
      {
        name: 'Швейка',
        email: 'email@shveika.com',
        format: 'xlsx',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json,
        f_start: '1',
        f_model: '2',
        f_name: '2',
        f_code: '2',
        f_usd: '4',
        f_rrc: '7',
        f_not_in_stock: '5'
      },
      {
        name: 'Акустика',
        email: 'email@akustika.ua',
        discount: '26',
        format: 'xlsx',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json,
        f_start: '3',
        f_model: '8',
        f_name: '6',
        f_code: '9',
        f_uah: '12'

      },
      {
        name: 'Техномастер',
        email: 'email@tm.ua',
        format: 'xlsx',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json,
        f_start: '9',
        f_model: '4',
        f_name: '4',
        f_code: '1',
        f_uah: '5',
        f_not_in_stock: '6'
      },
      {
        name: 'Рейнколд',
        email: 'email@ranekold.com',
        format: 'xlsx',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json,
        f_start: '2',
        f_name: '3',
        f_model: '3',
        f_code: '7',
        f_brand: '2',
        f_category: '1',
        f_uah: '4',
        f_rrc: '5'

      },
      {
        name: 'Технотрейд',
        email: 'email@techtrade.ua',
        format: 'xlsx',
        parser_class:  'Technotrade',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json,
        f_start: '2',
        f_name: '3',
        f_model: '3',
        f_code: '7',
        f_uah_1: '3',
        f_uah_2: '4',
        f_rrc: '5',
        f_brand: '2',
        f_category: '1'
      },
      {
        name: 'Юг Контракт',
        email: 'email@yugcontract.com',
        format: 'xlsx',
        parser_class: 'Yug',
        currency_rates: {
          uah: 1,
          rrc: 1,
          usd: 24.5,
          eur: 26.5
        }.to_json,
        f_start: '1',
        f_model: '5',
        f_name: '6',
        f_code: '4',
        f_usd: '15',
        f_uah: '16',
        f_rrc: '32',
        f_stock_kharkov: '9',
        f_stock_kiev: '10'

      }
    ]
    vendors = Vendor::Merchant.create!(vendors_params)
    puts "Created #{vendors.count.to_s} new vendors."
  end

  desc 'Destroy all Vendors'
  task reset: :environment do
    Vendor::Merchant.destroy_all
    puts 'All Vendors destroyed'
  end

  namespace :product do

    desc 'Create default Vendor::Products'
    task seed: :environment do
      Vendor::Merchant.find_each do |merchant|
        file_path = Rails.root.join('spec', 'support', "#{merchant.name}.#{merchant.format}")
        print "#{merchant.name} "
        print ' '*(20 - merchant.name.size)
        t1 = Time.now
        Vendor::Pricelist.new(merchant.id, file_path).import!
        time = Time.now - t1
        print " #{time.to_f.round(1)} sec\n"
      end
    end
  end
end
