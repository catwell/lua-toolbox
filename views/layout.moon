import Widget from require "lapis.html"

class MainLayout extends Widget
  content: =>
    html_5 ->
      head ->
        title @title or "Lua Toolbox"
        link rel: "stylesheet", href: "//fonts.googleapis.com/css?family=Raleway"
        link rel: "stylesheet", href: "//fonts.googleapis.com/css?family=Libre+Baskerville"
        link rel: "stylesheet", href: "/static/css/main.css"
        meta name: "google-site-verification", content: "xA4gPzb1vGS19EoreEaT8Up1hOtdYhInOyFuC4GTQ-g"
      body ->
        div id: "container", ->
          div id: "mainmenu", ->
            nav class: "left", ->
              a href: @url_for("main.home"), "Lua Toolbox"
            nav class: "right", ->
              a href: @url_for("main.about"), "about"
              span " | "
              if @current_user
                a href: @url_for("main.user", id: @current_user.id), @current_user\get_fullname()
                span " | "
                a href: @url_for("auth.logout"), "logout"
              else
                a href: @url_for("auth.login"), "login"
                span " | "
                a href: @url_for("auth.signup"), "sign up"
            div style: "clear: both;"
          @content_for "inner"
        script src: "//ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"
        script src: "/static/js/main.js"
