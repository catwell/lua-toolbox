import Widget from require "lapis.html"

class Signup extends Widget
  content: =>
    if @errors
      div id: "errors", ->
        for error in *@errors
          p ->
            em "ERROR"
            text " " .. error
    div id: "signupform", ->
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
