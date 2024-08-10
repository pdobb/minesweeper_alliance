class NullCoordinates
  def x
    nil
  end

  def y
    nil
  end

  def to_json
    "{}"
  end

  def inspect
    "(nil, nil)"
  end
end
