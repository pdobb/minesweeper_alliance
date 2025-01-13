import { Controller } from "@hotwired/stimulus"
import {
  computePosition, // Computes coordinates to position a floating element next to another element.
  autoUpdate, // Automatically updates tooltip position to ensure it stays anchored when scrolling/resizing.
  offset, // Add distance (margin or spacing) b/w the anchor and tooltip.
  shift, // Shifts the floating element along its axis of alignment to keep it in view.
  flip, // Flips the placement of the floating element to keep it in view.
  arrow, // Positions the arrow element to point toward the center of the reference element.
} from "@floating-ui/dom"

// TooltipController implement JS tooltips via the Floating-UI - DOM library.
// See: https://floating-ui.com/docs/getting-started
//
// Usage:
//   <span
//     data-controller="tooltip"
//     data-tooltip-placement-value="bottom-end"
//     data-action="
//       click->tooltip#toggle
//       keydown.esc@window->tooltip#hide
//     "
//   >
//     <dfn
//       data-tooltip-target="anchor"
//       aria-describedby="<unique_id>"
//     >
//       ...
//     </dfn>
//     <div id="<unique_id>" data-tooltip-target="tooltip" role="tooltip">
//       <div data-tooltip-target="arrow"></div>
//       <span>...</span>
//     </div>
//   </span
export default class extends Controller {
  static targets = ["anchor", "tooltip", "arrow"]
  static values = {
    placement: { type: String, default: "top" },
    offset: { type: Number, default: 15 },
    delay: { type: Number, default: 200 },
  }

  toggle() {
    this.tooltipTarget.style.display == "block" ? this.hide() : this.#doShow()
  }

  show() {
    if (this.hoverTimeout) clearTimeout(this.hoverTimeout)

    this.hoverTimeout = setTimeout(this.#doShow.bind(this), this.delayValue)
  }

  #doShow() {
    this.tooltipTarget.style.display = "block"
    this.update()

    this.cleanup = autoUpdate(
      this.anchorTarget,
      this.tooltipTarget,
      this.update.bind(this),
    )
  }

  hide() {
    if (this.hoverTimeout) clearTimeout(this.hoverTimeout)

    this.tooltipTarget.style.display = ""
    if (this.cleanup) this.cleanup()
  }

  update() {
    computePosition(this.anchorTarget, this.tooltipTarget, {
      placement: this.placementValue,
      middleware: [
        offset(this.offsetValue),
        shift(),
        flip(),
        arrow({ element: this.arrowTarget }),
      ],
    }).then(({ x, y, placement, middlewareData }) => {
      Object.assign(this.tooltipTarget.style, {
        left: `${x}px`,
        top: `${y}px`,
      })

      const { x: arrowX, y: arrowY } = middlewareData.arrow

      const staticSide = {
        top: "bottom",
        right: "left",
        bottom: "top",
        left: "right",
      }[placement.split("-")[0]]

      Object.assign(this.arrowTarget.style, {
        left: arrowX != null ? `${arrowX}px` : "",
        top: arrowY != null ? `${arrowY}px` : "",
        right: "",
        bottom: "",
        [staticSide]: "-4px",
      })
    })
  }
}
