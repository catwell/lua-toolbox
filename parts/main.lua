local lua = require "lapis.lua"
local lapis = require "lapis.init"

local lapis_application = require "lapis.application"
local respond_to = lapis_application.respond_to
local yield_error = lapis_application.yield_error
local capture_errors = lapis_application.capture_errors

local lapis_validate = require "lapis.validate"
local assert_valid = lapis_validate.assert_valid

local fmt = string.format
local cfg = require("lapis.config").get()
local model = require "model"
local User = model.User
local Module = model.Module

local app = {
  path = "",
  name = "main.",
}

app[{home = "/"}] = respond_to {
  GET = function(self)
    self.title = cfg.appname
    self.modules = Module.all()
    return {render = true}
  end,
}

app[{["module"] = "/module/:id"}] = respond_to {
  GET = function(self)
    self.module = Module.new(self.params.id)
    return {render = true}
  end,
  POST = function(self)
    local u = assert(self.current_user)
    local m = Module.new(self.params.id)
    local action = self.params.action
    assert(type(action) == "string")
    if action == "endorse" then
      assert(not u:endorses(m))
      u:endorse(m)
    elseif action == "deendorse" then
      assert(u:endorses(m))
      u:deendorse(m)
    else
      error("invalid action %s" % action)
    end
    self.module = m
    return {render = true}
  end,
}

app[{user = "/user/:id"}] = respond_to {
  GET = function(self)
    self.user = User.new(self.params.id)
    return {render = true}
  end,
}

return lua.class(app, lapis.Application)
