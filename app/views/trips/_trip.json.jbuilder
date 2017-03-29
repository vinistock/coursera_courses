json.extract! trip, :id, :name, :description
json.url trip_url(trip, format: :json)
json.user_roles trip.user_roles unless trip.user_roles.empty?

unless trip.images.empty?
  json.images trip.images
end
