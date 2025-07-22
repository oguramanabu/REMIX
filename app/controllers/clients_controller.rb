class ClientsController < ApplicationController
  before_action :require_authentication
  before_action :set_client, only: [ :show, :edit, :update, :destroy ]

  def index
    @clients = Client.includes(:shipping_addresses, :orders).order(:name)
  end

  def show
  end

  def new
    @client = Client.new
    @client.shipping_addresses.build
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to clients_path, notice: "クライアントが正常に作成されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @client.shipping_addresses.build if @client.shipping_addresses.empty?
  end

  def update
    if @client.update(client_params)
      redirect_to client_path(@client), notice: "クライアントが正常に更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: "クライアントが削除されました。"
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :address,
                                   shipping_addresses_attributes: [ :id, :name, :address, :_destroy ])
  end
end
