class Registration < ApplicationRecord
  STATUS = ["pending", "confirmed"]
  validates_inclusion_of :status, :in => STATUS
  validates_presence_of :status, :ticket_id
  attr_accessor :current_step
    validates_presence_of :name, :email, :cellphone, :if => :should_validate_basic_data?
    validates_presence_of :name, :email, :cellphone, :bio, :if => :should_validate_all_data?
  # Rails 可以根据条件来做表单验证，叫做 Conditional Validations。我们需要根据用户实际在做哪一步，来决定要启用哪些验证。
  belongs_to :event
  belongs_to :ticket
  belongs_to :user, :optional => true

  before_validation :generate_uuid, :on => :create

  def to_param
    self.uuid
  end

  protected

  def should_validate_basic_data?
    current_step == 2  # 只有做到第二步需要验证
  end

  def should_validate_all_data?
    current_step == 3 || status == "confirmed"  # 做到第三步，或最后状态是 confirmed 时需要验证
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
