class OrdersController < ApplicationController
  before_action :require_authentication
  before_action :set_order, only: [ :show, :edit, :update, :destroy, :update_file_metadata ]

  def index
    @orders = Order.includes(:creator, :users, :client).order(order_date: :desc)
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
    @users = User.all

    # Clean up empty URLs
    if params[:order][:attachment_urls].present?
      @order.attachment_urls = params[:order][:attachment_urls].reject(&:blank?)
    end

    # Parse file metadata if present
    if params[:order][:file_metadata].present?
      @order.file_metadata = JSON.parse(params[:order][:file_metadata])
    end

    if @order.save
      redirect_to orders_path, notice: "オーダーが正常に作成されました。"
    else
      render :new, status: :unprocessable_entity
    end
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

    if @order.update(order_params)
      redirect_to order_path(@order), notice: "オーダーが正常に更新されました。"
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

  def order_params
    params.require(:order).permit(:client_id, :factory_name, :order_date, :delivery_date,
                                  :item_number, :item_name, :quantity, :trade_term, :purchase_price,
                                  :sell_price, :export_port, :estimate_delivery_date, :sales_multiple,
                                  :exchange_rate, :license, :file_metadata,
                                  files: [], user_ids: [], attachment_urls: []
                                  )
  end
end
