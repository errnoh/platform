Echo("Loading helpers")

runfile "bots/teams/errnoh/json.lua"

function printTableKeys(t)
  for key,value in next,getAllData(t),nil do Echo(key) end
end

function printTable(t)
  for key,value in next,getAllData(t),nil do Echo(key .. ": " .. value) end
end

function getAllData(t, prevData)
  -- if prevData == nil, start empty, otherwise start with prevData
  local data = prevData or {}

  -- copy all the attributes from t
  for k,v in pairs(t) do
    if not data[k] then data[k] = v end
  end

  -- get t's metatable, or exit if not existing
  local mt = getmetatable(t)
  if type(mt)~='table' then return data end

  -- get the __index from mt, or exit if not table
  local index = mt.__index
  if type(index)~='table' then return data end

  -- include the data from index into data, recursively, and return
  return getAllData(index, data)
end

Echo("Helpers loaded")