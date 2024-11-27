class BuildingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: Building.all
  end

  def create
    render json: Building.new(validate_params)
  end

  def update
    id = params[:id]
    render json: "PUT success for id #{id}"
  end


  def validate_params
    # rails wraps PUT/POST body in a param based on the name of the controller
    # so this should just be called with { client_id, address, state, zip }
    params.require(:building).permit([:client_id, :address, :state, :zip])
  end
end
