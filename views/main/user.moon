class User extends require "views.base"
  content: =>
    div id: "endorsements", ->
      if @current_user and (@current_user.id == @user.id)
        h2 class: "list-header", "Your endorsements"
      else
        h2 class: "list-header", "#{@user\get_fullname()}'s endorsements"
      @render_modules_list(@user\endorsements("get_name"))
