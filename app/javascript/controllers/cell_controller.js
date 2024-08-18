import { Controller } from "@hotwired/stimulus"

// CellController is responsible for managing clicks on Cells within the
// Board / grid.
//
// It works by capturing contextmenu event (typically right click
// or a long click on most mobile devices) and modifying the url.
// It's a bit of a shortcut solution but it works because we know
// that every click will end up replacing the content of the board.
export default class extends Controller {
  connect() {
    // This doesn't quite work on iOS 13 and up because it doesn't
    // fire this event. iOS will need a custom solution.
    this.element.addEventListener("contextmenu", (event) => {
      event.preventDefault()
      event.cancelBubble = true
      this.element.href = this.element.href.replace('/reveal', "/toggle_flag")
      this.element.click()
    })
  }
}
