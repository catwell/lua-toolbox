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

local mailer = require "mailer"

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
    })
    if User:resolve_email(self.params.email) then
      yield_error(fmt("user %s already exists", self.params.email))
    end
    local u = User:create{
      email = self.params.email,
      fullname = self.params.fullname,
    }
    local tk = u:make_token()
    if cfg._name == "development" then
      return self:html(function()
        p(fmt("DEV MODE. Token: %s", tk))
      end)
    else
      mailer.send_signup(
        u,
        self:build_url(self:url_for("auth.redeem", {tk = tk}))
      )
      return self:html(function()
        p("Email sent, check your inbox!")
      end)
    end
  end),
}

app[{logout = "/logout"}] = respond_to {
  GET = function(self)
    self.session.current_user_id = false -- TODO should be nil
    redir = self.params.redirect or "main.home"
    return {redirect_to = self:url_for(redir)}
  end,
}

app[{forgotpassword = "/forgot-password"}] = respond_to {
  GET = function(self)
    return {render = true}
  end,
  POST = capture_errors(function(self)
    assert_valid(self.params, {
      {"email", is_email = true, max_length = 128},
    })
    local u = User:get_by_email(self.params.email)
    if not u then
      yield_error(fmt("user %s not found", self.params.email))
    end
    local tk = u:make_token()
    if cfg._name == "development" then
      return self:html(function()
        p(fmt("DEV MODE. Token: %s", tk))
      end)
    else
      mailer.send_resetpw(
        u,
        self:build_url(self:url_for("auth.redeem", {tk = tk}))
      )
      return self:html(function()
        p("Email sent, check your inbox!")
      end)
    end
  end),
}

app[{redeem = "/redeem/:tk"}] = respond_to {
  GET = capture_errors(function(self)
    if self.current_user then
      yield_error("already logged in")
    end
    assert_valid(self.params, {
      {"tk", min_length = 10, max_length = 10},
    })
    self.tk = self.params.tk
    local u = User:resolve_token(self.tk)
    if not u then
      yield_error("invalid token")
    end
    self.user = u
    return {render = true}
  end),
  POST = capture_errors(function(self)
    if self.current_user then
      yield_error("already logged in")
    end
    assert_valid(self.params, {
      {"tk", min_length = 10, max_length = 10},
    })
    self.tk = self.params.tk
    local u = User:resolve_token(self.tk)
    if not u then
      yield_error("invalid token")
    end
    self.user = u
    assert_valid(self.params, {
      {"password", min_length = 5, max_length = 128},
      {"confirm", equals = self.params.password},
    })
    u:set_password(self.params.password)
    u:invalidate_token()
    self.session.current_user_id = u.id
    return {redirect_to = self:url_for("main.home")}
  end),
}

return lua.class(app, lapis.Application)
