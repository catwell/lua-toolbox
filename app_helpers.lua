local fmt = string.format
local super_respond_to = (require "lapis.application").respond_to

local respond_to = function(t)
  local verbs = {"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"}
  for _, v in ipairs(verbs) do
    if not t[v] then
      t[v] = function(self)
        self.res.status = 501
        return fmt("%s NOT SUPPORTED", v)
      end
    end
  end
  return super_respond_to(t)
end

return {
    respond_to = respond_to,
}
