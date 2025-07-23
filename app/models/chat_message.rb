class ChatMessage < ApplicationRecord
  belongs_to :order
  belongs_to :user

  validates :content, presence: true
  serialize :mentioned_users, JSON

  scope :recent, -> { order(created_at: :desc) }
  scope :for_order, ->(order_id) { where(order_id: order_id) }

  # Parse @mentions from content and store mentioned user IDs
  before_save :extract_mentions

  def mentioned_user_objects
    return [] unless mentioned_users.present?
    User.where(id: mentioned_users)
  end

  def formatted_content
    content_with_mentions = content.dup
    mentioned_user_objects.each do |user|
      mention_text = "@#{user.family_name_kanji}#{user.given_name_kanji}"
      content_with_mentions.gsub!(/@#{Regexp.escape(user.family_name_kanji)}#{Regexp.escape(user.given_name_kanji)}/,
                                  "<span class=\"mention\">#{mention_text}</span>")
    end
    content_with_mentions
  end

  private

  def extract_mentions
    # Extract @mentions from content and find matching users
    mentions = content.scan(/@(\S+)/)
    user_ids = []

    mentions.each do |mention|
      mention_text = mention[0]
      # Try to find user by name (family_name + given_name)
      User.all.each do |user|
        full_name = "#{user.family_name_kanji}#{user.given_name_kanji}"
        if full_name == mention_text
          user_ids << user.id
        end
      end
    end

    self.mentioned_users = user_ids.uniq
  end
end
