local lapis_validate = require "lapis.validate"
local validate_functions = lapis_validate.validate_functions

validate_functions.is_email = function(input)
  if input:match(".+@.+%..+") then
    return true
  else
    return false, "%s is not a valid email"
  end
end
