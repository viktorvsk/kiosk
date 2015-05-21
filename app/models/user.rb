class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  ROLES = %w(admin customer content)
  # scope :admins, -> { where(role: 'admin') }
  # scope :contents, -> { where(role: 'content') }

  # PHONE_OPERATORS = %w(63 93 50 97 96 572).join('|')
  validates :phone,
    format: { with: /\A(380)\d{9}\Z/ },
    allow_blank: true,
    uniqueness: true
  before_validation :strip_phone

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :current_order, -> { where(state: 'in_cart') }, class_name: Order, dependent: :destroy
  has_many :orders, -> { where.not(state: 'in_cart') }, dependent: :destroy
  has_many :callbacks, dependent: :destroy
  has_many :actions, dependent: :destroy, class_name: UserProductAction

  ROLES.each do |role_name|
    scope "#{role_name}s", ->{ where(role: role_name) }
    define_method "#{role_name}?" do
      role_name == role
    end
  end

  def record!(product, action_type, action)
    actions.create!(product: product, action_type: action_type, action: action)
  end

  def is_admin?
    role == 'admin'
  end

  def form_display
    "#{name} #{phone}".presence || email
  end

  def promote_to(role_name)
    fail ArgumentError, "Invalid role. Use one of: #{ROLES.join(', ')}" unless role_name.to_s.in?( ROLES )
    update(role: role_name) unless role_name == role
  end

  def total_income
    orders.map(&:total_sum).sum
  end

  def clean_total_income
    orders.map(&:total_income).sum
  end

  def uniq_product_actions_today
    actions.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).pluck(:product_id).uniq.count
  end

  private

  def strip_phone
    p = self[:phone].to_s
    return if p.blank?
    p.gsub!(/[^\d]/, '')
    unless p =~ /\A38/
      p = "38#{p}"
    end
    self.phone = p
  end

end
