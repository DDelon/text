local BuffWeak = class("BuffWeak", require("Game/Skill/Buff/BuffSuperposition"))

function BuffWeak.create(targetPlayerId, propId, buffNum)
	local obj = BuffWeak.new();
	obj:init(targetPlayerId, propId, buffNum);
	return obj;
end

function BuffWeak:init(targetPlayerId, propId, buffNum)
	BuffWeak.super.init(self, targetPlayerId, propId, buffNum);
end

function BuffWeak:executeBuff(skillManager)
	--获得的积分减半
	BuffWeak.super.executeBuff(self)
	self:setBuffStatus()
	
end

--刷新剩余数量
function BuffWeak:setBuffStatus()
	print("buff num:"..self.num)
	FishGI.gameScene.uiMainLayer:setPropBuff(self.targetPlayerId, self.propId, self.num, string.format( "x%d",self.num ));
end

function BuffWeak:stopBuff(bUpdate)
	self.num = 0
	if bUpdate then
		self:setBuffStatus()
	end
	BuffWeak.super.stopBuff(self)
end

return BuffWeak;