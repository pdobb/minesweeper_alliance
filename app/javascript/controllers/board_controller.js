import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"
import Mouse from "mouse"
import Touchpad from "touchpad"

const mouse = (event) => new Mouse(event)
const touchpad = (event) => new Touchpad(event)

const cell = (element) =>
  new Proxy(new Cell(element), {
    get(target, prop) {
      return prop in target ? target[prop] : target.element[prop]
    },
  })

// BoardController is responsible for managing clicks on Cells within the
// Game Board. All valid clicks event types result in a Turbo Stream "POST"
// being sent to the Rails server.
//
// For Mobile Browsers:
//   For Unrevealed Cells:
//    - Tap -> Reveal Cell
//    - Long Press -> Toggle Flag
//   For Revealed Cells
//    - Tap -> Reveal Neighbors
//
// For Non-Mobile Browsers:
//   For Unrevealed Cells:
//    - Left Click -> Reveal Cell
//    - Right Click -> Toggle Flag
//   For Revealed Cells
//    - Left Click (onMouseDown) -> Highlight Neighbors
//    - Left Click (onMouseUp) -> Reveal Neighbors
export default class extends Controller {
  static values = {
    revealUrl: String,
    toggleFlagUrl: String,
    highlightNeighborsUrl: String,
    revealNeighborsUrl: String,
  }

  static cellIdRegex = /cells\/(\d+)\//

  reveal(event) {
    if (mouse(event).actsAsRightClick()) return

    const $cell = cell(event.target)
    if ($cell.isNotTableCell) return
    if ($cell.isRevealed || $cell.isFlagged) return

    this.#submit($cell, this.revealUrlValue)
  }

  toggleFlag(event) {
    const $cell = cell(event.target)
    if ($cell.isNotFlaggable) return

    this.#submit($cell, this.toggleFlagUrlValue)
  }

  highlightNeighbors(event) {
    if (!mouse(event).actsAsLeftClick()) return

    const $cell = cell(event.target)
    if ($cell.isNotRevealed || $cell.isBlank) return

    this.#submit($cell, this.highlightNeighborsUrlValue)
  }

  revealNeighbors(event) {
    if (!mouse(event).actsAsLeftClick()) return

    const $cell = cell(event.target)
    if ($cell.isNotRevealed || $cell.isBlank) return

    this.#submit($cell, this.revealNeighborsUrlValue)
  }

  touchStart(event) {
    if (cell(event.target).isNotFlaggable) return

    this.longPressHandler = touchpad(event).handleLongPress(() => {
      this.#indicateSuccessfulToggleFlagEvent()
      this.toggleFlag(event)
    })
  }

  touchEnd() {
    this.longPressHandler?.cancel()
  }

  #indicateSuccessfulToggleFlagEvent() {
    document
      .getElementById("flagsToMinesRatio")
      .classList.add("animate-ping-once")
    if (navigator.vibrate) navigator.vibrate(100)
  }

  #submit($cell, baseUrl) {
    $cell.showLoadingIndicator()

    const cellId = $cell.id.replace(/^cell_/, "")
    // /boards/<boardId>/cells/<cellId>/<action>
    const targetUrl = baseUrl.replace(
      this.constructor.cellIdRegex,
      `cells/${cellId}/`,
    )

    post(targetUrl, { responseKind: "turbo-stream" })
  }
}

class Cell {
  constructor(element) {
    this.element = element
    this.dataset = element.dataset
  }

  get isRevealed() {
    return this.dataset.revealed === "true"
  }
  get isNotRevealed() {
    return this.dataset.revealed === "false"
  }

  get isFlaggable() {
    return this.isNotRevealed
  }
  get isNotFlaggable() {
    return !this.isFlaggable
  }

  get isFlagged() {
    return this.dataset.flagged === "true"
  }

  get isBlank() {
    return this.element.innerHTML.trim() === ""
  }

  get isTableCell() {
    return this.element instanceof HTMLTableCellElement
  }
  get isNotTableCell() {
    return !this.isTableCell
  }

  showLoadingIndicator() {
    this.element.classList.add("animate-pulse-fast")
  }
}
