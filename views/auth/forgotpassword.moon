class ForgetPassword extends require "views.base"
  content: =>
    @render_errors()
    div ->
      if @current_user
        p "Already logged in as " .. @current_user\get_fullname()
        a href: @url_for("auth.logout") .. "?redirect=auth.forgotpassword", "logout"
      else
        form method: "POST", action: @url_for("auth.forgotpassword"), ->
          label for: "email", "E-Mail"
          input type: "text", id: "email", name: "email"
          input type: "submit", value: "reset password"
