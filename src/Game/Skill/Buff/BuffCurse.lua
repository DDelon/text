local BuffCurse = class("BuffCurse", require("Game/Skill/Buff/BuffSuperposition"))

function BuffCurse.create(targetPlayerId, propId, buffNum, isInit)
	local obj = BuffCurse.new();
	obj:init(targetPlayerId, propId, buffNum, isInit);
	return obj;
end

function BuffCurse:init(targetPlayerId, propId, buffNum, isInit)
	BuffCurse.super.init(self, targetPlayerId, propId, buffNum);
	if not isInit then
		FishGMF.addTrueAndFlyProp(targetPlayerId,10007,-buffNum,true,0,0)
	end
end

function BuffCurse:executeBuff(skillManager)
	--扣除一定的子弹数量
	self:setBuffStatus()
end

--刷新剩余数量
function BuffCurse:setBuffStatus()
	FishGI.gameScene.uiMainLayer:setPropBuff(self.targetPlayerId, self.propId, self.num, string.format( "-%d",self.num ));
end

function BuffCurse:stopBuff(bUpdate)
	FishGMF.addTrueAndFlyProp(self.targetPlayerId,10007,self.num,true,0,0)
	self.num = 0
	if bUpdate then 
		self:setBuffStatus()
	end 
	BuffCurse.super.stopBuff(self)
end

return BuffCurse;