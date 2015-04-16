class Vendor::Merchant < ActiveRecord::Base
  store_accessor :info,
    :discount, :email, :description, :pricelist_state,
    :pricelist_error, :last_price_date
  store_accessor :settings,
   :f_start, :f_model, :f_name, :f_code, :f_usd,
   :f_uah, :f_rrc, :f_eur, :f_not_in_stock, :f_delivery_tax,
   :encoding, :format, :parser_class,
   :required, :currency_order, :currency_rates, :not_in_stock,
   :f_uah_1, :f_uah_2, :f_monitor, :f_ddp, :f_stock_kharkov, :f_stock_kiev,
   :f_brand, :f_warranty, :f_category
  validates :name, presence: true, uniqueness: true
  validates :currency_rates, :required, :currency_order, :not_in_stock,
    json: true,
    allow_blank: true
  has_many :products, class_name: Vendor::Product, foreign_key: :vendor_merchant_id, dependent: :delete_all
  has_many :catalog_products, class_name: Catalog::Product, through: :products, source: :product
  CUSTOM = [
    %w( Обычный Default ),
    %w( ERC Erc ),
    %w( Рейнколд Ranecold ),
    %w( Технотрейд Technotrade ),
    %w( ЮГ-Контракт Yug )
  ]

  def to_partial_path
    "admin/#{super}"
  end

  def rates
    JSON.parse(currency_rates).slice('usd', 'eur').map{ |k, v| "#{k}: #{v}" }.join(', ')
  end

  def pricelist_path
    Rails.root.join('app', 'price_lists', "#{id}.#{format}")
  end

  def to_activepricelist
    rates = currency_rates.kind_of?(String) ? JSON.parse(currency_rates) : currency_rates
    settings = {
      'start'           => f_start,
      'format'          => format,
      'file'            => pricelist_path,
      'encoding'        => encoding,
      'rates'           => rates,
      'currency_order'  => currency_order,
      'required'        => required,
      'not_in_stock'    => not_in_stock,
      'discount'        => discount,
      'columns'         => {
        # Main
        'model'         => f_model,
        'name'          => f_name,
        'articul'       => f_code,
        'usd'           => f_usd,
        'uah'           => f_uah,
        'rrc'           => f_rrc,
        'eur'           => f_eur,
        'not_in_stock'  => f_not_in_stock,
        'delivery_tax'  => f_delivery_tax,
        # Custom
        'uah_1'         => f_uah_1,
        'uah_2'         => f_uah_2,
        'monitor'       => f_monitor,
        'ddp'           => f_ddp,
        'stock_kharkov' => f_stock_kharkov,
        'stock_kiev'    => f_stock_kiev
      }
    }

    settings.reject!{ |k, v| v.blank? }
    settings['columns'].reject!{ |k, v| v.blank? }
    settings
  end

end
