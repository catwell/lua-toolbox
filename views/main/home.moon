class Home extends require "views.base"
  content: =>
    h2 class: "list-header", "All labels"
    div class: "cell", ->
      @render_labels(@labels)
    h2 class: "list-header", "All modules"
    @render_modules_list(@modules)
