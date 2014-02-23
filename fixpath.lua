package.path = table.concat({
  package.path,
  "/usr/share/lua/5.1/?.lua",
  "/usr/share/lua/5.1/?/init.lua",
  "/usr/lib/lua/5.1/?.lua",
  "/usr/lib/lua/5.1/?/init.lua",
}, ";")

package.cpath = table.concat({
  package.cpath,
  "/usr/lib/lua/5.1/?.so",
}, ";")
