import Widget from require "lapis.html"

class Home extends Widget
  content: =>
    div id: "userlogin", ->
      if @current_user
        p "Logged in as " .. @current_user\get_fullname()
        a href: @url_for("auth.logout"), "logout"
      else
        a href: @url_for("auth.login"), "login"
    div id: "modules", ->
      h1 "Modules"
      ul ->
        for m in *@modules
          li -> a href: @url_for("main.module", id: m.id), m\get_name()
