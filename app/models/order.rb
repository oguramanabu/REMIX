class Order < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :client, optional: true
  has_many :order_users, dependent: :destroy
  has_many :users, through: :order_users

  has_many_attached :files

  validates :client_id, presence: true
  validates :factory_name, presence: true
  validates :order_date, presence: true
  validates :item_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :purchase_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sell_price, presence: true, numericality: { greater_than_or_equal_to: 0 }


  validate :validate_urls

  def display_filename(file)
    return file.filename.to_s unless file_metadata.present?
    file_metadata[file.filename.to_s] || file.filename.to_s
  end

  def total_purchase_amount
    return 0 unless quantity.present? && purchase_price.present?
    quantity * purchase_price
  end

  def total_sales_amount
    return 0 unless quantity.present? && sell_price.present?
    quantity * sell_price
  end

  def gross_profit_amount
    total_sales_amount - total_purchase_amount
  end

  def gross_profit_percentage
    return 0 if total_purchase_amount.zero?
    (gross_profit_amount / total_purchase_amount * 100).round(2)
  end

  def markup_rate
    return 0 if purchase_price.blank? || purchase_price.zero?
    ((sell_price - purchase_price) / purchase_price * 100).round(2)
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
