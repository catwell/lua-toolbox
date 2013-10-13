class Module extends require "views.base"
  content: =>
    h2 class: "list-header", @module\get_name()
    @render_errors()
    div class: "cell", ->
      @render_endorse_button(@module)
      @render_endorsers(@module\endorsers())
      @render_labels(@module\labels())
      if @current_user
        form method: "POST", action: @url_for("main.module", id: @module.id), ->
          input type: "text", name: "label"
          input type: "submit", value: "add label"
          input type: "hidden", name: "action", value: "label"
