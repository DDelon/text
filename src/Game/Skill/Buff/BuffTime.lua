local BuffTime = class("BuffTime", require("Game/Skill/Buff/BuffBase"))

function BuffTime:init(targetPlayerId, propId, buffNum)
	print("buff num:"..buffNum.." propId:"..propId);
	self.type = 1;
	BuffTime.super.init(self, targetPlayerId, propId, buffNum);
	self.scheduleId = 0;
	self:setBuffStatus();
	self:openUpdate();
end

function BuffTime:executeBuff(skillManager)
	BuffTime.super.executeBuff(self, skillManager);
end

function BuffTime:openUpdate()
	local function updateInline(dt)
		self:update(dt);
	end
	if self.scheduleId == 0 then
		self.scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateInline, 1, false);
	end
end

function BuffTime:update(dt)
	self.num = self.num-1;
	if self.num < 0 then
		self:stopBuff();
	else
		self:setBuffStatus();
	end
end

function BuffTime:closeUpdate()
	if self.scheduleId ~= 0 and self.scheduleId ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = 0;
	end
end

function BuffTime:setBuffStatus()
	FishGI.gameScene.uiMainLayer:setPropBuff(self.targetPlayerId, self.propId, self.num, self.num.."s");

end

function BuffTime:pause()
	BuffTime.super.pause(self);

	self:closeUpdate();
end

function BuffTime:resume()
	BuffTime.super.resume(self);
	self:openUpdate();
end

function BuffTime:stopBuff()
	BuffTime.super.stopBuff(self);
	FishGI.gameScene.uiMainLayer:setPropBuff(self.targetPlayerId, self.propId, 0, "0s");
	self:closeUpdate();
end

function BuffTime:clearData()
	BuffTime.super.clearData(self);
	self.type = 0;
	self:closeUpdate();
end


return BuffTime;