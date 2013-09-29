-- NOTE: nothing is atomic for now

local redis = require "redis"
local bcrypt = require "bcrypt"
local redismodel = require "redismodel"

-- monkey-patch required to make rocks loading work
local lr_fetch = require "luarocks.fetch"
local lr_path = require "luarocks.path"
lr_path.configure_paths = function(rockspec) end

local cfg = require("lapis.config").get()
local pfx = cfg.appname

local R = redis.connect(cfg.redis.host, cfg.redis.port)

--- declarations

local User = redismodel.new{
  redis = R,
  prefix = pfx,
  name = "user",
}

User:add_attribute("email")
User:add_index("email")
User:add_attribute("fullname")
User:add_attribute("password")

local Module = redismodel.new{
  redis = R,
  prefix = pfx,
  name = "module",
}

Module:add_attribute("name")
Module:add_index("name")

local Label = redismodel.new{
  redis = R,
  prefix = pfx,
  name = "label",
}

Label:add_attribute("name")
Label:add_index("name")

--- User

User.methods.check_password = function(self, pwd)
  assert(type(pwd) == "string")
  local hash = assert(self:getattr("pwhash"))
  return bcrypt.verify(pwd, hash)
end

User.methods.get_password = function(self)
  return nil
end

User.methods.set_password = function(self, pwd)
  assert(type(pwd) == "string")
  local salt = bcrypt.salt(10)
  local hash = assert(bcrypt.digest(pwd, salt))
  self:setattr("pwhash", hash)
end

User.methods.endorse = function(self, m)
  assert(
    (type(m) == "table")
    and tonumber(m.id)
  )
  R:sadd(self:rk("endorsements"), m.id)
  R:sadd(m:rk("endorsers"), self.id)
end

User.methods.deendorse = function(self, m)
  assert(
    (type(m) == "table")
    and tonumber(m.id)
  )
  R:srem(self:rk("endorsements"), m.id)
  R:srem(m:rk("endorsers"), self.id)
end

User.methods.endorsements = function(self)
  local ids = R:smembers(self:rk("endorsements"))
  return Module:all_with_ids(ids)
end

User.methods.endorses = function(self, m)
  assert(
    (type(m) == "table")
    and tonumber(m.id)
  )
  return R:sismember(self:rk("endorsements"), m.id)
end

--- Module

local load_rockspec = function(rs)
  if type(rs) == "string" then
    rs = lr_fetch.load_rockspec(rs)
  end
  assert(type(rs) == "table")
  return rs
end

local _super = Module.m_methods.create
Module.m_methods.create = function(cls, t)
  local rs = t.rockspec and load_rockspec(t.rockspec)
  if rs then assert(rs.name) end
  t.name = t.name or (rs and rs.name)
  _super(cls, t)
end

Module.methods.update_with_rockspec = function(self, rs)
  rs = load_rockspec(rs)
  assert(rs and rs.name)
  self:set_name(rs.name)
end

Module.methods.endorsers = function(self)
  local ids = R:smembers(self:rk("endorsers"))
  return User:all_with_ids(ids)
end

Module.methods.label = function(self, l)
  assert(
    (type(l) == "table")
    and tonumber(l.id)
  )
  R:sadd(self:rk("labels"), l.id)
  R:sadd(l:rk("modules"), self.id)
end

Module.methods.unlabel = function(self, l)
  assert(
    (type(l) == "table")
    and tonumber(l.id)
  )
  R:srem(self:rk("labels"), l.id)
  R:srem(l:rk("modules"), self.id)
end

Module.methods.labels = function(self)
  local ids = R:smembers(self:rk("labels"))
  return Label:all_with_ids(ids)
end

Module.methods.has_label = function(self, l)
  assert(
    (type(l) == "table")
    and tonumber(l.id)
  )
  return R:sismember(self:rk("labels"), l.id)
end

--- Label

Label.methods.modules = function(self)
  local ids = R:smembers(self:rk("modules"))
  return Module:all_with_ids(ids)
end

--- others

local init = function()
  if cfg._name == "development" then
    if not User:resolve_email("johndoe@example.com") then
      User:create{
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
  Label = Label,
  init = init,
  load_rockspec = load_rockspec,
}
