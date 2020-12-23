-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.Lua == nil then _G.Lua = {} end
local Lua = Lua
local ALittle = ALittle
local ___pairs = pairs
local ___ipairs = ipairs


assert(ALittle.ICsvFile, " extends class:ALittle.ICsvFile is nil")
Lua.LuaCsvFile = Lua.Class(ALittle.ICsvFile, "Lua.LuaCsvFile")

function Lua.LuaCsvFile:Load(path)
	self._path = path
	self._csv = carp.CarpCsv()
	local error = self._csv:Load(path)
	if error ~= nil then
		ALittle.Error(error)
	end
	return error == nil
end

function Lua.LuaCsvFile:Close()
	if self._csv ~= nil then
		self._csv:Close()
		self._csv = nil
	end
end

function Lua.LuaCsvFile:ReadCell(row, col)
	if self._csv == nil then
		return nil
	end
	return self._csv:ReadCell(row, col)
end

function Lua.LuaCsvFile:GetRowCount()
	if self._csv == nil then
		return 0
	end
	return self._csv:GetRowCount()
end

function Lua.LuaCsvFile:GetColCount()
	if self._csv == nil then
		return 0
	end
	return self._csv:GetColCount()
end

end