import Widget from require "lapis.html"

class Greeter extends Widget
  content: =>
    if @errors
      for error in *@errors
        p ->
          em "ERROR"
          text " " .. error
    else
      p "Hello, #{@name}."
    a href: @url_for("home"), "back home"
