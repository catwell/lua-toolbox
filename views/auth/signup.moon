import Widget from require "lapis.html"

class Signup extends Widget
  content: =>
    div id: "signupform", ->
      for error in *(@errors or {})
        p ->
          em "ERROR"
          text " " .. error
      if @current_user
        p "Already logged in as " .. @current_user\get_fullname()
        a href: @url_for("auth.logout") .. "?redirect=auth.signup", "logout"
      else
        form method: "POST", action: @url_for("auth.signup"), ->
          label for: "email", "E-Mail"
          input type: "text", id: "email", name: "email"
          label for: "fullname", "Full Name"
          input type: "text", id: "fullname", name: "fullname"
          label for: "password", "Password"
          input type: "password", id: "password", name: "password"
          label for: "confirm", "Confirm Password"
          input type: "password", id: "confirm", name: "confirm"
          input type: "submit", value: "signup"
