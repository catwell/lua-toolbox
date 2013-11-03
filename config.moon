import config from require "lapis.config"

_appname = "luatoolbox"
_session_name = _appname .. "_session"

config "development", ->
  appname _appname
  session_name _session_name
  port 8080
  num_workers 1
  secret "dev-secret"
  lua_code_cache "off"
  redis {"127.0.0.1", 6379}

config "production", ->
  appname _appname
  session_name _session_name
  port 80
  num_workers 4
  secret assert os.getenv "LAPIS_SECRET"
  lua_code_cache "on"
  redis {"127.0.0.1", 6379}
  smtp {
    server: os.getenv "SMTP_SERVER",
    user: os.getenv "SMTP_USER",
    password: os.getenv "SMTP_PASSWORD",
  }
