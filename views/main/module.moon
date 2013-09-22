import Widget from require "lapis.html"

class Module extends Widget
  content: =>
    h1 @module\get_name()
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
