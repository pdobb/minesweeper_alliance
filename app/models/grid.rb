class Grid
  attr_reader :cells

  def initialize(cells)
    @cells = cells
  end

  # {
  #   0 => [<Cell(💣) (0, 0)>, <Cell(💣) (1, 0)>, <Cell(◻️) (2, 0)>],
  #   1 => [<Cell(◻️) (0, 1)>, <Cell(💣) (1, 1)>, <Cell(◻️) (2, 1)>],
  #   2 => [<Cell(◻️) (0, 2)>, <Cell(💣) (1, 2)>, <Cell(◻️) (2, 2)>]
  # }
  def to_h
    cells.group_by(&:y)
  end

  # [
  #   [<Cell(💣) (0, 0)>, <Cell(💣) (1, 0)>, <Cell(◻️) (2, 0)>],
  #   [<Cell(◻️) (0, 1)>, <Cell(💣) (1, 1)>, <Cell(◻️) (2, 1)>],
  #   [<Cell(◻️) (0, 2)>, <Cell(💣) (1, 2)>, <Cell(◻️) (2, 2)>]
  # ]
  def to_a
    to_h.values
  end

  # 0 => [(1, 0), (2, 0), (3, 0)]
  # 1 => [(1, 1), (3, 1)]
  # 2 => [(1, 2), (2, 2), (3, 2)]
  def render
    to_h.each do |y, row|
      puts "#{y} => #{row}"
    end

    nil
  end

  def to_ascii
    # TODO
  end
end
