{
if (typeof ALittle === "undefined") window.ALittle = {};

ALittle.RegStruct(-1631648859, "ALittle.WorkerRPCInfo", {
name : "ALittle.WorkerRPCInfo", ns_name : "ALittle", rl_name : "WorkerRPCInfo", hash_code : -1631648859,
name_list : ["thread","rpc_id"],
type_list : ["ALittle.Thread","int"],
option_map : {}
})
ALittle.RegStruct(-930447138, "ALittle.Thread", {
name : "ALittle.Thread", ns_name : "ALittle", rl_name : "Thread", hash_code : -930447138,
name_list : [],
type_list : [],
option_map : {}
})

if (ALittle.IWorker === undefined) throw new Error(" extends class:ALittle.IWorker is undefined");
ALittle.IWorkerCommon = JavaScript.Class(ALittle.IWorker, {
	Ctor : function() {
		this._id_map_rpc = new Map();
		this._id_creator = ALittle.NewObject(ALittle.SafeIDCreator);
	},
	ClearRPC : function(reason) {
		let tmp = new Map();
		for (let [rpc_id, info] of this._id_map_rpc) {
			if (info === undefined) continue;
			this._id_creator.ReleaseID(rpc_id);
			tmp.set(rpc_id, info);
		}
		this._id_map_rpc = new Map();
		for (let [rpc_id, info] of tmp) {
			if (info === undefined) continue;
			let [result, error] = ALittle.Coroutine.Resume(info.thread, reason, undefined);
			if (result !== true) {
				ALittle.Error(error);
			}
		}
	},
	HandleMessage : function(worker_msg) {
		let id = worker_msg.id;
		let rpc_id = worker_msg.rpc_id;
		if (id === 0) {
			return;
		}
		if (rpc_id === 0) {
			let callback = ALittle.FindWorkerCallback(id);
			if (callback === undefined) {
				let name = "unknow";
				let rflt = ALittle.FindStructById(id);
				if (rflt !== undefined) {
					name = rflt.name;
				}
				ALittle.Log("WorkerCommon can't find callback by id:" + id + ", name:" + name);
				return;
			}
			let msg = worker_msg.msg;
			if (msg === undefined) {
				let name = "unknow";
				let rflt = ALittle.FindStructById(id);
				if (rflt !== undefined) {
					name = rflt.name;
				}
				ALittle.Log("WorkerCommon MessageRead failed by id:" + id + ", name:" + name);
				return;
			}
			callback(this, msg);
			return;
		}
		if (rpc_id > 0) {
			this.HandleRPCRequest(id, rpc_id, worker_msg.msg);
			return;
		}
		rpc_id = -rpc_id;
		this._id_creator.ReleaseID(rpc_id);
		let info = this._id_map_rpc.get(rpc_id);
		if (info === undefined) {
			ALittle.Log("WorkerCommon can't find rpc info by id:" + id);
			return;
		}
		this._id_map_rpc.delete(rpc_id);
		if (id === 1) {
			let [result, reason] = ALittle.Coroutine.Resume(info.thread, worker_msg.reason, undefined);
			if (result !== true) {
				ALittle.Error(reason);
			}
			return;
		}
		let [result, reason] = ALittle.Coroutine.Resume(info.thread, undefined, worker_msg.msg);
		if (result !== true) {
			ALittle.Error(reason);
		}
	},
	SendRpcError : function(rpc_id, reason) {
		let msg = {};
		msg.id = 1;
		msg.reason = reason;
		msg.rpc_id = -rpc_id;
		this.Send(msg);
	},
	SendRPC : function(thread, msg_id, msg_body) {
		let rpc_id = this._id_creator.CreateID();
		let worker_msg = {};
		worker_msg.id = msg_id;
		worker_msg.msg = msg_body;
		worker_msg.rpc_id = rpc_id;
		this.Send(worker_msg);
		let info = {};
		info.thread = thread;
		info.rpc_id = rpc_id;
		this._id_map_rpc.set(rpc_id, info);
	},
	HandleRPCRequest : async function(id, rpc_id, msg) {
		let [callback, return_id] = ALittle.FindWorkerRpcCallback(id);
		if (callback === undefined) {
			this.SendRpcError(rpc_id, "没有注册消息RPC回调函数");
			ALittle.Log("WorkerCommon.HandleMessage can't find callback by id:" + id);
			return;
		}
		let [error, return_body] = await (async function() { try { let ___VALUE = await callback.call(this, msg); return [undefined, ___VALUE]; } catch (___ERROR) { return [___ERROR.message]; } }).call(this);
		if (error !== undefined) {
			this.SendRpcError(rpc_id, error);
			ALittle.Log("WorkerCommon.HandleMessage callback invoke failed! by id:" + id + ", reason:" + error);
			return;
		}
		if (return_body === undefined) {
			this.SendRpcError(rpc_id, "WorkerCommon.HandleMessage callback have not return! by id:" + id);
			ALittle.Log("WorkerCommon.HandleMessage callback have not return! by id:" + id);
			return;
		}
		let worker_msg = {};
		worker_msg.id = return_id;
		worker_msg.msg = return_body;
		worker_msg.rpc_id = -rpc_id;
		this.Send(worker_msg);
	},
}, "ALittle.IWorkerCommon");

if (ALittle.IWorkerCommon === undefined) throw new Error(" extends class:ALittle.IWorkerCommon is undefined");
ALittle.Worker = JavaScript.Class(ALittle.IWorkerCommon, {
	Ctor : function(path) {
		this._stop = false;
		if (window.wx !== undefined) {
			this._wx_worker = window.wx.createWorker(path + ".js");
			this._wx_worker.onMessage(this.HandleWxMessage.bind(this));
		} else {
			this._web_worker = new Worker(path + ".js");
			this._web_worker.onmessage = this.HandleWebMessage.bind(this);
		}
	},
	IsStopped : function() {
		return this._stop;
	},
	Stop : function(reason) {
		if (this._stop) {
			return;
		}
		this._stop = true;
		if (reason === undefined) {
			reason = "主动关闭Worker";
		}
		this.ClearRPC(reason);
		if (this._wx_worker !== undefined) {
			this._wx_worker.terminate();
			this._wx_worker = undefined;
		} else {
			this._web_worker.terminate();
			this._web_worker = undefined;
		}
	},
	Send : function(msg) {
		if (this._wx_worker !== undefined) {
			this._wx_worker.postMessage(msg);
		} else {
			this._web_worker.postMessage(msg);
		}
	},
	HandleWxMessage : function(event) {
		this.HandleMessage(event.data);
	},
	HandleWebMessage : function(event) {
		this.HandleMessage(event.data);
	},
	HandleLuaMessage : function(frame_time) {
		while (true) {
			let content = this._lua_worker.Pull();
			if (content === undefined) {
				return;
			}
			let [result, object] = lua.pcall(lua.ajson.decode, content);
			if (result) {
				this.HandleMessage(object);
			}
		}
	},
}, "ALittle.Worker");

if (ALittle.IWorkerCommon === undefined) throw new Error(" extends class:ALittle.IWorkerCommon is undefined");
ALittle.WorkerInst = JavaScript.Class(ALittle.IWorkerCommon, {
	Send : function(msg) {
		if (window.wx !== undefined) {
			worker.postMessage(msg);
			return;
		}
		postMessage(msg);
	},
}, "ALittle.WorkerInst");

let A_WorkerInst = undefined;
let __WebWorkerMessage = function(event) {
	A_WorkerInst.HandleMessage(event.data);
}

let __WxWorkerMessage = function(event) {
	A_WorkerInst.HandleMessage(event.data);
}

ALittle.__ALITTLEAPI_WorkerMessage = function(json) {
	let [result, object] = lua.pcall(lua.ajson.decode, json);
	if (!result) {
		ALittle.Error("__ALITTLEAPI_WorkerMessage ajson decode failed");
		return;
	}
	A_WorkerInst.HandleMessage(object);
}

ALittle.__ALITTLEAPI_WorkerUpdate = function(frame_time) {
	A_LoopSystem.Update(frame_time);
	A_WeakLoopSystem.Update(frame_time);
}

let __WorkerInit = function() {
	if (window.wx !== undefined && worker !== undefined) {
		worker.onMessage(__WxWorkerMessage);
	}
	if (postMessage !== undefined) {
		onmessage = __WebWorkerMessage;
	}
	return true;
}

let __worker_init = __WorkerInit();
}