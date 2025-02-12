import { Controller } from "@hotwired/stimulus"
import { cell } from "games/current/board/cell"
import { mouse } from "mouse"

// Games::Current::Board::DesktopController is responsible for managing clicks
// on Cells within the desktop Game Board. All valid clicks result in a Turbo
// Stream "POST" request being sent to the server.
//
// For Unrevealed Cells:
//  - Left Click -> Reveal Cell
//  - Right Click -> Toggle Flag
// For Revealed Cells
//  - Left Click (onMouseDown) -> Highlight Neighbors
//  - Left Click (onClick) -> Reveal/Dehighlight Neighbors
export default class extends Controller {
  static values = {
    revealUrl: String,
    toggleFlagUrl: String,
    focusUrl: String,
    unfocusUrl: String,
    highlightNeighborsUrl: String,
    dehighlightNeighborsUrl: String,
    revealNeighborsUrl: String,
  }

  connect() {
    this.focusTimer = null
    this.currentlyFocusedCell = null
  }

  dispatchMousedown(event) {
    if (!mouse(event).actsAsLeftClick()) return

    this.mousedownTarget = event.target

    cell(event.target).highlightNeighbors(this.highlightNeighborsUrlValue)
  }

  dispatchMouseup(event) {
    if (mouse(event).actsAsRightClick()) return

    if (this.mousedownTarget && event.target != this.mousedownTarget) {
      cell(this.mousedownTarget).dehighlightNeighbors(
        this.dehighlightNeighborsUrlValue,
      )
    }
  }

  dispatchMouseOver(event) {
    if (this.focusTimer) clearTimeout(this.focusTimer)

    const $cell = cell(event.target)

    if (this.currentlyFocusedCell && this.currentlyFocusedCell !== $cell) {
      this.currentlyFocusedCell.updateFocus(this.unfocusUrlValue)
      this.currentlyFocusedCell = null
    }

    if ($cell.isFocusable) {
      this.focusTimer = setTimeout(() => {
        this.currentlyFocusedCell = $cell
        $cell.updateFocus(this.focusUrlValue)
      }, 100)
    }
  }

  dispatchMouseOut(event) {
    if (this.focusTimer) clearTimeout(this.focusTimer)

    const $cell = cell(event.target)

    // Unfocus if we're leaving the currently focused cell
    if ($cell !== this.currentlyFocusedCell) {
      this.currentlyFocusedCell.updateFocus(this.unfocusUrlValue)
      this.currentlyFocusedCell = null
    } else {
      $cell.updateFocus(this.unfocusUrlValue)
    }
  }

  dispatchContextmenu(event) {
    cell(event.target).toggleFlag(this.toggleFlagUrlValue)
  }

  dispatchClick(event) {
    if (mouse(event).actsAsRightClick()) return

    const $cell = cell(event.target)

    if ($cell.isRevealed) {
      $cell.revealNeighbors(this.revealNeighborsUrlValue)
    } else {
      $cell.reveal(this.revealUrlValue)
    }
  }
}
