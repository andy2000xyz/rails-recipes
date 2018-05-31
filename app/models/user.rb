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

end
