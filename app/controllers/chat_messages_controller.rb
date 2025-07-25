class ChatMessagesController < ApplicationController
  before_action :require_authentication
  before_action :set_order
  before_action :check_order_access

  def index
    @chat_messages = @order.chat_messages.includes(:user).order(created_at: :asc).limit(50)
    render json: @chat_messages.map { |message| format_message(message) }
  end

  def create
    @chat_message = @order.chat_messages.build(chat_message_params)
    @chat_message.user = Current.user

    if @chat_message.save
      render json: { status: "success", message: format_message(@chat_message) }, status: :created
    else
      render json: { status: "error", errors: @chat_message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def users_for_mention
    # Return all users except current user (more typical for chat systems)
    # You can change this back to only order-related users if needed
    accessible_users = User.where.not(id: Current.user.id)

    search_query = params[:q].to_s.downcase

    # If search query is empty, return all accessible users
    filtered_users = if search_query.empty?
      accessible_users.limit(10) # Limit to prevent too many results
    else
      accessible_users.where("LOWER(family_name_kanji || given_name_kanji) LIKE ?", "%#{search_query}%").limit(10)
    end

    render json: filtered_users.map { |user|
      {
        id: user.id,
        name: "#{user.family_name_kanji}#{user.given_name_kanji}",
        display_name: "#{user.family_name_kanji} #{user.given_name_kanji}",
        email: user.email_address
      }
    }
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def check_order_access
    unless @order.creator == Current.user || @order.users.include?(Current.user)
      render json: { error: "Access denied" }, status: :forbidden
    end
  end

  def chat_message_params
    params.require(:chat_message).permit(:content)
  end

  def format_message(message)
    {
      id: message.id,
      content: message.formatted_content,
      user: {
        id: message.user.id,
        name: "#{message.user.family_name_kanji} #{message.user.given_name_kanji}",
        avatar_initial: message.user.family_name_kanji[0]
      },
      created_at: message.created_at.strftime("%Y年%m月%d日 %H:%M"),
      mentioned_users: message.mentioned_user_objects.map { |u|
        { id: u.id, name: "#{u.family_name_kanji} #{u.given_name_kanji}" }
      }
    }
  end
end
