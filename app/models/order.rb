class Order < ActiveRecord::Base
  STATES = %w{in_cart checkout completed deny in_cart_products}
  store_accessor :info, :phone, :name, :address, :comment,
    :payment_type, :delivery_type, :delivery_cost, :creation_way
  belongs_to :user
  has_many :products, through: :line_items
  has_many :line_items, dependent: :destroy

  # PHONE_OPERATORS = %w(63 93 50 97 96 572).join('|')
  # validates :phone, format: { with: /\A(380)(#{PHONE_OPERATORS})\d{6,7}\Z/ }, allow_blank: true
  validates :phone, format: { with: /\A(380)\d{9}\Z/ }, allow_blank: true
  before_validation :strip_phone

  #scope :payd, -> { where(state: 'payd') }
  #scope :unknown, -> { where(user: nil) }
  scope :in_cart,   -> { includes(:line_items).where(line_items: { order_id: nil }, orders: {state: 'in_cart'}) }
  scope :in_cart_products,   -> { joins(:line_items).where("orders.state = 'in_cart'") }
  scope :completed, -> { where("orders.state = 'completed'") }
  scope :checkout,  -> { where("orders.state = 'checkout'") }
  scope :deny,      -> { where("orders.state = 'deny'") }

  scope :by_month,  -> (month) { where('orders.created_at >= ? AND orders.created_at <= ?', Date.new(Date.today.year, month.to_i, 1), Date.new(Date.today.year, month.to_i, 1).end_of_month) }

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

  def admin_order_product=(product_id)
    add_product(product_id, 1, true)
  end

  def admin_order_product
    ''
  end

  def order_product=(product_id)
    add_product(product_id)
  end

  def order_product
  end

  def add_product(product, quantity=1, admin=false)
    product = product.kind_of?(Catalog::Product) ? product : Catalog::Product.where(id: product).first
    if product && product.price > 0
      if already_added = line_items.detect{ |li| li.product == product }
        quantity = quantity + already_added.quantity
        if admin
          pr = product.price * quantity
          v_pr = product.in_price * quantity
          already_added.update(quantity: quantity, price: pr.ceil, vendor_price: v_pr.ceil)
        else
          already_added.update(quantity: quantity)
        end
      else
        if admin
          line_items.create(product: product, quantity: quantity, price: product.price, vendor_price: product.in_price)
        else
          line_items.create(product: product, quantity: quantity)
        end
      end


    else
      false
    end

  end

  def add_comment=(value)
    txt = comment.to_s << value
    self.comment = txt
  end

  def add_comment
    ""
  end

  def display_comment
     # TODO: XSS
    comment.to_s.split("<hr/>").reverse.join("<hr/>").html_safe
  end

  def items_count
    line_items.map(&:quantity).sum
  end

  def ready?
    valid? && %w(name phone).all?{ |field| self.send(field).present? }
  end

  def total_sum
    line_items.includes(:product, :order).map { |li| li.quantity * li.client_price } .sum
  end

  def total_income
    line_items.includes(:product).map(&:income).sum
  end

  def format_phone
    ActionController::Base.helpers.number_to_phone(phone[3..-1], country_code: 380)
  end

  def credit_names
    line_items.map do |li|
      name = "#{li.product.name}"
      name << "(x#{li.quantity})" if li.quantity > 1
      name
    end
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
