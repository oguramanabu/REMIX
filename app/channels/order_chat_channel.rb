class OrderChatChannel < ApplicationCable::Channel
  def subscribed
    order = Order.find(params[:order_id])
    # Only allow users who can access the order to subscribe
    if can_access_order?(order)
      stream_from "order_chat_#{params[:order_id]}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    order = Order.find(params[:order_id])
    return unless can_access_order?(order)

    message = order.chat_messages.create!(
      user: current_user,
      content: data["content"]
    )

    # Broadcast to all subscribers
    ActionCable.server.broadcast("order_chat_#{params[:order_id]}", {
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
    })
  end

  private

  def can_access_order?(order)
    current_user == order.creator || order.users.include?(current_user)
  end
end
