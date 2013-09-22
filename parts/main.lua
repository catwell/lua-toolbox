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

return lua.class(app, lapis.Application)
