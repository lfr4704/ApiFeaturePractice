require 'test_helper'

class Api::TrucksControllerTest < ActionDispatch::IntegrationTest

  test "GET /api/trucks works" do
    get api_trucks_url

    assert_response 200
    assert_same_elements FoodTruck.all.map(&:to_h), response
  end

  test "GET /api/trucks/1 works" do
    truck = food_trucks(:pizza)
    get api_truck_url(truck)

    assert_response 200
    assert_equal truck.to_h, response
  end

  test "A truck has a NULL rating without rating" do
    truck = food_trucks(:pizza)
    get api_truck_url(truck)

    assert_response 200
    assert_nil response[:rating]
  end

  test "GET returns rating for rated truck" do
    # TODO pizza must have a 5-star rating

    truck = food_trucks(:pizza)
    get api_truck_url(truck)

    assert_response 200
    assert_equal "5.0", response[:rating]
  end

  test "Decimals should be rounded to a single decimal place when multiple ratings exist" do
    # TODO pizza must have a 0.3-star rating
    # Maybe 0,0,1?

    truck = food_trucks(:pizza)
    get api_truck_url(truck)

    assert_response 200
    assert_equal "0.3", response[:rating]
  end

  # EXERCISE 2 - DO NOT DELETE THIS LINE

  # EXERCISE 3 - DO NOT DELETE THIS LINE

  def response
    @parsed_response ||= JSON.parse(@response.body, symbolize_names: true)
  end

end
