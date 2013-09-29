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
local User = model.User

local app = {
  path = "",
  name = "auth.",
}

app[{login = "/login"}] = respond_to {
  GET = function(self)
    return {render = true}
  end,
  POST = capture_errors(function(self)
    assert_valid(self.params, {
      {"email", is_email = true, max_length = 128},
      {"password", min_length = 5, max_length = 128},
    })
    local u = User:get_by_email(self.params.email)
    if not u then
      yield_error(fmt("user %s not found", self.params.email))
    end
    if not u:check_password(self.params.password) then
      yield_error(fmt("invalid password for user %s", self.params.email))
    end
    self.session.current_user_id = u.id
    return {redirect_to = self:url_for("main.home")}
  end),
}

app[{signup = "/signup"}] = respond_to {
  GET = function(self)
    return {render = true}
  end,
  POST = capture_errors(function(self)
    assert_valid(self.params, {
      {"email", is_email = true, max_length = 128},
      {"fullname", min_length = 2, max_length = 128},
      {"password", min_length = 5, max_length = 128},
      {"confirm", equals = self.params.password},
    })
    if User:resolve_email(self.params.email) then
      yield_error(fmt("user %s already exists", self.params.email))
    end
    local u = User:create{
      email = self.params.email,
      fullname = self.params.fullname,
      password = self.params.password,
    }
    self.session.current_user_id = u.id
    return {redirect_to = self:url_for("main.home")}
  end),
}

app[{logout = "/logout"}] = respond_to {
  GET = function(self)
    self.session.current_user_id = false -- should be nil
    redir = self.params.redirect or "main.home"
    return {redirect_to = self:url_for(redir)}
  end,
}

return lua.class(app, lapis.Application)
