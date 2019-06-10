local value = redis.call("get", KEYS[1])
if tonumber(value) <= 0 then
  redis.call("set", KEYS[1], "0")
  return 0
end

return redis.call("decr", KEYS[1])