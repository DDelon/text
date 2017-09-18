local SkillBase = import("Game.Skill.NormalSkill.SkillBase")
local SkillViolnet = class("SkillViolnet",SkillBase)

function SkillViolnet:ctor(...)
    self.duration = tonumber(FishGI.GameConfig:getConfigData("skill","960000006","duration"))
    self:initListener()
    self:initBg()
    self:openTouchEventListener()
    self.isChose = false
    self.endTime = 0
end

--初始化监听器
function SkillViolnet:initListener()
    FishGI.eventDispatcher:registerCustomListener("UseViolentResult", self, function(valTab) self:useViolentResult(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("ViolentTimeOut", self, function(valTab) self:ViolentTimeOut(valTab) end);
end

--初始化精灵
function SkillViolnet:initBg()

end

function SkillViolnet:setPropId(propId)
    self.propId = propId
    
end

--按键按下的处理
function SkillViolnet:clickCallBack( )
    local useType = self:judgeUseType()
    if useType == nil then
        return
    end
    self:pushDataToPool(useType)
    self.useType = useType
    local data = {}
    data.useType = useType
    self:sendNetMessage(data)
    self.btn:setTouchEnabled(false)
    self:runTimer()
    self.endTime = os.time()+self.duration
end

function SkillViolnet:checkIsEnd()
    local curTime = os.time();
    if curTime >= self.endTime then
        local playerId = FishGI.gameScene.playerManager.selfIndex;
        local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(playerId)
        player:endEffectId();
        self.endTime = 0;
        self.btn.parentClasss:setState(1)
    end
end

function SkillViolnet:useViolentResult(data)

    local playerId = data.playerID;
    local useType = data.useType;
    local newCrystal = data.newCrystal;
    if data.isSuccess then
        self.playerSelf = FishGI.gameScene.playerManager:getMyData()
        local myPlayerId = self.playerSelf.playerInfo.playerId

        local isShow = nil
        if myPlayerId == playerId then
            isShow = false
            self.btn.parentClasss:setState(2)
        end

        if useType == 1 then
            --更新水晶
            FishGMF.upDataByPropId(playerId,FishCD.PROP_TAG_02,newCrystal,isShow)
        elseif useType == 0 then
            FishGMF.addTrueAndFlyProp(playerId,FishCD.PROP_TAG_05,-1,isShow)
        end

        local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(playerId)
        player:startEffectId(self.propId);
    end
end

function SkillViolnet:ViolentTimeOut(data)
    local playerId = data.playerId;
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(playerId)
    player:endEffectId();
    
    if playerId == FishGI.gameScene.playerManager.selfIndex then
        self.endTime = 0;
        self.btn.parentClasss:setState(1)
    end
    
end

--进入前台刷新时间
function SkillViolnet:upDateUserTime(disTime )
    self:upDateTimer()
end

return SkillViolnet;