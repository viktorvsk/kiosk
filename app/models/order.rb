class Order < ActiveRecord::Base
  STATES = ['in_cart', 'unknown', 'checkout', 'completed']
  store_accessor :info, :phone, :name, :address, :comment,
    :payment_type, :delivery_type, :status
  belongs_to :user
  has_many :products, through: :line_items
  has_many :line_items, dependent: :destroy

  PHONE_OPERATORS = %w(63 93 50 97 96 572).join('|')
  validates :phone, format: { with: /\A(380)(#{PHONE_OPERATORS})\d{6,7}\Z/ }, allow_blank: true
  before_validation :strip_phone

  scope :in_cart, -> { where("orders.state = 'in_cart' AND user_id IS NOT NULL") }
  scope :unknown, -> { where(user: nil) }
  scope :completed, -> { where("orders.completed_at IS NOT NULL AND orders.state = 'payd'") }
  scope :checkout, -> { where(state: 'checkout') }
  scope :by_month, -> (month) { where('created_at >= ? AND created_at <= ?', Date.new(Date.today.year, month.to_i, 1), Date.new(Date.today.year, month.to_i, 1).end_of_month) }

  accepts_nested_attributes_for :line_items, allow_destroy: true
  accepts_nested_attributes_for :user

  class << self
    def ransackable_scopes(auth_object = nil)
      [:by_month, :by_state]
    end

    def by_state(state)
      return false unless state.to_s.in?(STATES)
      all.send(state)
    end

    def payment_types
      Conf['txt.payment_types'].split("\n").map(&:strip)
    end

    def delivery_types
      Conf['txt.delivery_types'].split("\n").map(&:strip)
    end
  end

  def order_product=(product_id)
    add_product(product_id)
  end

  def order_product
  end

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

  def comment=(value)
    txt = self.info['comment'].to_s << "<br/>#{value}"
    super(txt)
  end

  def comment
    ""
  end

  def items_count
    line_items.map(&:quantity).sum
  end

  def ready?
    valid? && %w(name phone address).all?{ |field| self.send(field).present? }
  end

  def total_sum
    if state == 'checkout'
      line_items.includes(:product).map{ |li| li.price * li.quantity }.sum
    else
      line_items.includes(:product).map{ |li| li.product.price * li.quantity }.sum
    end
  end

  def total_income
    line_items.includes(:product).map{ |li| li.income }.sum
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
