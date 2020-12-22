-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.Lua == nil then _G.Lua = {} end
local ___pairs = pairs
local ___ipairs = ipairs
local Lua = Lua
local ALittle = ALittle


Lua.CarpNetEventType = {
	HTTP_SUCCEED = 1,
	HTTP_FAILED = 2,
	HTTP_FILE_SUCCEED = 11,
	HTTP_FILE_FAILED = 12,
	HTTP_FILE_PROGRESS = 13,
	TIMER = 21,
	MSG_CONNECT_SUCCEED = 31,
	MSG_CONNECT_FAILED = 32,
	MSG_DISCONNECTED = 33,
	MSG_MESSAGE = 34,
}

assert(ALittle.ISchedule, " extends class:ALittle.ISchedule is nil")
Lua.LuaSchedule = Lua.Class(ALittle.ISchedule, "Lua.LuaSchedule")

function Lua.LuaSchedule:Ctor()
end

function Lua.LuaSchedule:RunInFrame()
	if self._net == nil then
		self._net = carp.CarpNet()
	end
	while true do
		local event = carp.CarpNet.Poll(self._net)
		if event == nil then
			break
		end
		self:HandleEvent(event)
	end
end

function Lua.LuaSchedule:Run()
	if self._net == nil then
		self._net = carp.CarpNet()
	end
	self._net:Timer(16)
	while true do
		local event = carp.CarpNet.Poll(self._net)
		if event == nil then
			break
		end
		if event.type == Lua.CarpNetEventType.TIMER then
			if self._last_time ~= nil then
				A_LuaLoopSystem:Update(event.time - self._last_time)
				A_LuaWeakLoopSystem:Update(event.time - self._last_time)
			end
			self._last_time = event.time
			self._net:Timer(16)
		else
			self:HandleEvent(event)
		end
	end
end

function Lua.LuaSchedule:HandleEvent(event)
	if event.type == Lua.CarpNetEventType.MSG_MESSAGE then
		ALittle.__ALITTLEAPI_Message(event.id, event.msg_id, event.rpc_id, self._factory)
		carp.CarpNet.FreeReadFactory(event.factory)
	elseif event.type == Lua.CarpNetEventType.HTTP_SUCCEED then
		ALittle.__ALITTLEAPI_HttpClientSucceed(event.id)
	elseif event.type == Lua.CarpNetEventType.HTTP_FAILED then
		ALittle.__ALITTLEAPI_HttpClientFailed(event.id, event.error)
	elseif event.type == Lua.CarpNetEventType.HTTP_FILE_SUCCEED then
		ALittle.__ALITTLEAPI_HttpFileSucceed(event.id)
	elseif event.type == Lua.CarpNetEventType.HTTP_FILE_FAILED then
		ALittle.__ALITTLEAPI_HttpFileFailed(event.id, event.error)
	elseif event.type == Lua.CarpNetEventType.HTTP_FILE_PROGRESS then
		ALittle.__ALITTLEAPI_HttpFileProcess(event.id, event.cur_size, event.total_size)
	elseif event.type == Lua.CarpNetEventType.MSG_CONNECT_SUCCEED then
		ALittle.__ALITTLEAPI_ConnectSucceed(event.id)
	elseif event.type == Lua.CarpNetEventType.MSG_CONNECT_FAILED then
		ALittle.__ALITTLEAPI_ConnectFailed(event.id)
	elseif event.type == Lua.CarpNetEventType.MSG_DISCONNECTED then
		ALittle.__ALITTLEAPI_Disconnected(event.id)
	end
end

_G.A_LuaSchedule = Lua.LuaSchedule()
end