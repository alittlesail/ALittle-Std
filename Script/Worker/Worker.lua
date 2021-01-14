-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs

ALittle.RegStruct(-1631648859, "ALittle.WorkerRPCInfo", {
name = "ALittle.WorkerRPCInfo", ns_name = "ALittle", rl_name = "WorkerRPCInfo", hash_code = -1631648859,
name_list = {"thread","rpc_id"},
type_list = {"ALittle.Thread","int"},
option_map = {}
})
ALittle.RegStruct(-930447138, "ALittle.Thread", {
name = "ALittle.Thread", ns_name = "ALittle", rl_name = "Thread", hash_code = -930447138,
name_list = {},
type_list = {},
option_map = {}
})

assert(ALittle.IWorker, " extends class:ALittle.IWorker is nil")
ALittle.IWorkerCommon = Lua.Class(ALittle.IWorker, "ALittle.IWorkerCommon")

function ALittle.IWorkerCommon:Ctor()
	___rawset(self, "_id_map_rpc", {})
	___rawset(self, "_id_creator", ALittle.SafeIDCreator())
end

function ALittle.IWorkerCommon:ClearRPC(reason)
	local tmp = {}
	for rpc_id, info in ___pairs(self._id_map_rpc) do
		self._id_creator:ReleaseID(rpc_id)
		tmp[rpc_id] = info
	end
	self._id_map_rpc = {}
	for rpc_id, info in ___pairs(tmp) do
		local result, error = ALittle.Coroutine.Resume(info.thread, reason, nil)
		if result ~= true then
			ALittle.Error(error)
		end
	end
end

function ALittle.IWorkerCommon:HandleMessage(worker_msg)
	local id = worker_msg.id
	local rpc_id = worker_msg.rpc_id
	if id == 0 then
		return
	end
	if rpc_id == 0 then
		local callback = ALittle.FindWorkerCallback(id)
		if callback == nil then
			local name = "unknow"
			local rflt = ALittle.FindStructById(id)
			if rflt ~= nil then
				name = rflt.name
			end
			ALittle.Log("WorkerCommon can't find callback by id:" .. id .. ", name:" .. name)
			return
		end
		local msg = worker_msg.msg
		if msg == nil then
			local name = "unknow"
			local rflt = ALittle.FindStructById(id)
			if rflt ~= nil then
				name = rflt.name
			end
			ALittle.Log("WorkerCommon MessageRead failed by id:" .. id .. ", name:" .. name)
			return
		end
		callback(self, msg)
		return
	end
	if rpc_id > 0 then
		self:HandleRPCRequest(id, rpc_id, worker_msg.msg)
		return
	end
	rpc_id = -rpc_id
	self._id_creator:ReleaseID(rpc_id)
	local info = self._id_map_rpc[rpc_id]
	if info == nil then
		ALittle.Log("WorkerCommon can't find rpc info by id:" .. id)
		return
	end
	self._id_map_rpc[rpc_id] = nil
	if id == 1 then
		local result, reason = ALittle.Coroutine.Resume(info.thread, worker_msg.reason, nil)
		if result ~= true then
			ALittle.Error(reason)
		end
		return
	end
	local result, reason = ALittle.Coroutine.Resume(info.thread, nil, worker_msg.msg)
	if result ~= true then
		ALittle.Error(reason)
	end
end

function ALittle.IWorkerCommon:SendRpcError(rpc_id, reason)
	local msg = {}
	msg.id = 1
	msg.reason = reason
	msg.rpc_id = -rpc_id
	self:Send(msg)
end

function ALittle.IWorkerCommon:SendRPC(thread, msg_id, msg_body)
	local rpc_id = self._id_creator:CreateID()
	local worker_msg = {}
	worker_msg.id = msg_id
	worker_msg.msg = msg_body
	worker_msg.rpc_id = rpc_id
	self:Send(worker_msg)
	local info = {}
	info.thread = thread
	info.rpc_id = rpc_id
	self._id_map_rpc[rpc_id] = info
end

