{
if (typeof ALittle === "undefined") window.ALittle = {};


ALittle.LoopObject = JavaScript.Class(undefined, {
	get complete_callback() {
		return this._complete_callback;
	},
	set complete_callback(value) {
		this._complete_callback = value;
	},
	IsCompleted : function() {
		return true;
	},
	Completed : function() {
		if (this._complete_callback !== undefined) {
			this._complete_callback();
		}
	},
	Update : function(frame_time) {
		return frame_time;
	},
	Reset : function() {
	},
	SetTime : function(time) {
		return [time, true];
	},
	SetCompleted : function() {
	},
	Dispose : function(deep) {
		this.Stop();
	},
	Start : function() {
		A_JLoopSystem.AddUpdater(this);
	},
	Stop : function() {
		A_JLoopSystem.RemoveUpdater(this);
	},
}, "ALittle.LoopObject");

}