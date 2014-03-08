class About extends require "views.base"
  content: =>

    h2 class: "list-header", "About Lua Toolbox"
    div class: "cell", ->
        p ->
            text "Lua Toolbox is an "
            a href: "https://github.com/catwell/lua-toolbox/", "Open Source"
            text " website aiming at helping with the discovery and selection"
            text " of Lua modules."
        p ->
            text "For that pupose, it lets its users endorse modules and"
            text " ranks them by number of endorsements. It also has a labels"
            text " system to classify modules by intended use."
        p ->
            text "To help with the project or report bugs, use GitHub issues."
            text " To report security issues that should be fixed before they"
            text " are disclosed, please get in touch with "
            a href:  "http://catwell.info", "Pierre Chapuis"
            text "."

    h2 class: "list-header", "Metrics"
    div class: "cell", ->
        h3 "Endorsements per module"
        object type: "image/svg+xml", data: table.concat {
            "http://api.chartspree.com/bar.svg",
            "?series=#{table.concat(@endorsement_data.values, ",")}",
            "&_labels=#{table.concat(@endorsement_data.labels, ",")}",
            "&_show_legend=false",
            "&_height=300px",
        }
