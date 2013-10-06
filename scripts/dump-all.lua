local model = require "model"
local pretty = require "pl.pretty"

pretty.dump {
  modules = model.Module:export(),
  users = model.User:export(),
  labels = model.Label:export(),
}
