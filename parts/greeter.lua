local lua = require "lapis.lua"
local lapis = require "lapis.init"

local lapis_application = require "lapis.application"
local respond_to = lapis_application.respond_to
local yield_error = lapis_application.yield_error
local capture_errors = lapis_application.capture_errors

local lapis_validate = require "lapis.validate"
local assert_valid = lapis_validate.assert_valid

local fmt = string.format

local model = require "model"

local app = {
  path = "/greet",
  name = "greeter.",
}

app[{greet = "/:login"}] = respond_to {
  GET = capture_errors(function(self)
    assert_valid(self.params, {
      {"login", min_length = 2, max_length = 128},
    })
    local user = model.get_user_by_login(self.params.login)
    if user then
      self.name = user.fullname
    else
      yield_error("unexpected guest")
    end
    return {
      render = true,
      layout = "greeter.layout",
    }
  end),
}

-- BELOW: This does not work:
-- app.layout = require "views.greeter.layout"

return lua.class(app, lapis.Application)
