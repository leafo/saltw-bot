
import Widget from require "lapis.html"

class Stats extends Widget
  content: =>
    h1 "Speak"

    form method: "post", ->
      input type: "text", name: "message"
      text " "
      button "Send"

      label ->
        input type: "checkbox", name: "is_action"
        text " Say as action"

