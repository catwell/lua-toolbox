local lua = require "lapis.lua"
local lapis = require "lapis.init"
local model = require "model"

local app = {}

app.handle_404 = function(self)
  return fmt("NOT FOUND: %s", self.req.cmd_url)
end

app.layout = require "views.layout"

app = lua.class(app, lapis.Application)

app:include("parts.auth")
app:include("parts.main")
app:include("parts.api")

app:before_filter(function(self)
  local id = self.session.current_user_id
  if id then
    self.current_user = assert(model.User:new(id))
  end
end)

return app
