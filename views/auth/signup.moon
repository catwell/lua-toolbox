class Signup extends require "views.base"
  content: =>
    @render_errors()
    div id: "signupform", ->
      if @current_user
        p "Already logged in as " .. @current_user\get_fullname()
        a href: @url_for("auth.logout") .. "?redirect=auth.signup", "logout"
      else
        form method: "POST", action: @url_for("auth.signup"), ->
          label for: "email", ->
            text "E-Mail"
            span class:"form-tip", "Not public, we will never spam you."
          input type: "text", id: "email", name: "email"
          label for: "fullname", ->
            text "Full Name"
            span class:"form-tip", "How you will appear to other users."
          input type: "text", id: "fullname", name: "fullname"
          label for: "password", ->
            text "Password"
            span class:"form-tip", "At least 5 characters. We use bcrypt."
          input type: "password", id: "password", name: "password"
          label for: "confirm", "Confirm Password"
          input type: "password", id: "confirm", name: "confirm"
          input type: "submit", value: "signup"
