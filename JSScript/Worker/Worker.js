{
if (typeof ALittle === "undefined") window.ALittle = {};

ALittle.RegStruct(-667760585, "ALittle.WorkerMessage", {
name : "ALittle.WorkerMessage", ns_name : "ALittle", rl_name : "WorkerMessage", hash_code : -667760585,
name_list : ["id","rpc_id","msg"],
type_list : ["int","int","any"],
option_map : {}
})

if (ALittle.IWorker === undefined) throw new Error(" extends class:ALittle.IWorker is undefined");
ALittle.Worker = JavaScript.Class(ALittle.IWorker, {
}, "ALittle.Worker");

ALittle.__ALITTLEAPI_WorkerMessage = function(json) {
}

ALittle.__ALITTLEAPI_WebWorkerMessage = function(event) {
}

onmessage = ALittle.__ALITTLEAPI_WebWorkerMessage;
ALittle.__ALITTLEAPI_WorkerUpdate = function(frame_time) {
	A_LuaLoopSystem.Update(frame_time);
	A_WeakLoopSystem.Update(frame_time);
}

}