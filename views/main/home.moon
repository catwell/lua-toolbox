class Home extends require "views.base"
  content: =>
    h2 class: "list-header", "Important information"
    div class: "cell", ->
      p ->
        text "Lua Toolbox features are being merged into "
        a href: "https://luarocks.org", "the main LuaRocks website"
        text "."
      p ->
        text "The site is now read-only, which means you can no longer "
        text "endorse modules. Labels have been imported into LuaRocks, "
        text "and you can opt-in to "
        a href: "https://luarocks.org/settings/import-toolbox",
          "transfer your endorsements"
        text "."
      p ->
        text "For more information, please see the corresponding "
        a href: "https://github.com/leafo/luarocks-site/pull/86",
          "GitHub issue"
        text ". "
        text "Lua Toolbox itself, now being redundant, will probably shut "
        text "down completely in a few months. Thank you for using it over "
        text "the last three years. Let us keep improving the Lua ecosystem "
        text "together!"
      p ->
        em ->
          text "Pierre 'catwell' Chapuis"
    h2 class: "list-header", "All labels"
    div class: "cell", ->
      @render_labels(@labels)
    h2 class: "list-header", "All modules"
    @render_modules_list(@modules)
