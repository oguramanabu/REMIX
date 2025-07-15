class OrderItem < ApplicationRecord
  belongs_to :order

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def total_price
    quantity * unit_price
  end
end
