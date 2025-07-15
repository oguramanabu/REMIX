class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar
  has_many :sessions, dependent: :destroy
  has_many :created_orders, class_name: "Order", foreign_key: "creator_id", dependent: :destroy
  has_many :order_users, dependent: :destroy
  has_many :orders, through: :order_users
  has_many :sent_invitations, class_name: "UserInvitation", foreign_key: "invited_by_id", dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :family_name_eng, presence: true
  validates :given_name_eng, presence: true
  validates :family_name_kanji, presence: true
  validates :given_name_kanji, presence: true

  validate :avatar_format, if: -> { avatar.attached? }

  def full_name_kanji
    "#{family_name_kanji} #{given_name_kanji}"
  end

  def full_name_eng
    "#{family_name_eng} #{given_name_eng}"
  end

  private

  def avatar_format
    return unless avatar.attached?

    unless avatar.blob.content_type.in?([ "image/jpeg", "image/png" ])
      errors.add(:avatar, "はJPEGまたはPNG形式である必要があります")
    end

    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "は5MB以下である必要があります")
    end
  end
end
