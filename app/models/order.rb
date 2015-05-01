class Order < ActiveRecord::Base

  store_accessor :info, :phone, :name, :address, :comment
  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items

  PHONE_OPERATORS = %w(63 93 50 97 96 572).join('|')
  validates :phone, format: { with: /\A(380)(#{PHONE_OPERATORS})\d{6,7}\Z/ }, allow_blank: true
  before_validation :strip_phone

  scope :in_cart, -> { where(state: 'in_cart') }
  belongs_to :user


  def add_product(product, quantity=1)
    product = product.kind_of?(Catalog::Product) ? product : Catalog::Product.where(id: product).first
    if product
      if already_added = line_items.detect{ |li| li.product == product }
        already_added.increment! :quantity, quantity
      else
        line_items.create(product: product, quantity: quantity)
      end
    else
      false
    end

  end

  def ready?
    valid? && %w(name phone address).all?{ |field| self.send(field).present? }
  end

  def total_sum
    if state == 'in_cart'
      line_items.map{ |li| li.product.price * li.quantity }.sum
    else
      line_items.map{ |li| li.price * li.quantity }.sum
    end
  end

  def format_phone
    ActionController::Base.helpers.number_to_phone(phone[3..-1], country_code: 380)
  end

  private

  def strip_phone
    return if new_record? || (p = self[:info]["phone"].to_s).blank?
    p.gsub!(/[^\d]/, '')
    unless p =~ /\A38/
      p = "38#{p}"
    end
    self.phone = p
  end
end
