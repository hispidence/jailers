-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2015
--
--
-- utils.lua
--
-- Misc utility functions
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- jSplit
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
-- letter, number or underscore as a delimiter.
-------------------------------------------------------------------------------
function jSplit(str)
  local vals = {}
  for s in str:gmatch("[%w_]+") do
    vals[#vals + 1] = s
  end
  return vals
end