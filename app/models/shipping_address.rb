class ShippingAddress < ApplicationRecord
  belongs_to :client

  validates :address, presence: true
  validates :name, presence: true

  def display_name
    name.present? ? "#{name} - #{address}" : address
  end
end
