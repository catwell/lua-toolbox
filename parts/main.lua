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
local Label = model.Label

local app = {
  path = "",
  name = "main.",
}

app[{home = "/"}] = respond_to {
  GET = function(self)
    self.title = cfg.appname
    self.modules = Module:all()
    return {render = true}
  end,
}

app[{["module"] = "/module/:id"}] = respond_to {
  GET = function(self)
    self.module = Module:new(self.params.id)
    return {render = true}
  end,
  POST = capture_errors(function(self)
    local u = assert(self.current_user)
    local m = Module:new(self.params.id)
    local action = self.params.action
    assert(type(action) == "string")
    self.module = m
    if action == "endorse" then
      assert(not u:endorses(m))
      u:endorse(m)
    elseif action == "deendorse" then
      assert(u:endorses(m))
      u:deendorse(m)
    elseif action == "label" then
      assert_valid(self.params, {
        {"label", min_length = 3, max_length = 128},
      })
      l = Label:get_by_name(self.params.label)
      if not l then
        l = Label:create{name = self.params.label}
      end
      m:label(l)
    else
      error(fmt("invalid action %s", action))
    end
    return {render = true}
  end),
}

app[{["label"] = "/label/:id"}] = respond_to {
  GET = function(self)
    self.label = Label:new(self.params.id)
    return {render = true}
  end,
}

app[{user = "/user/:id"}] = respond_to {
  GET = function(self)
    self.user = User:new(self.params.id)
    return {render = true}
  end,
}

return lua.class(app, lapis.Application)
