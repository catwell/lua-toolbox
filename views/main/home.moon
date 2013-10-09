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
            -- a class: "module-name", href: @url_for("main.module", id: m.id), m\get_name()
            h3 class: "module-name", m\get_name()
            p class: "module-description", m\get_description()
            p class: "module-endorsers", ->
              endorsers = m\endorsers()
              len = #endorsers
              if len > 0
                last = endorsers[len]
                endorsers[len] = nil
                text "Endorsed by: "
                for u in *endorsers
                  a href: @url_for("main.user", id: u.id), u\get_fullname()
                  text ", "
                a href: @url_for("main.user", id: last.id), last\get_fullname()
                text "."

