class OrdersController < ApplicationController
  before_action :require_authentication
  before_action :set_order, only: [ :show, :edit, :update, :destroy, :update_file_metadata, :delete_attachment ]
  before_action :check_order_access, only: [ :show, :edit, :update, :destroy, :update_file_metadata, :delete_attachment ]

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
    # Handle files separately
    new_files = params[:order][:files] if params[:order][:files].present?

    order_params_without_files = order_params.except(:files)
    @order = Order.new(order_params_without_files)
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

    # Attach files if present
    if new_files.present?
      @order.files.attach(new_files)
    end

    # Handle assigned users
    if params[:order][:user_ids].present?
      params[:order][:user_ids].reject(&:blank?).each do |user_id|
        @order.order_users.find_or_create_by(user_id: user_id)
      end
    end

    # Handle autosave requests differently
    if params[:commit] == "autosave"
      render json: {
        status: "success",
        redirect_url: order_path(@order),
        edit_url: edit_order_path(@order)
      }
    else
      redirect_to edit_order_path(@order), notice: "新しいオーダーが下書きとして作成されました。内容を入力して保存してください。"
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

    # Determine if this is a draft save or submit based on button clicked
    if params[:commit] == "下書き保存"
      save_as_draft
    elsif params[:commit] == "提出"
      submit_order
    else
      # Default update behavior
      # Handle files - append new files to existing ones
      new_files = params[:order][:files] if params[:order][:files].present?

      order_params_without_files = order_params.except(:files)
      if @order.update(order_params_without_files)
        # Attach new files if present after successful update
        if new_files.present?
          @order.files.attach(new_files)
        end
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

    # Handle files - append new files to existing ones
    new_files = params[:order][:files] if params[:order][:files].present?

    # Save without validation for drafts
    order_params_without_files = order_params.except(:files)
    @order.assign_attributes(order_params_without_files)
    @order.save(validate: false)

    # Attach new files if present
    if new_files.present?
      @order.files.attach(new_files)
    end

    # Handle autosave requests differently
    if params[:commit] == "autosave"
      render json: { status: "success" }
    else
      redirect_to edit_order_path(@order), notice: "下書きが保存されました。"
    end
  end

  def submit_order
    @order.status = "submitted"

    # Handle files - append new files to existing ones
    new_files = params[:order][:files] if params[:order][:files].present?

    order_params_without_files = order_params.except(:files)
    @order.assign_attributes(order_params_without_files)

    # Handle assigned users
    @order.order_users.destroy_all
    if params[:order][:user_ids].present?
      params[:order][:user_ids].reject(&:blank?).each do |user_id|
        @order.order_users.find_or_create_by(user_id: user_id)
      end
    end

    if @order.save
      # Attach new files if present after successful save
      if new_files.present?
        @order.files.attach(new_files)
      end
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

  def delete_attachment
    Rails.logger.info "Delete attachment called with params: #{params.inspect}"
    Rails.logger.info "Order ID: #{@order.id}, Attachment ID: #{params[:attachment_id]}"

    begin
      # Find the attachment by signed ID from the files collection
      attachment_to_delete = nil
      filename_to_delete = nil

      @order.files.each do |file|
        if file.signed_id == params[:attachment_id]
          attachment_to_delete = file
          filename_to_delete = file.filename.to_s
          break
        end
      end

      Rails.logger.info "Found attachment: #{attachment_to_delete.present?}"
      Rails.logger.info "Filename: #{filename_to_delete}"

      if attachment_to_delete
        # Remove from file_metadata if it exists
        if @order.file_metadata&.key?(filename_to_delete)
          @order.file_metadata.delete(filename_to_delete)
          @order.save
        end

        # Purge the attachment
        attachment_to_delete.purge
        Rails.logger.info "Attachment purged successfully"
        render json: { success: true, message: "ファイルが削除されました" }
      else
        Rails.logger.error "Attachment not found with signed_id: #{params[:attachment_id]}"
        render json: { success: false, error: "ファイルが見つかりません" }, status: :not_found
      end
    rescue StandardError => e
      Rails.logger.error "Unexpected error in delete_attachment: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { success: false, error: "ファイルの削除中にエラーが発生しました" }, status: :internal_server_error
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
