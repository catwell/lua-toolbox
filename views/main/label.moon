class Label extends require "views.base"
  content: =>
    div id: "modules", ->
      h2 class: "list-header", ->
        text #@modules
        text " modules labelled "
        text @label\get_name()
      @render_modules_list(@modules)
