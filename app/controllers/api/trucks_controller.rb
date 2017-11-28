class Api::TrucksController < ApiController
  # GET /api/trucks
  # GET /api/trucks/json
  def index
    @trucks = FoodTruck.all

    render json: @trucks.map(&:to_h)
  end

  # GET /api/trucks/1
  # GET /api/trucks/1.json
  def show
    @truck = FoodTruck.find(params[:id])

    render json: @truck.to_h
  end

  # PATCH /api/trucks/1
  def update
    @truck = FoodTruck.find(params[:id])
    @truck.update(truck_attributes)

    render json: @truck.to_h
  end

  private

  def truck_attributes
    params.require(:truck).permit(
      :name, :website, :description, :opens_at_hour, :closes_at_hour,
      :open_sunday, :open_monday, :open_tuesday, :open_wednesday, :open_thursday,
      :open_friday, :open_saturday
    )
  end
end
