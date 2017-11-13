class TagsController < ApplicationController
  def show
    @tag = Tag.find(params[:id])
    @trucks = FoodTruck.tagged_with(@tag)
  end
end
