local lua = require "lapis.lua"
local lapis = require "lapis.init"

local lapis_application = require "lapis.application"
local respond_to = lapis_application.respond_to
local yield_error = lapis_application.yield_error
local capture_errors_json = lapis_application.capture_errors_json

local lapis_validate = require "lapis.validate"
local assert_valid = lapis_validate.assert_valid

local fmt = string.format
local cfg = require("lapis.config").get()
local model = require "model"
local User = model.User
local Module = model.Module
local Label = model.Label

local app = {
  path = "/api",
  name = "api.",
}

app[{deendorse = "/toggle-endorsement"}] = respond_to {
  POST = capture_errors_json(function(self)
    assert_valid(self.params, {
      {"id", is_integer = true},
    })
    local u = self.current_user
    if not u then
      yield_error("not logged in")
    end
    local m = Module:new(self.params.id)
    if u:endorses(m) then
      u:deendorse(m)
    else
      u:endorse(m)
    end
    return {json = {ok = true}}
  end),
}

return lua.class(app, lapis.Application)
