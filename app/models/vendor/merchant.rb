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
   :f_dclink_ddp, :f_brand, :f_warranty, :f_category, :f_stock_dclink
  validates :name, presence: true, uniqueness: true
  validates :currency_rates, :currency_order, :required, :not_in_stock, :currency_order, :not_in_stock,
    json: true,
    allow_blank: true
  has_many :products, class_name: Vendor::Product, foreign_key: :vendor_merchant_id, dependent: :delete_all
  has_many :catalog_products, class_name: Catalog::Product, through: :products, source: :product
  CUSTOM = [
    %w( Обычный Default ),
    %w( ERC Erc ),
    %w( DC-Link Dclink ),
    %w( Технотрейд Technotrade ),
    %w( ЮГ-Контракт Yug ),
    %w( DC-Link(XML) Dclinkxml ),
    %w( Akustika(XML) Akustikaxml ),
    %w( Timautoxml Timautoxml )
  ]

  def self.auto_updateable
    ids = all.select{ |m| "#{m.parser_class}Parser".classify.constantize.respond_to?(:auto_update) rescue false }.map(&:id)
    where(id: ids)
  end

  def self.oldest_price
    all.map{ |m| DateTime.parse(m.last_price_date) rescue nil }.compact.sort.first
  end

  def self.newest_price
    all.map{ |m| DateTime.parse(m.last_price_date) rescue nil }.compact.sort.last
  end

  def self.special
    ids = all.select{ |m| m.parser_class != 'Default' }
    where(id: ids)
  end

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
    curr_order = currency_order.presence ||'[]'
    curr_order_json = JSON.parse(curr_order)
    rates = currency_rates.kind_of?(String) ? JSON.parse(currency_rates) : currency_rates
    nst = if not_in_stock.present?
      not_in_stock.kind_of?(String) ? JSON.parse(not_in_stock) : not_in_stock
    end
    settings = {
      'start'           => f_start,
      'format'          => format,
      'file'            => pricelist_path,
      'encoding'        => encoding,
      'rates'           => rates,
      'currency_order'  => curr_order_json,
      'required'        => required,
      'not_in_stock'    => nst,
      'discount'        => discount,
      'dclink_ddp'      => f_dclink_ddp,
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
        'stock_kiev'    => f_stock_kiev,
        'stock_dclink'  => f_stock_dclink
      }
    }

    settings.reject!{ |k, v| v.blank? }
    settings['columns'].reject!{ |k, v| v.blank? }
    settings
  end

end
