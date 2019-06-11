local value = redis.call("get", KEYS[1])

if not value then
  return nil
elseif value == "0" then
  return 0
elseif tonumber(value) < 0 then
  redis.call("set", KEYS[1], 0)
  return 0
else
  return redis.call("decr", KEYS[1])
end
