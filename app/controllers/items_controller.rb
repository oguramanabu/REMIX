class ItemsController < ApplicationController
  before_action :require_authentication

  def search
    @items = Item.search_by_name(params[:q]).limit(10)
    render json: @items.map { |item| { name: item.name, description: item.description } }
  end
end
