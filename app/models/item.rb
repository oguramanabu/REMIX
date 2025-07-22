class Item < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :search_by_name, ->(query) { where("name ILIKE ?", "%#{query}%") if query.present? }
end
