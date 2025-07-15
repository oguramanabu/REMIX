class UserInvitation < ApplicationRecord
  belongs_to :invited_by, class_name: "User"

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :invited_at, presence: true

  validate :email_not_already_registered

  before_validation :generate_token, on: :create
  before_validation :set_invited_at, on: :create

  scope :pending, -> { where(accepted_at: nil, cancelled_at: nil) }
  scope :accepted, -> { where.not(accepted_at: nil) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }

  def pending?
    accepted_at.nil? && cancelled_at.nil?
  end

  def accepted?
    accepted_at.present?
  end

  def cancelled?
    cancelled_at.present?
  end

  def expired?
    invited_at < 7.days.ago
  end

  def accept!
    update!(accepted_at: Time.current)
  end

  def cancel!
    update!(cancelled_at: Time.current)
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def set_invited_at
    self.invited_at = Time.current
  end

  def email_not_already_registered
    return unless email_address.present?

    if User.exists?(email_address: email_address)
      errors.add(:email_address, "is already registered")
    end
  end
end
