class OrderUser < ApplicationRecord
  belongs_to :order
  belongs_to :user

  validates :order_id, uniqueness: { scope: :user_id }
end
