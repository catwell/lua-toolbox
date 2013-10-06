local _getter = function(attr)
  return function(self)
    return self:getattr(attr)
  end
end

local _simple_setter = function(attr)
  return function(self, val)
    return self:setattr(attr, val)
  end
end

local _indexed_setter = function(attr)
  return function(self, val)
    assert(
      (type(val) == "string") or
      (type(val) == "number")
    )
    local old_val = self["get_" .. attr](self)
    if old_val then
      self.model.R:hdel(self.model:rk("_by_" .. attr), val)
    end
    self.model.R:hset(self.model:rk("_by_" .. attr), val, self.id)
    self:setattr(attr, val)
  end
end

local _resolver = function(attr)
  return function(cls, val)
    assert(type(val) == "string")
    return tonumber(cls.R:hget(cls:rk("_by_" .. attr), val))
  end
end

local _indexed_getter = function(attr)
  return function(cls, val)
    assert(type(val) == "string")
    local id = cls["resolve_" .. attr](cls, val)
    if id then
      return cls:new(id)
    else return nil end
  end
end

local rk = function(cls, ...)
  return table.concat({cls.prefix, cls.name, ...}, ":")
end

local add_attribute = function(cls, attr)
  assert(not cls.attributes[attr])
  cls.attributes[attr] = true
  cls.methods["get_" .. attr] = _getter(attr)
  cls.methods["set_" .. attr] = _simple_setter(attr)
end

local add_index = function(cls, attr)
  assert(
    cls.attributes[attr] and
    (not cls.indexed[attr])
  )
  cls.indexed[attr] = true
  cls.methods["set_" .. attr] = _indexed_setter(attr)
  cls.m_methods["resolve_" .. attr] = _resolver(attr)
  cls.m_methods["get_by_" .. attr] = _indexed_getter(attr)
end

local new = function(cls, id)
  id = assert(tonumber(id))
  local r = {
    id = id,
    model = cls,
  }
  return setmetatable(r, {__index=cls.methods})
end

local next_id = function(cls)
  return cls.R:incr(cls:rk("_next_id"))
end

local all_with_ids = function(cls, ids)
  assert(type(ids) == "table")
  local r = {}
  for i=1,#ids do
    r[i] = cls:new(ids[i])
  end
  return r
end

local all = function(cls)
  local ids = cls.R:smembers(cls:rk("_all"))
  return cls:all_with_ids(ids)
end

local exists = function(cls, id)
  assert(type(id) == "number")
  return cls.R:sismember(cls:rk("_all"), id)
end

local create = function(cls, t)
  for attr,_ in pairs(cls.indexed) do
    local x = assert(t[attr])
    assert(not cls["resolve_" .. attr](cls, attr))
  end
  local r = cls:new( cls:next_id() )
  cls.R:sadd(cls:rk("_all"), r.id)
  for attr,_ in pairs(cls.attributes) do
    if t[attr] then r["set_" .. attr](r, t[attr]) end
  end
  return r
end

base_m_methods = function()
  return {
    rk = rk,
    add_attribute = add_attribute,
    add_index = add_index,
    new = new,
    next_id = next_id,
    all_with_ids = all_with_ids,
    all = all,
    exists = exists,
    create = create,
  }
end

local rk = function(self, ...)
  return table.concat({self.model:rk(self.id), ...}, ":")
end

local getattr = function(self, attr)
  assert(type(attr) == "string")
  return self.model.R:hget(self:rk(), attr)
end

local setattr = function(self, attr, val)
  assert(type(attr) == "string")
  assert(
    (type(val) == "string") or
    (type(val) == "number")
  )
  self.model.R:hset(self:rk(), attr, val)
end

local check_attributes = function(self, t)
  for k,_ in pairs(self.model.attributes) do
    if self["get_" .. k](self) ~= t[k] then
      return false
    end
  end
  return true
end

local base_methods = function()
  return {
    rk = rk,
    getattr = getattr,
    setattr = setattr,
    check_attributes = check_attributes,
  }
end

local m_new = function(t)
  assert(
    (type(t.name) == "string") and
    (type(t.prefix) == "string") and
    t.redis
  )
  local r = {
    R = t.redis,
    prefix = t.prefix,
    name = t.name,
    attributes = {},
    indexed = {},
    methods = base_methods(),
    m_methods = base_m_methods(),
  }
  r = setmetatable(r, {__index=r.m_methods})
  return r
end

return {new = m_new}
