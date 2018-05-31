class User < ApplicationRecord

  ROLES = ["admin", "editor"]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_one :profile
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :registrations

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  accepts_nested_attributes_for :profile

  def display_name
    self.email.split("@").first
  end

  def is_admin?
    self.role == "admin"
  end

  def is_editor?
    ["admin", "editor"].include?(self.role)  # 如果是 admin 的话，当然也有 editor 的权限
  end

end

  # 透过 User model 的 is_admin? 和 is_editor? 方法集中权限检查的逻辑，之后如果新增不同子权限，只要改 model 就可以了。
