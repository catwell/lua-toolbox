import Widget from require "lapis.html"

class GreeterLayout extends Widget
  content: =>
    html_5 ->
      head ->
        title @title or "Hello!"
        link rel: "stylesheet", href: "/static/css/main.css"
      body ->
        h1 "Hello!"
        @content_for "inner"
