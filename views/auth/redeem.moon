class Redeem extends require "views.base"
  content: =>
    @render_errors()
    div ->
      if @user
        p "Hello #{@user\get_fullname()}, choose your password:"
        form method: "POST", action: @url_for("auth.redeem", tk: @tk), ->
          label for: "password", ->
            text "Password"
            span class:"form-tip", "At least 5 characters. We use bcrypt."
          input type: "password", id: "password", name: "password"
          label for: "confirm", "Confirm Password"
          input type: "password", id: "confirm", name: "confirm"
          input type: "submit", value: "submit"
