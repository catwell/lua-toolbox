local pathx = require "pl.path"
local dirx = require "pl.dir"
local DIR = assert(arg[1])
assert(pathx.isdir(DIR))

local Module = (require "model").Module

local fs = dirx.getfiles(DIR, "*.rockspec")
local rs, m
for i=1,#fs do
  rs = model.load_rockspec(fs[i])
  m = Module.get_by_name(assert(rs.name))
  if m then
    print("updated: " .. rs.name)
    m:update_with_rockspec(rs)
  else
    print("created: " .. rs.name)
    Module.create{rockspec = rs}
  end
end
