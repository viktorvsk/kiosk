class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  ROLES = %w(admin customer)
  scope :admins, -> { joins(:role).where(states: { name: 'admin' }) }
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  has_one :role, as: :stateable, class_name: State

  ROLES.each do |role_name|
    define_method "#{role_name}?" do
      role.present? && role.name == role_name.to_s
    end
  end

  def role_name
    role.name
  end

  def customer?
    role.nil? or role.name == 'customer'
  end

  def is_admin?
    role.try(:name) == 'admin'
  end

  def promote_to(role_name)
    fail ArgumentError, "Invalid role. Use one of: #{ROLES.join(', ')}" unless role_name.to_s.in?( ROLES )
    if role.present?
      role.update(name: role_name.to_s) unless role.name == role_name.to_s
    else
      create_role(name: role_name)
    end
    role_name
  end
end
