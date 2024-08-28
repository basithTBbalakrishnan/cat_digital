class ItemsController < ApplicationController
  
  def create
    @item = Item.new(item_params)
    if @item.save
      notify_third_parties(@item)
      render json: @item, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      notify_third_parties(@item)
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  private

  
  def item_params
    params.require(:item).permit(:name, :data)
  end

  def notify_third_parties(item)
  	THIRD_PARTY_CONFIG = YAML.load_file(Rails.root.join('config', 'third_party.yml'))[Rails.env]
    third_party_endpoints = THIRD_PARTY_CONFIG['third_party_endpoints']
    @webhook_secret = THIRD_PARTY_CONFIG['webhook_secret']

    third_party_endpoints.each do |endpoint|
      send_notification(endpoint, item)
    end
  end

  def send_notification(endpoint, item)
	require 'net/http'
	require 'json'

	uri = URI(endpoint)
	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Post.new(uri.path, {
	  'Content-Type' => 'application/json',
	  'X-Webhook-Secret' => @webhook_secret
	})
	request.body = item.to_json
	response = http.request(request)
	if response
      render json: messeage: "Notification send successfully", status: 200
    else
      render json: messeage: "Notification failed", status: 400
    end
  end
end

