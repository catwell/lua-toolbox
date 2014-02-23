require "fixpath"
local lapis = require "lapis.init"
require "extensions"

local model = require "model"
model.init()

local app = require "app"
lapis.serve(app)
