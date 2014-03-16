local pathx = require "pl.path"
local dirx = require "pl.dir"
local DIR = assert(arg[1])
local fast = (arg[2] ~= "full")
assert(pathx.isdir(DIR))

local model = require "model"
local Module = model.Module

local fs = dirx.getfiles(DIR, "*.rockspec")
local rs, m
for i=1,#fs do
  rs = model.load_rockspec(fs[i])
  if rs then
    m = Module:get_by_name(assert(rs.name))
    if m then
      if m:update_with_rockspec(rs, fast) then
        print("updated: " .. rs.name)
      else
        print("unchanged: " .. rs.name)
      end
    else
      Module:create{rockspec = rs}
      print("created: " .. rs.name)
    end
  end
end
