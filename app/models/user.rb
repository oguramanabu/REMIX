class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :family_name_eng, presence: true
  validates :given_name_eng, presence: true
  validates :family_name_kanji, presence: true
  validates :given_name_kanji, presence: true
end
