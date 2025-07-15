class OrdersController < ApplicationController
  before_action :require_authentication
  before_action :set_order, only: [ :show, :edit, :update, :destroy ]

  def index
    @orders = Order.includes(:order_items, :creator, :users).order(order_date: :desc)
  end

  def show
  end

  def new
    @order = Order.new
    @order.order_items.build
    @users = User.all
  end

  def create
    @order = Order.new(order_params)
    @order.creator = Current.user
    @users = User.all

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

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:client, :factory_name, :order_date, :shipping_date, :delivery_date,
                                  user_ids: [],
                                  order_items_attributes: [ :id, :name, :quantity, :unit_price, :_destroy ])
  end
end
