import Widget from require "lapis.html"

class Module extends Widget
  content: =>
    h1 @module\get_name()
    if @errors
      div id: "errors", ->
        for error in *@errors
          p ->
            em "ERROR"
            text " " .. error
    div id: "endorsers", ->
      h1 "Endorsers"
      ul ->
        for u in *@module\endorsers()
          li -> a href: @url_for("main.user", id: u.id), u\get_fullname()
      if @current_user
        form method: "POST", action: @url_for("main.module", id: @module.id), ->
          if @current_user\endorses(@module)
            input type: "submit", value: "de-endorse"
            input type: "hidden", name: "action", value: "deendorse"
          else
            input type: "submit", value: "endorse"
            input type: "hidden", name: "action", value: "endorse"
    div id: "labels", ->
      h1 "Labels"
      ul ->
        for l in *@module\labels()
          li -> a href: @url_for("main.label", id: l.id), l\get_name()
      if @current_user
        form method: "POST", action: @url_for("main.module", id: @module.id), ->
          input type: "text", name: "label"
          input type: "submit", value: "add label"
          input type: "hidden", name: "action", value: "label"
