class Coordinates < Data.define(:x, :y)
  def inspect
    "(#{x}, #{y})"
  end

  def to_s
    inspect
  end
end
