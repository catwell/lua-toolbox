import Widget from require "lapis.html"

class Label extends Widget
  content: =>
    h1 @label\get_name()
    div id: "modules", ->
      h1 "Modules"
      ul ->
        for m in *@label\modules()
          li -> a href: @url_for("main.module", id: m.id), m\get_name()
