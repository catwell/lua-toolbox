-- NOTE: nothing is atomic for now

local redis = require "redis"
local bcrypt = require "bcrypt"

-- monkey-patch required to make rocks loading work
local lr_fetch = require "luarocks.fetch"
local lr_path = require "luarocks.path"
lr_path.configure_paths = function(rockspec) end

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
  local hash = R:hget(rk("user", self.id), "pwhash")
  return bcrypt.verify(pwd, hash)
end

local user_set_password = function(self, pwd)
  assert(type(pwd) == "string")
  local salt = bcrypt.salt(10)
  local hash = assert(bcrypt.digest(pwd, salt))
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
  return u
end

local Module = {}

--- Module

local load_rockspec = function(rs)
  if type(rs) == "string" then
    rs = lr_fetch.load_rockspec(rs)
  end
  assert(type(rs) == "table")
  return rs
end

local module_update_with_rockspec = function(self, rs)
  rs = load_rockspec(rs)
  assert(rs and rs.name)
  self:set_name(rs.name)
end

local module_get_name = function(self)
  return R:hget(rk("module", self.id), "name")
end

local module_set_name = function(self, name)
  assert(type(name) == "string")
  local old_name = self:get_name()
  if old_name then
    R:hdel(rk("module", "by_name"), name)
  end
  R:hset(rk("module", "by_name"), name, self.id)
  R:hset(rk("module", self.id), "name", name)
end

local module_methods = {
  update_with_rockspec = module_update_with_rockspec,
  get_name = module_get_name,
  set_name = module_set_name,
}

Module.new = function(id)
  id = assert(tonumber(id))
  local r = {id = id}
  return setmetatable(r, {__index=module_methods})
end

Module.all = function()
  local ids = R:hvals(rk("module", "by_name"))
  local r = {}
  for i=1,#ids do
    r[i] = Module.new(ids[i])
  end
  return r
end

Module.exists = function(id)
  assert(type(id) == "number")
  return R:hexists(rk("module", id), "name")
end

Module.resolve_name = function(name)
  assert(type(name) == "string")
  return tonumber(R:hget(rk("module", "by_name"), name))
end

Module.get_by_name = function(name)
  assert(type(name) == "string")
  local id = Module.resolve_name(name)
  if id then
    return Module.new(id)
  else return nil end
end

Module.next_id = function()
  return R:incr(rk("module", "next_id"))
end

Module.create = function(t)
  rs = t.rockspec and load_rockspec(t.rockspec) or nil
  if rs then assert(rs.name) end
  local name = assert(t.name or (rs and rs.name))
  assert(not Module.resolve_name(name))
  local m =  Module.new( Module.next_id() )
  m:set_name(name)
  return m
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
  Module = Module,
  init = init,
  load_rockspec = load_rockspec,
}
