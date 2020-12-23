-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.Lua == nil then _G.Lua = {} end
local Lua = Lua
local ALittle = ALittle
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs


local __LUAHTTP_MAXID = 0
assert(ALittle.IHttpSenderNative, " extends class:ALittle.IHttpSenderNative is nil")
Lua.LuaHttpInterface = Lua.Class(ALittle.IHttpSenderNative, "Lua.LuaHttpInterface")

function Lua.LuaHttpInterface:Ctor()
	__LUAHTTP_MAXID = __LUAHTTP_MAXID + 1
	___rawset(self, "_id", __LUAHTTP_MAXID)
end

function Lua.LuaHttpInterface:GetID()
	return self._id
end

function Lua.LuaHttpInterface:SetURL(url, content)
	self._url = url
	self._content = content
end

function Lua.LuaHttpInterface:Start()
	if self._content == nil then
		A_LuaSchedule._net:HttpGet(self._id, self._url)
	else
		A_LuaSchedule._net:HttpPost(self._id, self._url, "application/json", self._content)
	end
end

function Lua.LuaHttpInterface:Stop()
	if self._content == nil then
		A_LuaSchedule._net:HttpStopGet(self._id)
	else
		A_LuaSchedule._net:HttpStopPost(self._id)
	end
end

function Lua.LuaHttpInterface:GetResponse()
	return self._response
end

end