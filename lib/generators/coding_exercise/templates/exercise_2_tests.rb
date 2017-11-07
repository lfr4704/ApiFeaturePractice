test "PATCH /api/trucks/1 updates the most recent known location" do
  truck = food_trucks(:pizza)
  lat, lng = [37.782267, -122.391248]
  patch api_truck_url(truck), params: { truck: { location: [lat, lng] } }

  assert_response 200
  assert_equal response.fetch(:location), [lat, lng]
end

test "GET /api/trucks/1 returns the most recent known location" do
  truck = food_trucks(:pizza)
  lat, lng = [37.782267, -122.391248]
  truck.set_location(latitude: lat, longitude: lng)

  get api_truck_url(truck)
  assert_response 200
  assert_equal response.fetch(:location), [lat, lng]
end

test "GET /api/trucks with `near` returns the distance in the response" do
  truck = food_trucks(:pizza)
  lat, lng = [37.782267, -122.391248]
  truck.set_location(latitude: lat, longitude: lng)

  get api_trucks_url,
    params: { near: [lat, lng] }
  assert_response 200
  assert_predicate response.first[:distance], :present?
end

test "Omitting the near lat/lng omits the distance from the response" do
  truck = food_trucks(:pizza)
  lat, lng = [37.782267, -122.391248]
  truck.set_location(latitude: lat, longitude: lng)

  get api_trucks_url
  assert_response 200
  refute response.first.key?(:distance),
    "distance should be omitted when `near` isn't provided"
end
