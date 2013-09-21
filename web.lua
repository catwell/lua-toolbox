local lua = require "lapis.lua"
local lapis = require "lapis.init"
require "extensions"

local lapis_application = require "lapis.application"
local respond_to = lapis_application.respond_to

local fmt = string.format

local cfg = require("lapis.config").get()

local model = require "model"
model.init()

local app = {}

app[{home = "/"}] = respond_to {
  GET = function(self)
    self.title = cfg.appname
    local email = "johndoe@example.com"
    return self:html(function()
      a({href = self:url_for("greeter.greet", {email = email})}, "greet")
    end)
  end,
}

app.handle_404 = function(self)
  return fmt("NOT FOUND: %s", self.req.cmd_url)
end

app.layout = require "views.layout"

app = lua.class(app, lapis.Application)
app:include(require "parts.auth")
app:include(require "parts.greeter")

app:before_filter(function(self)
  local id = self.session.current_user_id
  if id then
    self.current_user = assert(model.User.new(id))
  end
end)

lapis.serve(app)
