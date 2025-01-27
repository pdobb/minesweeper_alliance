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
    highlightNeighborsUrl: String,
    dehighlightNeighborsUrl: String,
    revealNeighborsUrl: String,
  }

  static highlightNeighborsDelay = 100 // ms

  dispatchMousedown(event) {
    if (!mouse(event).actsAsLeftClick()) return

    this.mousedownTarget = event.target

    this.highlightNeighborsTimer = setTimeout(() => {
      cell(event.target).highlightNeighbors(this.highlightNeighborsUrlValue)
    }, this.constructor.highlightNeighborsDelay)
  }

  dispatchMouseup(event) {
    if (mouse(event).actsAsRightClick()) return

    clearTimeout(this.highlightNeighborsTimer)

    if (this.mousedownTarget && event.target != this.mousedownTarget) {
      cell(this.mousedownTarget).dehighlightNeighbors(
        this.dehighlightNeighborsUrlValue,
      )
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
