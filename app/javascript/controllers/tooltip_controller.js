import { Controller } from "@hotwired/stimulus"
import {
  computePosition, // Computes coordinates to position a floating element next to another element.
  offset, // Add distance (margin or spacing) b/w the anchor and tooltip.
  shift, // Shifts the floating element along its axis of alignment to keep it in view.
  autoUpdate, // Automatically updates the position of the tooltip, to ensure it stays anchored.
  arrow,
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
//       aria-describedby="..._tooltip"
//     >
//       ...
//     </dfn>
//     <div id="..._tooltip" data-tooltip-target="tooltip" role="tooltip">
//       <div data-tooltip-target="arrow"></div>
//       ...
//     </div>
//   </span
export default class extends Controller {
  static targets = ["anchor", "tooltip", "arrow"]
  static values = {
    placement: { type: String, default: "top" },
    offset: { type: Number, default: 10 },
  }

  toggle() {
    this.tooltipTarget.style.display == "block" ? this.hide() : this.show()
  }

  show() {
    this.tooltipTarget.style.display = "block"
    this.update()

    this.cleanup = autoUpdate(
      this.anchorTarget,
      this.tooltipTarget,
      this.update.bind(this),
    )
  }

  hide() {
    this.tooltipTarget.style.display = ""
    this.cleanup()
  }

  update() {
    computePosition(this.anchorTarget, this.tooltipTarget, {
      placement: this.placementValue,
      middleware: [
        offset(this.offsetValue),
        shift(),
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
