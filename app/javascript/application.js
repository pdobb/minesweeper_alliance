// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import { cookies } from "cookies"

document.addEventListener("turbo:before-stream-render", function (event) {
  const source = event.detail.newStream.dataset.source
  const userToken = cookies.get("user_token-v2")

  if (source == userToken) {
    console.info("blocking: ", event.target)
    event.preventDefault()
  } else {
    console.info(event.target)
  }
})
