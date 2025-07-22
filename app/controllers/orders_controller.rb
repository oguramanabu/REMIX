class OrdersController < ApplicationController
  before_action :require_authentication
  before_action :set_order, only: [ :show, :edit, :update, :destroy, :update_file_metadata ]
  before_action :check_order_access, only: [ :show, :edit, :update, :destroy, :update_file_metadata ]

  def index
    # Show orders the user created or is assigned to
    @orders = Order.includes(:creator, :users, :client)
                   .left_joins(:order_users)
                   .where("orders.creator_id = ? OR order_users.user_id = ?",
                          Current.user.id, Current.user.id)
                   .distinct
                   .order(order_date: :desc)
  end

  def show
  end

  def new
    @order = Order.new
    @users = User.all
  end

  def create
    @order = Order.new(order_params)
    @order.creator = Current.user
    @order.status = "draft"  # Always create as draft
    @users = User.all

    # Clean up empty URLs
    if params[:order][:attachment_urls].present?
      @order.attachment_urls = params[:order][:attachment_urls].reject(&:blank?)
    end

    # Parse file metadata if present
    if params[:order][:file_metadata].present?
      @order.file_metadata = JSON.parse(params[:order][:file_metadata])
    end

    # Save as draft first (no validations required)
    @order.save(validate: false)

    # Handle assigned users
    if params[:order][:user_ids].present?
      params[:order][:user_ids].reject(&:blank?).each do |user_id|
        @order.order_users.find_or_create_by(user_id: user_id)
      end
    end

    redirect_to edit_order_path(@order), notice: "新しいオーダーが下書きとして作成されました。内容を入力して保存してください。"
  end

  def edit
    @users = User.all
  end

  def update
    # Clean up empty URLs
    if params[:order][:attachment_urls].present?
      params[:order][:attachment_urls] = params[:order][:attachment_urls].reject(&:blank?)
    end

    # Parse file metadata if present
    if params[:order][:file_metadata].present?
      params[:order][:file_metadata] = JSON.parse(params[:order][:file_metadata])
    end

    # Determine if this is a draft save or submit based on button clicked
    if params[:commit] == "下書き保存"
      save_as_draft
    elsif params[:commit] == "提出"
      submit_order
    else
      # Default update behavior
      if @order.update(order_params)
        redirect_to order_path(@order), notice: "オーダーが正常に更新されました。"
      else
        @users = User.all
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def save_as_draft
    @order.status = "draft"

    # Handle assigned users
    @order.order_users.destroy_all
    if params[:order][:user_ids].present?
      params[:order][:user_ids].reject(&:blank?).each do |user_id|
        @order.order_users.find_or_create_by(user_id: user_id)
      end
    end

    # Save without validation for drafts
    @order.assign_attributes(order_params)
    @order.save(validate: false)

    redirect_to edit_order_path(@order), notice: "下書きが保存されました。"
  end

  def submit_order
    @order.status = "submitted"
    @order.assign_attributes(order_params)

    # Handle assigned users
    @order.order_users.destroy_all
    if params[:order][:user_ids].present?
      params[:order][:user_ids].reject(&:blank?).each do |user_id|
        @order.order_users.find_or_create_by(user_id: user_id)
      end
    end

    if @order.save
      redirect_to order_path(@order), notice: "オーダーが提出されました。"
    else
      @users = User.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    redirect_to orders_path, notice: "オーダーが削除されました。"
  end

  def update_file_metadata
    original_filename = params[:original_filename]
    new_filename = params[:new_filename]

    @order.file_metadata ||= {}

    if new_filename.present? && new_filename != original_filename
      @order.file_metadata[original_filename] = new_filename
    elsif @order.file_metadata[original_filename]
      @order.file_metadata.delete(original_filename)
    end

    if @order.save
      render json: { success: true, display_name: @order.file_metadata[original_filename] || original_filename }
    else
      render json: { success: false, error: @order.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def check_order_access
    unless @order.creator == Current.user || @order.users.include?(Current.user)
      redirect_to orders_path, alert: "このオーダーにアクセスする権限がありません。"
    end
  end

  def order_params
    params.require(:order).permit(:client_id, :factory_name, :order_date, :delivery_date,
                                  :item_number, :item_name, :quantity, :trade_term, :purchase_price,
                                  :sell_price, :export_port, :estimate_delivery_date, :sales_multiple,
                                  :exchange_rate, :license, :file_metadata, :status,
                                  files: [], user_ids: [], attachment_urls: []
                                  )
  end
end
