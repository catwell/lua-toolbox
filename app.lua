local fmt = string.format

local lua = require "lapis.lua"
local lapis = require "lapis.init"
local logger = require "lapis.logging"
local model = require "model"
local cfg = require("lapis.config").get()
local rand_id = (require "helpers").rand_id

local app = {}

app.handle_404 = function(self)
  self.res.status = 404
  return fmt("NOT FOUND: %s", self.req.cmd_url)
end

local _super = lapis.Application.handle_error
app.handle_error = function(self, err, trace, ...)
  if cfg._name == "development" then
    return _super(self, err, trace, ...)
  end
  local errid = rand_id(16)
  ngx.log(ngx.ERR, fmt("\nerrid: %s\n", errid), err, trace, "\n")
  self.res.status = 500
  self.buffer = fmt("Something went wrong (error 500, id %s).", errid)
  self:render()
  logger.request(self)
  return self
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
