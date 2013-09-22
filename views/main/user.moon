import Widget from require "lapis.html"

class User extends Widget
  content: =>
    h1 @user\get_fullname()
    div id: "endorsements", ->
      h1 "Endorsements"
      ul ->
        for m in *@user\endorsements()
          li -> a href: @url_for("main.module", id: m.id), m\get_name()
