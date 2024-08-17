# frozen_string_literal: true

class Grid
  attr_reader :cells

  def initialize(cells)
    @cells = cells
  end

  # @example
  #   {
  #     0=>[<Cell[1](◻️) (0, 0) :: nil>, <Cell[2](◻️) (1, 0) :: nil>, <Cell[3](◻️ / 💣) (2, 0) :: nil>],
  #     1=>[<Cell[4](◻️) (0, 1) :: nil>, <Cell[5](◻️) (1, 1) :: nil>, <Cell[6](◻️ / 💣) (2, 1) :: nil>],
  #     2=>[<Cell[7](◻️) (0, 2) :: nil>, <Cell[8](◻️) (1, 2) :: nil>, <Cell[9](◻️ / 💣) (2, 2) :: nil>]
  #   }
  def to_h
    cells.group_by { |cell| cell.y || "nil" }
  end

  # @example
  #   [
  #     [<Cell[1](◻️) (0, 0) :: nil>, <Cell[2](◻️) (1, 0) :: nil>, <Cell[3](◻️ / 💣) (2, 0) :: nil>],
  #     [<Cell[4](◻️) (0, 1) :: nil>, <Cell[5](◻️) (1, 1) :: nil>, <Cell[6](◻️ / 💣) (2, 1) :: nil>],
  #     [<Cell[7](◻️) (0, 2) :: nil>, <Cell[8](◻️) (1, 2) :: nil>, <Cell[9](◻️ / 💣) (2, 2) :: nil>]
  #   ]
  def to_a
    to_h.values
  end

  # @example
  #   0 => ◻️ (0, 0) ◻️ (1, 0) ◻️ (2, 0)
  #   1 => ◻️ (0, 1) ◻️ (1, 1) ◻️ (2, 1)
  #   2 => ◻️ (0, 2) ◻️ (1, 2) ◻️ (2, 2)
  def render
    to_h.each do |y, row|
      print "#{y} => "

      row.each do |cell|
        print cell.render, " "
      end

      print "\n"
    end

    nil
  end
end
