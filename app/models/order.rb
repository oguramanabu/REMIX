class Order < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :order_users, dependent: :destroy
  has_many :users, through: :order_users

  has_many_attached :files

  validates :client, presence: true
  validates :factory_name, presence: true
  validates :order_date, presence: true


  validate :validate_urls

  def display_filename(file)
    return file.filename.to_s unless file_metadata.present?
    file_metadata[file.filename.to_s] || file.filename.to_s
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
