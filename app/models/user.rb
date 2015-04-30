class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  ROLES = %w(admin customer)
  scope :admins, -> { where(role: 'admin') }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :current_order, -> { where(state: 'in_cart') }, class_name: Order
  has_many :orders, -> { where.not(state: 'in_cart') }

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
end
