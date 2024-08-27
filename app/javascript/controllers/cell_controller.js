import { Controller } from "@hotwired/stimulus"

// CellController is responsible for managing interactions between Cells within
// the Game Board.
export default class extends Controller {
  static classes = ["indicator"]

  indicateNeighbors(event) {
    const $cell = event.target
    if (this.#isNotRevealed($cell) || this.#isBlank($cell)) return

    const grid = new Grid(this.element)
    grid.neighbors($cell).forEach(($neighboringCell) => {
      $neighboringCell.classList.add(...this.indicatorClasses)
    })
  }

  #isNotRevealed($cell) {
    return $cell.dataset.revealed === "false"
  }

  #isBlank($cell) {
    return $cell.innerHTML.trim() === ""
  }
}

class Grid {
  constructor($table) {
    this.$table = $table
    this.cols = this.$table.rows[0].cells.length - 1
    this.rows = this.$table.rows.length - 1
  }

  neighbors($cell) {
    const currentPosition = new Position(
      $cell.cellIndex,
      // The `- 1`` here is intended to account for the `<thead>`` element...
      // even though we shouldn't have to (?).
      $cell.parentNode.rowIndex - 1,
    )

    return this.#neighboringPositions(currentPosition)
      .map((position) => this.#findCell(position.colIndex, position.rowIndex))
      .filter((cell) => this.#isIndicatable(cell))
  }

  #neighboringPositions(currentPosition) {
    // prettier-ignore
    const vectors = [
      [-1, -1], [0, -1], [1, -1],
      [-1,  0],          [1,  0],
      [-1,  1], [0,  1], [1,  1],
    ]

    return vectors
      .map((vector) => currentPosition.add(vector[0], vector[1]))
      .filter((position) => position.isValid(this.cols, this.rows))
  }

  #findCell(colIndex, rowIndex) {
    return this.$table.rows[rowIndex]?.cells[colIndex]
  }

  #isIndicatable($cell) {
    return this.#isNotRevealed($cell) && this.#isNotFlagged($cell)
  }

  #isNotRevealed($cell) {
    return $cell?.dataset?.revealed === "false"
  }

  #isNotFlagged($cell) {
    return $cell?.dataset?.flagged === "false"
  }
}

class Position {
  constructor(colIndex, rowIndex) {
    this.colIndex = colIndex
    this.rowIndex = rowIndex
  }

  add(newColIndex, newRowIndex) {
    return new Position(
      this.colIndex + newColIndex,
      this.rowIndex + newRowIndex,
    )
  }

  isValid(maxColIndex, maxRowIndex) {
    // prettier-ignore
    return (
      (this.colIndex >= 0 && this.colIndex <= maxColIndex) &&
      (this.rowIndex >= 0 && this.rowIndex <= maxRowIndex)
    )
  }
}
