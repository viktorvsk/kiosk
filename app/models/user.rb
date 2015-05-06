class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  ROLES = %w(admin customer)
  scope :admins, -> { where(role: 'admin') }

  PHONE_OPERATORS = %w(63 93 50 97 96 572).join('|')
  validates :phone,
    format: { with: /\A(380)(#{PHONE_OPERATORS})\d{6,7}\Z/ },
    allow_blank: true,
    uniqueness: true
  before_validation :strip_phone

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :current_order, -> { where(state: 'in_cart') }, class_name: Order, dependent: :destroy
  has_many :orders, -> { where.not(state: 'in_cart') }, dependent: :destroy
  has_many :callbacks, dependent: :destroy

  ROLES.each do |role_name|
    define_method "#{role_name}?" do
      role_name == role
    end
  end

  def is_admin?
    role == 'admin'
  end

  def promote_to(role_name)
    fail ArgumentError, "Invalid role. Use one of: #{ROLES.join(', ')}" unless role_name.to_s.in?( ROLES )
    update(role: role_name) unless role_name == role
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
