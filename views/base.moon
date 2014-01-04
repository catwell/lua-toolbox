import Widget from require "lapis.html"

class Base extends Widget

  render_endorse_button: (m) =>
    if @current_user
      button class: "module-endorse #{@current_user\endorses(m) and "endorsed" or ""}", ["data-module-id"]: m.id, ->
        span class: "regular", "endorse"
        span class: "endorsed", "endorsed"
        span class: "hover", "deendorse"

  render_users_txtlist: (users, prefix) =>
    len = #users
    if len > 0
      last = users[len]
      users[len] = nil
      text prefix
      for u in *users
        a href: @url_for("main.user", id: u.id), u\get_fullname()
        text ", "
      a href: @url_for("main.user", id: last.id), last\get_fullname()
      text "."

  render_endorsers: (endorsers) =>
    p class: "module-endorsers", ->
      @render_users_txtlist(endorsers, "Endorsed by: ")

  render_module_link: (m) =>
    url = @module\get_url()
    if url
      p -> a href: url, url

  render_modules_txtlist: (deps, prefix) =>
    len = #deps
    if len > 0
      last = deps[len]
      deps[len] = nil
      text prefix
      for u in *deps
        a href: @url_for("main.module", id: u.id), u\get_name()
        text ", "
      a href: @url_for("main.module", id: last.id), last\get_name()
      text "."

  render_dependencies: (deps) =>
    p class: "module-dependencies", ->
      @render_modules_txtlist(deps, "Depends on: ")

  render_reverse_dependencies: (deps) =>
    p class: "module-reverse-dependencies", ->
      @render_modules_txtlist(deps, "Depended on by: ")

  render_all_dependencies: (m) =>
    deps = m\dependencies()
    rev_deps = m\reverse_dependencies()
    if deps[1]
      @render_dependencies(deps)
    if rev_deps[1]
      @render_reverse_dependencies(rev_deps)

  render_labels: (labels) =>
    ul class: "labels-list", ->
      for l in *labels
        li ->
          a href: @url_for("main.label", id: l.id), l\get_name()

  render_endorsers_and_labels: (m) =>
      endorsers = m\endorsers()
      labels = m\labels(sort: "get_name")
      if endorsers[1]
        @render_endorsers(endorsers)
      if labels[1]
        div class: "labels-container", ->
          text "Labels: "
          @render_labels(labels)

  render_modules_list: (modules) =>
    ul class: "modules-list", ->
      for m in *modules
        li ->
          @render_endorse_button(m)
          a class: "module-name", href: @url_for("main.module", id: m.id), m\get_name()
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