function ALittle.IWorkerCommon:HandleRPCRequest(id, rpc_id, msg)
	local callback, return_id = ALittle.FindWorkerRpcCallback(id)
	if callback == nil then
		self:SendRpcError(rpc_id, "没有注册消息RPC回调函数")
		ALittle.Log("WorkerCommon.HandleMessage can't find callback by id:" .. id)
		return
	end
	local error, return_body = Lua.TCall(callback, self, msg)
	if error ~= nil then
		self:SendRpcError(rpc_id, error)
		ALittle.Log("WorkerCommon.HandleMessage callback invoke failed! by id:" .. id .. ", reason:" .. error)
		return
	end
	if return_body == nil then
		self:SendRpcError(rpc_id, "WorkerCommon.HandleMessage callback have not return! by id:" .. id)
		ALittle.Log("WorkerCommon.HandleMessage callback have not return! by id:" .. id)
		return
	end
	local worker_msg = {}
	worker_msg.id = return_id
	worker_msg.msg = return_body
	worker_msg.rpc_id = -rpc_id
	self:Send(worker_msg)
end
ALittle.IWorkerCommon.HandleRPCRequest = Lua.CoWrap(ALittle.IWorkerCommon.HandleRPCRequest)

assert(ALittle.IWorkerCommon, " extends class:ALittle.IWorkerCommon is nil")
ALittle.Worker = Lua.Class(ALittle.IWorkerCommon, "ALittle.Worker")

function ALittle.Worker:Ctor(path)
	___rawset(self, "_stop", false)
	___rawset(self, "_lua_worker", carp.CarpLuaWorker(A_CoreBasePath, A_StdBasePath, path))
	___rawset(self, "_loop_frame", ALittle.LoopFrame(Lua.Bind(self.HandleLuaMessage, self)))
	A_WeakLoopSystem:AddUpdater(self._loop_frame)
end

function ALittle.Worker:IsStopped()
	return self._stop
end

function ALittle.Worker:Stop(reason)
	if self._stop then
		return
	end
	self._stop = true
	if reason == nil then
		reason = "主动关闭Worker"
	end
	self:ClearRPC(reason)
	if self._lua_worker ~= nil then
		self._lua_worker:Stop()
		self._lua_worker = nil
		A_WeakLoopSystem:RemoveUpdater(self._loop_frame)
		self._loop_frame = nil
	end
end

function ALittle.Worker:Send(msg)
	self._lua_worker:Post(ajson.encode(msg))
end

function ALittle.Worker:HandleWxMessage(event)
	self:HandleMessage(event.data)
end

function ALittle.Worker:HandleWebMessage(event)
	self:HandleMessage(event.data)
end

function ALittle.Worker:HandleLuaMessage(frame_time)
	while true do
		local content = self._lua_worker:Pull()
		if content == nil then
			return
		end
		local result, object = pcall(ajson.decode, content)
		if result then
			self:HandleMessage(object)
		end
	end
end

assert(ALittle.IWorkerCommon, " extends class:ALittle.IWorkerCommon is nil")
ALittle.WorkerInst = Lua.Class(ALittle.IWorkerCommon, "ALittle.WorkerInst")

function ALittle.WorkerInst:Send(msg)
	carp_CarpLuaWorker:Post(ajson.encode(msg))
end

local A_WorkerInst = nil
function ALittle.__ALITTLEAPI_WorkerMessage(json)
	local result, object = pcall(ajson.decode, json)
	if not result then
		ALittle.Error("__ALITTLEAPI_WorkerMessage ajson decode failed")
		return
	end
	A_WorkerInst:HandleMessage(object)
end

function ALittle.__ALITTLEAPI_WorkerUpdate(frame_time)
	A_LoopSystem:Update(frame_time)
	A_WeakLoopSystem:Update(frame_time)
end

local __WorkerInit
__WorkerInit = function()
	_G["__ALITTLEAPI_WorkerMessage"] = ALittle.__ALITTLEAPI_WorkerMessage
	_G["__ALITTLEAPI_WorkerUpdate"] = ALittle.__ALITTLEAPI_WorkerUpdate
	A_WorkerInst = ALittle.WorkerInst()
	return true
end

local __worker_init = __WorkerInit()
end