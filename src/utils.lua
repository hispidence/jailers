-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- utils.lua
--
-- Misc utility functions
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- jRound
--
-- Rounds a floating-point number to its nearest whole.
-------------------------------------------------------------------------------
function jRound(n)
	if n >= 0 then return math.floor(n + 0.5)
	else return math.ceil(n - 0.5) end
end



-------------------------------------------------------------------------------
-- jSplit
--
-- Splits the string into a table of values, using anything other than a
-- letter, number, underscore, or hyphen as a delimiter.
-------------------------------------------------------------------------------
function jSplit(str)
  local vals = {}
  for s in str:gmatch("[%w_-]+") do
    vals[#vals + 1] = s
  end
  return vals
end



-------------------------------------------------------------------------------
-- jSplitKV
--
-- Splits the string into a table of values, using anything other than a
-- letter, number, underscore, or hyphen as a delimiter. Additionally, this
-- function returns a key-value table. 
-------------------------------------------------------------------------------
function jSplitKV(str)
  local vals = jSplit(str)
  local kvVals = {}
  for i = 1, #vals, 2 do
    if nil == vals[i+1] then
      print("Warning! jSplitKV mismatch; no value found for string \"" ..
        vals[i] .. "\".")
    end
    kvVals[vals[i]] = vals[i+1]
  end
  return kvVals
end

