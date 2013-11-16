import Widget from require "lapis.html"

class Base extends Widget

  render_endorse_button: (m) =>
    if @current_user
      button class: "module-endorse #{@current_user\endorses(m) and "endorsed" or ""}", ["data-module-id"]: m.id, ->
        span class: "regular", "endorse"
        span class: "endorsed", "endorsed"
        span class: "hover", "deendorse"

  render_endorsers: (endorsers) =>
    p class: "module-endorsers", ->
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

  render_labels: (labels) =>
    ul class: "labels-list", ->
      for l in *labels
        li ->
          a href: @url_for("main.label", id: l.id), l\get_name()

  render_endorsers_and_labels: (m) =>
      endorsers = m\endorsers()
      labels = m\labels("get_name")
      if endorsers[1]
        @render_endorsers(endorsers)
      if labels[1]
        text "Labels: "
        @render_labels(labels)

  render_modules_list: (modules) =>
    ul class: "modules-list", ->
      for m in *modules
        li ->
          @render_endorse_button(m)
          a class: "module-name", href: @url_for("main.module", id: m.id), m\get_name()
          --h3 class: "module-name", m\get_name()
          p class: "module-description", m\get_description()
          @render_endorsers_and_labels(m)

  render_errors: () =>
    if @errors
      div id: "errors", ->
        for error in *@errors
          p ->
            em "ERROR"
            text " " .. error

Base
