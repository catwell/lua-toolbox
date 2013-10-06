import Widget from require "lapis.html"

class User extends Widget
  content: =>
    div id: "endorsements", ->
      ul class: "modules-list", ->
        for m in *@user\endorsements()
          li ->
            if @current_user
              button class: "module-endorse #{@current_user\endorses(m) and "endorsed" or ""}", ["data-module-id"]: m.id, ->
                span class: "regular", "endorse"
                span class: "endorsed", "endorsed"
                span class: "hover", "deendorse"
            a class: "module-name", href: @url_for("main.module", id: m.id), m\get_name()
            p class: "module-description", m\get_description()
