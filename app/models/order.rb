class Order < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :order_items, dependent: :destroy
  has_many :order_users, dependent: :destroy
  has_many :users, through: :order_users

  validates :client, presence: true
  validates :factory_name, presence: true
  validates :order_date, presence: true

  accepts_nested_attributes_for :order_items, allow_destroy: true, reject_if: :all_blank
end
