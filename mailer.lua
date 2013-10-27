local tls_mailer = require "tls-mailer"
local cfg = require("lapis.config").get()

if cfg._name == "development" then
  return {}
end

local sender = {
  email = "no-reply@toolbox.luafr.org",
  name = "Lua Toolbox",
}

local mailer = tls_mailer.new{
  server = cfg.smtp.server,
  user = cfg.smtp.user,
  password = cfg.smtp.password,
}

local send_message = function(user, subject, text)
  local recipient = {
    email = user:get_email(),
    name = user:get_fullname(),
  }
  local r, e = mailer:send{
    from = sender,
    to = recipient,
    subject = subject,
    text = text,
  }
  assert(r, e) -- TODO better
end

local signup_tpl = [[
Hello %s,

click here to confirm your account on Lua Toolbox:
%s

--%s
The Lua Toolbox robot team
]]

local send_signup = function(user, link)
  send_message(
    user,
    "Lua Toolbox: activate your account",
    string.format(signup_tpl, user:get_fullname(), link, " ")
  )
end

local resetpw_tpl = [[
Hello %s,

click here to reset your password on Lua Toolbox:
%s

--%s
The Lua Toolbox robot team
]]

local send_resetpw = function(user, link)
  send_message(
    user,
    "Lua Toolbox: reset your password",
    string.format(resetpw_tpl, user:get_fullname(), link, " ")
  )
end

return {
  send_signup = send_signup,
  send_resetpw = send_resetpw,
}
