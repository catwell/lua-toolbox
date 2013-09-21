import Widget from require "lapis.html"

class Login extends Widget
  content: =>
    div id: "loginform", ->
      for error in *(@errors or {})
        p ->
          em "ERROR"
          text " " .. error
      if @current_user
        p "Already logged in as " .. @current_user\get_fullname()
        a href: @url_for("auth.logout"), "logout"
      else
        form method: "POST", action: @url_for("auth.login"), ->
          label for: "email", "email"
          input type: "text", id: "email", name: "email"
          label for: "password", "password"
          input type: "password", id: "password", name: "password"
          input type: "submit", value: "login"
