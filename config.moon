import config from require "lapis.config"

_appname = "badakhshan"
_session_name = _appname .. "_session"

config "development", ->
  appname _appname
  session_name _session_name
  port 8080
  num_workers 1
  secret "dev-secret"
  lua_code_cache "off"
  redis ->
    host "127.0.0.1"
    port 6379

config "production", ->
  appname _appname
  session_name _session_name
  port 80
  num_workers 4
  secret assert os.getenv "LAPIS_SECRET"
  lua_code_cache "on"
  redis ->
    host "127.0.0.1"
    port 6379
