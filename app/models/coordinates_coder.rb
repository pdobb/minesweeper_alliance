class CoordinatesCoder
  def self.dump(coordinates)
    coordinates.to_json
  end

  # @example json
  #   { "x": 1, "y": 1 }
  def self.load(json)
    hash = JSON.parse(json).symbolize_keys
    Coordinates.new(**hash)
  rescue
    NullCoordinates.new
  end
end
