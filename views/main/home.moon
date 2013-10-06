import Widget from require "lapis.html"

class Home extends Widget
  content: =>
    div id: "modules", ->
      ul class: "modules-list", ->
        for m in *@modules
          li ->
            if @current_user
              button class: "module-endorse #{@current_user\endorses(m) and "endorsed" or ""}", ["data-module-id"]: m.id, ->
                span class: "regular", "endorse"
                span class: "endorsed", "endorsed"
                span class: "hover", "deendorse"
            a class: "module-name", href: @url_for("main.module", id: m.id), m\get_name()
            p class: "module-description", m\get_description()
