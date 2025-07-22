class ItemsController < ApplicationController
  before_action :require_authentication
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]

  def index
    @items = Item.all.order(:name)
  end

  def show
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to @item, notice: "Item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "Item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to items_url, notice: "Item was successfully deleted."
  end

  def search
    @items = Item.search_by_name(params[:q]).limit(10)
    render json: @items.map { |item| { name: item.name, description: item.description } }
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description)
  end
end
