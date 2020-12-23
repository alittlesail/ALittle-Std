-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.Lua == nil then _G.Lua = {} end
local Lua = Lua
local ALittle = ALittle
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs


local __LUAMSG_MAXID = 0
assert(ALittle.IMsgCommonNative, " extends class:ALittle.IMsgCommonNative is nil")
Lua.LuaMsgInterface = Lua.Class(ALittle.IMsgCommonNative, "Lua.LuaMsgInterface")

function Lua.LuaMsgInterface:Ctor()
	__LUAMSG_MAXID = __LUAMSG_MAXID + 1
	___rawset(self, "_id", __LUAMSG_MAXID)
end

function Lua.LuaMsgInterface:GetID()
	return self._id
end

function Lua.LuaMsgInterface:Connect(ip, port)
	A_LuaSchedule._net:Connect(self._id, ip, port)
end

function Lua.LuaMsgInterface:Close()
	A_LuaSchedule._net:Close(self._id)
end

function Lua.LuaMsgInterface:IsConnected()
	return A_LuaSchedule._net:IsConnected(self._id)
end

function Lua.LuaMsgInterface:SendFactory(factory)
	A_LuaSchedule._net:Send(self._id, factory)
end

end