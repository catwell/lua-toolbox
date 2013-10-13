import Widget from require "lapis.html"

class Base extends Widget

  render_endorse_button: (m) =>
    if @current_user
      button class: "module-endorse #{@current_user\endorses(m) and "endorsed" or ""}", ["data-module-id"]: m.id, ->
        span class: "regular", "endorse"
        span class: "endorsed", "endorsed"
        span class: "hover", "deendorse"

  render_generic: (list, get_name, prefix, route) =>
    len = #list
    if len > 0
      last = list[len]
      list[len] = nil
      text prefix
      for u in *list
        a href: @url_for(route, id: u.id), u[get_name](u)
        text ", "
      a href: @url_for(route, id: last.id), last[get_name](last)
      text "."

  render_endorsers: (endorsers) =>
    p class: "module-endorsers", ->
      @render_generic(endorsers, "get_fullname", "Endorsed by: ", "main.user")

  render_labels: (labels) =>
    p class: "module-labels", ->
      @render_generic(labels, "get_name", "Labels: ", "main.label")

  render_modules_list: (modules) =>
    ul class: "modules-list", ->
      for m in *modules
        li ->
          @render_endorse_button(m)
          a class: "module-name", href: @url_for("main.module", id: m.id), m\get_name()
          --h3 class: "module-name", m\get_name()
          p class: "module-description", m\get_description()
          @render_endorsers(m\endorsers())

  render_errors: () =>
    if @errors
      div id: "errors", ->
        for error in *@errors
          p ->
            em "ERROR"
            text " " .. error

Base
