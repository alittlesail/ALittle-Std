{
if (typeof ALittle === "undefined") window.ALittle = {};


if (ALittle.LoopObject === undefined) throw new Error(" extends class:ALittle.LoopObject is undefined");
ALittle.LoopRepeat = JavaScript.Class(ALittle.LoopObject, {
	Ctor : function(object, count) {
		this._force_completed = false;
		this._object = object;
		this._total_count = count;
		this._accumulate_count = 0;
		if (this._object === undefined) {
			this._accumulate_count = 0;
			this._total_count = 0;
			ALittle.Log("LoopRepeat create failed:function is nil or not a function");
			return;
		}
	},
	Reset : function() {
		this._accumulate_count = 0;
		if (this._object !== undefined) {
			this._object.Reset();
		}
		this._force_completed = false;
	},
	IsCompleted : function() {
		if (this._force_completed) {
			return true;
		}
		if (this._total_count < 0) {
			return false;
		}
		return this._total_count <= this._accumulate_count;
	},
	SetCompleted : function() {
		if (this._total_count < 0) {
			this._force_completed = true;
			return;
		}
		this._accumulate_count = this._total_count;
	},
	SetTime : function(time) {
		this._accumulate_count = 0;
		if (time <= 0) {
			return [0, false];
		}
		if (this._total_count < 0) {
			return [0, false];
		}
		while (this._accumulate_count < this._total_count && time > 0) {
			let [remain_time, competed] = this._object.SetTime(time);
			if (competed) {
				++ this._accumulate_count;
			}
			time = remain_time;
		}
		return [time, this._accumulate_count >= this._total_count];
	},
	Update : function(frame_time) {
		while ((this._total_count <= 0 || this._accumulate_count < this._total_count) && frame_time > 0) {
			if (this._object.IsCompleted()) {
				this._object.Reset();
			}
			frame_time = this._object.Update(frame_time);
			if (this._object.IsCompleted()) {
				++ this._accumulate_count;
				this._object.Completed();
			}
		}
		return frame_time;
	},
}, "ALittle.LoopRepeat");

}