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
//  - Left Click (onMouseUp) -> Reveal/Dehighlight Neighbors
export default class extends Controller {
  static values = {
    revealUrl: String,
    toggleFlagUrl: String,
    highlightNeighborsUrl: String,
    revealNeighborsUrl: String,
  }

  static cellIdRegex = /cells\/(\d+)\//

  dispatchMousedown(event) {
    if (!mouse(event).actsAsLeftClick()) return

    cell(event.target).highlightNeighbors(this.highlightNeighborsUrlValue)
  }

  dispatchContextmenu(event) {
    cell(event.target).toggleFlag(this.toggleFlagUrlValue)
  }

  dispatchMouseup(event) {
    if (!mouse(event).actsAsLeftClick()) return

    cell(event.target).revealNeighbors(this.revealNeighborsUrlValue)
  }

  dispatchClick(event) {
    if (mouse(event).actsAsRightClick()) return

    cell(event.target).reveal(this.revealUrlValue)
  }
}
