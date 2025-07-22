class Order < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :client, optional: true
  has_many :order_users, dependent: :destroy
  has_many :users, through: :order_users

  has_many_attached :files

  # Status enum-like behavior
  validates :status, inclusion: { in: %w[draft submitted completed cancelled] }

  # Conditional validations - only required for submitted/completed orders
  validates :client_id, presence: true, if: -> { submitted? || completed? }
  validates :factory_name, presence: true, if: -> { submitted? || completed? }
  validates :order_date, presence: true, if: -> { submitted? || completed? }
  validates :item_name, presence: true, if: -> { submitted? || completed? }
  validates :quantity, presence: true, numericality: { greater_than: 0 }, if: -> { submitted? || completed? }
  validates :purchase_price, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: -> { submitted? || completed? }
  validates :sell_price, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: -> { submitted? || completed? }

  validate :validate_urls

  # Status helper methods
  def draft?
    status == "draft"
  end

  def submitted?
    status == "submitted"
  end

  def completed?
    status == "completed"
  end

  def cancelled?
    status == "cancelled"
  end

  # Status badge color methods
  def status_badge_class
    case status
    when "draft" then "badge-info"
    when "submitted" then "badge-warning"
    when "completed" then "badge-success"
    when "cancelled" then "badge-error"
    else "badge-ghost"
    end
  end

  def status_label
    case status
    when "draft" then "下書き"
    when "submitted" then "提出済み"
    when "completed" then "完了"
    when "cancelled" then "キャンセル"
    else status
    end
  end

  # Check if order can be shared (has assigned users or is not draft)
  def shareable?
    users.any? || !draft?
  end

  def display_filename(file)
    return file.filename.to_s unless file_metadata.present?
    file_metadata[file.filename.to_s] || file.filename.to_s
  end

  def total_purchase_amount
    return 0 unless quantity.present? && purchase_price.present? && exchange_rate.present?
    quantity * purchase_price * exchange_rate
  end

  def total_sales_amount
    return 0 unless quantity.present? && sell_price.present?
    quantity * sell_price
  end

  def gross_profit_amount
    total_sales_amount - total_purchase_amount
  end

  def gross_profit_percentage
    return 0 if total_sales_amount.zero?
    (gross_profit_amount / total_sales_amount * 100).round(2)
  end

  private

  def validate_urls
    return unless attachment_urls.present?

    attachment_urls.each do |url|
      next if url.blank?

      unless url.match?(URI::DEFAULT_PARSER.make_regexp(%w[http https]))
        errors.add(:attachment_urls, "「#{url}」は有効なURLではありません")
      end
    end
  end
end
