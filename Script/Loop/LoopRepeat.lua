-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs


assert(ALittle.LoopObject, " extends class:ALittle.LoopObject is nil")
ALittle.LoopRepeat = Lua.Class(ALittle.LoopObject, "ALittle.LoopRepeat")

function ALittle.LoopRepeat:Ctor(object, count)
	___rawset(self, "_force_completed", false)
	___rawset(self, "_object", object)
	___rawset(self, "_total_count", count)
	___rawset(self, "_accumulate_count", 0)
	if self._object == nil then
		___rawset(self, "_accumulate_count", 0)
		___rawset(self, "_total_count", 0)
		ALittle.Log("LoopRepeat create failed:function is nil or not a function")
		return
	end
end

function ALittle.LoopRepeat:Reset()
	self._accumulate_count = 0
	if self._object ~= nil then
		self._object:Reset()
	end
	self._force_completed = false
end

function ALittle.LoopRepeat:IsCompleted()
	if self._force_completed then
		return true
	end
	if self._total_count < 0 then
		return false
	end
	return self._total_count <= self._accumulate_count
end

function ALittle.LoopRepeat:SetCompleted()
	if self._total_count < 0 then
		self._force_completed = true
		return
	end
	self._accumulate_count = self._total_count
end

function ALittle.LoopRepeat:SetTime(time)
	self._accumulate_count = 0
	if time <= 0 then
		return 0, false
	end
	if self._total_count < 0 then
		return 0, false
	end
	while self._accumulate_count < self._total_count and time > 0 do
		local remain_time, competed = self._object:SetTime(time)
		if competed then
			self._accumulate_count = self._accumulate_count + 1
		end
		time = remain_time
	end
	return time, self._accumulate_count >= self._total_count
end

function ALittle.LoopRepeat:Update(frame_time)
	while (self._total_count <= 0 or self._accumulate_count < self._total_count) and frame_time > 0 do
		if self._object:IsCompleted() then
			self._object:Reset()
		end
		frame_time = self._object:Update(frame_time)
		if self._object:IsCompleted() then
			self._accumulate_count = self._accumulate_count + 1
			self._object:Completed()
		end
	end
	return frame_time
end

end