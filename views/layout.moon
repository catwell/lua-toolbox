import Widget from require "lapis.html"

class MainLayout extends Widget
  content: =>
    html_5 ->
      head ->
        title @title or ""
        link rel: "stylesheet", href: "/static/css/main.css"
      body -> @content_for "inner"
