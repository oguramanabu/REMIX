class Client < ApplicationRecord
  has_many :shipping_addresses, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :address, presence: true

  accepts_nested_attributes_for :shipping_addresses, allow_destroy: true, reject_if: :all_blank

  def display_name
    name
  end

  def full_address_with_shipping
    addresses = [ address ]
    addresses += shipping_addresses.map(&:address) if shipping_addresses.any?
    addresses.join(", ")
  end
end
