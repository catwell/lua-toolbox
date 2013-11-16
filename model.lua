-- NOTE: nothing is atomic for now

local redis = require "redis"
local bcrypt = require "bcrypt"
local redismodel = require "redismodel"

-- monkey-patch required to make rocks loading work
local lr_fetch = require "luarocks.fetch"
local lr_path = require "luarocks.path"
local lr_deps = require "luarocks.deps"
lr_path.configure_paths = function(rockspec) end

local cfg = require("lapis.config").get()
local pfx = cfg.appname

local R = redis.connect(unpack(cfg.redis))

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
User:add_attribute("trust_level")

local Module = redismodel.new{
  redis = R,
  prefix = pfx,
  name = "module",
}

Module:add_attribute("name")
Module:add_index("name")
Module:add_attribute("version")
Module:add_attribute("url")
Module:add_attribute("description")

local Label = redismodel.new{
  redis = R,
  prefix = pfx,
  name = "label",
}

Label:add_attribute("name")
Label:add_index("name")

redismodel.add_nn_assoc {
  master = User,
  slave = Module,
  assoc_create = "endorse",
  assoc_remove = "deendorse",
  assoc_check = "endorses",
  master_collection = "endorsements",
  slave_collection = "endorsers",
}

redismodel.add_nn_assoc {
  master = Module,
  slave = Label,
  assoc_create = "label",
  assoc_remove = "unlabel",
  assoc_check = "has_label",
  master_collection = "labels",
  slave_collection = "modules",
}

--- User

User.methods.check_password = function(self, pwd)
  assert(type(pwd) == "string")
  local hash = self:getattr("pwhash")
  if not hash then return false end
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

User.methods.get_trust_level = function(self)
  return tonumber(self:getattr("trust_level")) or 0
end

User.methods.invalidate_token = function(self)
  local tk = self:getattr("pwtoken")
  if tk then
    self.model.R:del(self.model:rk("_tk_" .. tk))
    self:delattr("pwtoken")
  end
end

local rand_id = function(n)
  local r = {}
  for i=1,n do r[i] = string.char(math.random(65,90)) end
  return table.concat(r)
end

User.methods.make_token = function(self)
  self:invalidate_token()
  local tk = rand_id(10)
  self:setattr("pwtoken", tk)
  local duration = 3600 * 24 * 10 -- 10 days
  self.model.R:setex(self.model:rk("_tk_" .. tk), duration, self.id)
  return tk
end

User.m_methods.resolve_token = function(cls, tk)
  assert(type(tk) == "string")
  local id = tonumber(cls.R:get(cls:rk("_tk_" .. tk)))
  if not id then return nil end
  local u = cls:new(id)
  assert(u:getattr("pwtoken") == tk)
  return u
end

local _super = User.methods.export
User.methods.export = function(self)
  local r = _super(self)
  r.pwhash = self:getattr("pwhash")
  return r
end

--- Module

local load_rockspec = function(rs)
  if type(rs) == "string" then
    rs = lr_fetch.load_rockspec(rs)
  end
  assert(type(rs) == "table")
  if type(rs.description) == "table" then
    rs.url = rs.url or rs.description.homepage
    rs.description = rs.description.summary or rs.description.detailed
  end
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
  -- -> changed?
  rs = load_rockspec(rs)
  assert(rs and rs.name and rs.version)
  assert(rs.name == self:get_name())
  local old_version = self:get_version()
  if old_version then
    if old_version == rs.version then
      if self:check_attributes(rs) then
        return false
      end
    elseif lr_deps.compare_versions(old_version, rs.version) then
      return false
    end
  end
  for k,_ in pairs(self.model.attributes) do
    if rs[k] then self["set_" .. k](self, rs[k]) end
  end
  return true
end

Module.sort_by_nb_endorsers = {
  function(self) return {self:nb_endorsers(), self:get_name()} end,
  function(a, b) return (a[1] == b[1]) and (a[2] < b[2]) or (a[1] > b[1]) end,
}

--- others

local init = function()
  if cfg._name == "development" then
    if not User:resolve_email("johndoe@example.com") then
      User:create{
        email = "johndoe@example.com",
        fullname = "John Doe",
        password = "tagazok",
        trust_level = 2,
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
