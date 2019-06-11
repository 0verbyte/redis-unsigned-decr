local testAssert = function()
  local testIndex = 0

  return function(condition, message)
    testIndex = testIndex + 1
    assert(condition, 'TEST ' .. testIndex .. ' FAILED!! msg=' .. message)
  end
end

local test = testAssert()
local testKey = 'test'

-- Check nil is maintained for empty keys
local value = redis.call('unsigned.decr', testKey)
test(value == false, 'expected "' .. testKey .. '" key to be nil (false)!')

value = redis.call('incr', testKey)
test(value == 1, 'expected "' .. testKey .. '" key to be 1! got ' .. value)

value = redis.call('unsigned.decr', testKey)
test(value == 0, 'expected "' .. testKey .. '" key to be 0! got ' .. value)

-- Check keys are being clamped to unsigned when calling on key with 0 value
value = redis.call('unsigned.decr', testKey)
test(value == 0, 'expected "' .. testKey .. '" key to be 0! got ' .. value)

-- Check keys are being clamped to unsigned when explicitly set to signed int
redis.call('set', testKey, '-1')
value = redis.call('unsigned.decr', testKey)
test(value == 0, 'expected "' .. testKey .. '" key to be clamped to 0! got ' .. value)

local keyMax = 10
local keyMin = 1
redis.call('set', testKey, keyMax)
for i=keyMin, keyMax do
  local tmp = redis.call('unsigned.decr', testKey)
  test(tmp == (keyMax - i), 'expected "' .. testKey .. '" key to be ' .. (keyMax - i) .. '! got ' .. tmp)
end

value = redis.call('unsigned.decr', testKey)
test(value == 0, 'expected "' .. testKey .. '" key to be 0! got ' .. value)
