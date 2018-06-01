class Event < ApplicationRecord
  mount_uploader :logo, EventLogoUploader
  mount_uploaders :images, EventImageUploader
  serialize :images, JSON

  include RankedModel
  ranks :row_order
  belongs_to :category, :optional => true
  has_many :tickets, :dependent => :destroy, :inverse_of  => :event
  has_many :registrations, :dependent => :destroy
    # 某些版本的Rails 有个accepts_nested_attributes_for 的bug 让has_many 故障了，需要额外补上inverse_of 参数，不然存储时会找不到tickets

  has_many :attachments, :class_name => "EventAttachment", :dependent => :destroy
  has_many :registration_imports, :dependent => :destroy
  accepts_nested_attributes_for :attachments, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :tickets, :allow_destroy => true, :reject_if => :all_blank

  STATUS = ["draft", "public", "private"]
  validates_inclusion_of :status, :in => STATUS
  validates_presence_of :name

  before_validation :generate_friendly_id, :on => :create

  scope :only_public, -> { where( :status => "public" ) }
  scope :only_available, -> { where( :status => ["public", "private"] ) }

  def to_param
    self.friendly_id
  end

  protected

  def generate_friendly_id
    self.friendly_id ||= SecureRandom.uuid
  end

end
