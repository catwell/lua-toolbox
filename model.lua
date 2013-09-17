local redis = require "redis"

local cfg = require("lapis.config").get()
local pfx = cfg.appname

local R = redis.connect(cfg.redis.host, cfg.redis.port)

local rk = function(...)
  return table.concat({pfx, ...}, ":")
end

local create_user = function(login, fullname)
  R:hset(rk("users"), login, fullname)
end

local get_user_by_login = function(login)
  local fullname = R:hget(rk("users"), login)
  if fullname then
    return {login = login, fullname = fullname}
  else return nil end
end

local init = function()
  create_user("tester", "My Test User")
end

return {
  create_user = create_user,
  get_user_by_login = get_user_by_login,
  init = init,
}
