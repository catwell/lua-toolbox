local rand_id = function(n)
  local r = {}
  for i=1,n do r[i] = string.char(math.random(65,90)) end
  return table.concat(r)
end

return {
    rand_id = rand_id,
}
