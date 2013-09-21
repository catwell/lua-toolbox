-- NOTES:
-- I took a few shortcuts:
-- - nothing is atomic for now
-- - passwords are hashed as MD5 (!!)
-- Those issues should be fixed before any kind of release.


local redis = require "redis"
local md5 = require "md5"

local cfg = require("lapis.config").get()
local pfx = cfg.appname

local R = redis.connect(cfg.redis.host, cfg.redis.port)

local rk = function(...)
  return table.concat({pfx, ...}, ":")
end

local User = {}

--- User

local user_get_email = function(self)
  return R:hget(rk("user", self.id), "email")
end

local user_set_email = function(self, email)
  assert(type(email) == "string")
  local old_email = self:get_email()
  if old_email then
    R:hdel(rk("user", "by_email"), email)
  end
  R:hset(rk("user", "by_email"), email, self.id)
  R:hset(rk("user", self.id), "email", email)
end

local user_get_fullname = function(self)
  return R:hget(rk("user", self.id), "fullname")
end

local user_set_fullname = function(self, fullname)
  R:hset(rk("user", self.id), "fullname", fullname)
end

local user_check_password = function(self, pwd)
  assert(type(pwd) == "string")
  local hash = assert(md5.sumhexa(pwd))
  local verif = R:hget(rk("user", self.id), "pwhash")
  return hash == verif
end

local user_set_password = function(self, pwd)
  assert(type(pwd) == "string")
  local hash = assert(md5.sumhexa(pwd))
  R:hset(rk("user", self.id), "pwhash", hash)
end

local user_methods = {
  get_email = user_get_email,
  set_email = user_set_email,
  get_fullname = user_get_fullname,
  set_fullname = user_set_fullname,
  check_password = user_check_password,
  set_password = user_set_password,
}

User.new = function(id)
  id = assert(tonumber(id))
  local r = {id = id}
  return setmetatable(r, {__index=user_methods})
end

User.exists = function(id)
  assert(type(id) == "number")
  return R:hexists(rk("user", id), "email")
end

User.resolve_email = function(email)
  assert(type(email) == "string")
  return tonumber(R:hget(rk("user", "by_email"), email))
end

User.get_by_email = function(email)
  assert(type(email) == "string")
  local id = User.resolve_email(email)
  if id then
    return User.new(id)
  else return nil end
end

User.next_id = function()
  return R:incr(rk("user", "next_id"))
end

User.create = function(t)
  local email = assert(t.email)
  assert(not User.resolve_email(email))
  local u =  User.new( User.next_id() )
  u:set_email(email)
  if t.password then u:set_password(t.password) end
  if t.fullname then u:set_fullname(t.fullname) end
end

local init = function()
  if cfg._name == "development" then
    if not User.resolve_email("johndoe@example.com") then
      User.create{
        email = "johndoe@example.com",
        fullname = "John Doe",
        password = "tagazok",
      }
    end
  end
end

return {
  User = User,
  init = init,
}
