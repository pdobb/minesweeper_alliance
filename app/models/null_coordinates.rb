class NullCoordinates
  def x = nil
  def y = nil

  def neighbors = []
  def to_h = {}
  def to_json = "{}"

  def inspect
    "(nil, nil)"
  end

  def to_s = inspect
  def render = inspect
end
