# This model represents a single entry in the `favorite_locations` table
class FavoriteLocation < Sequel::Model
  plugin :json_serializer
end
