local SkillBase = import("Game.Skill.NormalSkill.SkillBase")
local SkillFreeze = class("SkillFreeze",SkillBase)

function SkillFreeze:ctor(...)
    self:initListener()
    self:initBg()

end

--初始化监听器
function SkillFreeze:initListener()
    FishGI.eventDispatcher:registerCustomListener("startMyFreeze", self, function(valTab) self:startMyFreeze(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("endFreeze", self, function(valTab) self:endFreeze(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("otherFreezeStart", self, function(valTab) self:otherFreezeStart(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("gameStartFreeze", self, function(valTab) self:gameStartFreeze(valTab) end);
end

--冰冻背景
function SkillFreeze:initBg()
    self.freezeBg = cc.Sprite:create("battle/effect/effect_fullfz.png")
    self:addChild(self.freezeBg)
    self.freezeBg:setOpacity(0)
    self.freezeBg:setVisible(false)
end

--按键按下的处理
function SkillFreeze:clickCallBack( )
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
end

--开始自己的冰冻
function SkillFreeze:startMyFreeze( valTab)
    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    local myPlayerId = self.playerSelf.playerInfo.playerId
    local useType = valTab.useType
    local newCrystal = valTab.newCrystal
    local isSuccess = valTab.isSuccess

    if isSuccess == false then
        self:clearDataFromPool(useType)
        self:stopTimer()
        --FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000087),nil)
        return
    end
    self.startTime = os.time()

    if useType == 1 then
        --更新水晶
        FishGMF.upDataByPropId(myPlayerId,FishCD.PROP_TAG_02,newCrystal,false)
    elseif useType == 0 then
        FishGMF.addTrueAndFlyProp(myPlayerId,FishCD.PROP_TAG_03,-1,false)
    end

    self:clearDataFromPool(useType)

    self:freezeEffect()

    FishGMF.setFishState(4)
    
end

--进入前台刷新时间
function SkillFreeze:upDateUserTime(disTime )
    self:upDateTimer()
end

--开始其他人的冰冻
function SkillFreeze:otherFreezeStart( valTab)
    local playerId = valTab.playerId
    local newCrystal = valTab.newCrystal
    
    self:freezeEffect()
    FishGMF.setFishState(4)

    --更新水晶
    FishGMF.upDataByPropId(playerId,FishCD.PROP_TAG_02,newCrystal)
end

--游戏开始时的冰冻
function SkillFreeze:gameStartFreeze( valTab)
    FishGI.AudioControl:playEffect("sound/fishfreeze_01.mp3",false)
    local playerId = valTab.playerId

    local size = self.freezeBg:getContentSize()
    local sizeWin = cc.Director:getInstance():getWinSize()   
    local curPosInNode = self:convertToNodeSpace(cc.p(sizeWin.width/2,sizeWin.height/2))
    self.freezeBg:setPosition(cc.p(curPosInNode.x,curPosInNode.y))
    self.freezeBg:setScaleX(sizeWin.width/size.width)
    self.freezeBg:setScaleY(sizeWin.height/size.height)

    self.freezeBg:stopAllActions()
    self.freezeBg:setVisible(true)
    self.freezeBg:setOpacity(255)

    FishGMF.setFishState(5)

end

--冰冻特效
function SkillFreeze:freezeEffect( )
    FishGI.AudioControl:playEffect("sound/fishfreeze_01.mp3",false)
    local size = self.freezeBg:getContentSize()
    local sizeWin = cc.Director:getInstance():getWinSize()   
    local curPosInNode = self:convertToNodeSpace(cc.p(sizeWin.width/2,sizeWin.height/2))
    self.freezeBg:setPosition(cc.p(curPosInNode.x,curPosInNode.y))
    self.freezeBg:setScaleX(sizeWin.width/size.width)
    self.freezeBg:setScaleY(sizeWin.height/size.height)

    self.freezeBg:stopAllActions()
    self.freezeBg:setVisible(true)
    self.freezeBg:setOpacity(0)
    self.freezeBg:runAction(cc.FadeTo:create(0.8,255))
end

--结束冰冻
function SkillFreeze:endFreeze( valTab )
    self.freezeBg:runAction(cc.FadeTo:create(0.3,0))
    FishGMF.setFishState(1)
end

return SkillFreeze;