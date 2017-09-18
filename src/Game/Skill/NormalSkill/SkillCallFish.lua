local SkillBase = import("Game.Skill.NormalSkill.SkillBase")
local SkillCallFish = class("SkillCallFish",SkillBase)

function SkillCallFish:ctor(...)
    self:initListener()
end

--初始化监听器
function SkillCallFish:initListener()
    FishGI.eventDispatcher:registerCustomListener("startCallFish", self, function(valTab) self:startCallFish(valTab) end);
end

--按键按下的处理
function SkillCallFish:clickCallBack( )
    local useType = self:judgeUseType()
    if useType == nil then
        return
    end
    self:pushDataToPool(useType)
    self.useType = useType
    local data = {}
    data.useType = useType
    self:sendNetMessage(data)
    self:runTimer()
    self.btn:setTouchEnabled(false)
end

--收到召唤消息
function SkillCallFish:startCallFish(valTab)
    local isSuccess = valTab.isSuccess
    local playerId = valTab.playerId
    local useType = valTab.useType
    local failType = valTab.failType
    local newCrystal = valTab.newCrystal
    local callFishId = valTab.callFishId
    local pathId = valTab.pathId
    local fishId = valTab.fishId
    local frameId = valTab.frameId;

    if isSuccess == false then
        self:clearDataFromPool(self.useType)
        print("-----startlamp--isSuccess == false-failType="..failType)
        self:stopTimer()
        
        if failType == 1 then
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000087),nil)
        elseif failType == 2 then
            FishGF.showSystemTip(FishGF.getChByIndex(800000109));
        end
        return
    end
    
    FishGI.AudioControl:playEffect("sound/com_btn03.mp3")
    self.playerSelf = FishGI.gameScene.playerManager:getMyData()
    local myPlayerId = self.playerSelf.playerInfo.playerId

    local isShow = nil
    if myPlayerId == playerId then
        isShow = false
    end

    if useType == 1 then
        --更新水晶
        FishGMF.upDataByPropId(playerId,FishCD.PROP_TAG_02,newCrystal,isShow)
    elseif useType == 0 then
        FishGMF.addTrueAndFlyProp(playerId,FishCD.PROP_TAG_05,-1,isShow)
    end

    if myPlayerId == playerId then
        self:clearDataFromPool(useType)
    end

    --开始召唤
    --function GameEffect:throwLamp(beginPos, endPos, moveVal, rotateVal, fadeInTime, fadeOutTime, cloudTime, callFunc)
    local frame = 1.15/FishCD.FRAME_TIME_INTERVAL;
    local function callFish()
        local data = {};
        data["frameId"] = frameId;
        data["fishTypeId"] = fishId;
        data["pathId"] = pathId;
        data["playerId"] = playerId;
        data["callFishId"] = callFishId;
        LuaCppAdapter:getInstance():callFish(data);
    end
    print("call success");
    local chairId = FishGI.gameScene.playerManager:getPlayerChairId(playerId);
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale();
    local beginPos = cc.p(FishCD.posTab[chairId].x*scaleX_, FishCD.posTab[chairId].y*scaleY_);
    local endPos = LuaCppAdapter:getInstance():getPathPos(pathId, frame);
    self:throwLamp(beginPos, endPos, callFish);

end

--开始位置 结束位置
function SkillCallFish:throwLamp(beginPos, endPos, callFunc)
    local totalTimes = 0;
    endPos = cc.p(endPos.x, endPos.y+10);
    local effectLayer = cc.Director:getInstance():getRunningScene():getChildByTag(FishCD.TAG.EFFECT_LAYER_TAG);
    local playerLayer = FishGI.gameScene.playerManager;


    local function addDarkCloud()
        
        FishGF.print("appear cloud");
        local cloud1 = cc.Sprite:create("battle/effect/effect_lamp_clouds.png");
        cloud1:setOpacity(0);
        cloud1:setScale(0);
        cloud1:setPosition(endPos);
        local cloud2 = cc.Sprite:create("battle/effect/effect_lamp_clouds.png");
        cloud2:setRotation(180);
        cloud2:setOpacity(0);
        cloud2:setScale(0);
        cloud2:setPosition(cc.p(endPos.x, endPos.y-cloud1:getContentSize().height/2));


        local fadeAct1 = cc.Sequence:create(cc.FadeTo:create(0.6, 255), cc.FadeTo:create(0.6, 0));
        local scaleAct1 = cc.Sequence:create(cc.ScaleTo:create(1.2, 3), cc.RemoveSelf:create());
        local spaw1 = cc.Spawn:create(fadeAct1, scaleAct1);
        cloud1:runAction(spaw1);

        local fadeAct2 = cc.Sequence:create(cc.FadeTo:create(0.6, 255), cc.FadeTo:create(0.6, 0));
        local scaleAct2 = cc.Sequence:create(cc.ScaleTo:create(1.2, 3), cc.RemoveSelf:create());
        local spaw2 = cc.Spawn:create(fadeAct2, scaleAct2);
        local seq = cc.Sequence:create(cc.DelayTime:create(0.2), spaw2);
        cloud2:runAction(seq);
        endPos = cc.p(endPos.x, endPos.y-20);

        playerLayer:addChild(cloud1, 100);
        playerLayer:addChild(cloud2, 100);

    end

    local function addLamp()
        local dis = cc.pDistanceSQ(beginPos, endPos);


        local rotateAct = cc.RotateBy:create(0.88, 360);
        local fadeAct = cc.Sequence:create(cc.FadeTo:create(0.12, 255), cc.DelayTime:create(0.76), cc.FadeTo:create(0.08, 0));
        local moveAct = cc.MoveTo:create(0.88, endPos);
        local enterCloudAct = cc.Sequence:create(cc.DelayTime:create(0.76), cc.CallFunc:create(addDarkCloud),cc.DelayTime:create(0.2), cc.CallFunc:create(addDarkCloud));
        local callFishAct = cc.Sequence:create(cc.DelayTime:create(1.16), cc.CallFunc:create(callFunc), cc.RemoveSelf:create());

        local lampSprite = cc.Sprite:create("battle/effect/effect_lamp.png");
        lampSprite:setOpacity(255);
        lampSprite:setPosition(beginPos);
        lampSprite:runAction(rotateAct);
        lampSprite:runAction(fadeAct);
        lampSprite:runAction(moveAct);
        lampSprite:runAction(enterCloudAct);
        lampSprite:runAction(callFishAct);
        playerLayer:addChild(lampSprite, 99);
    end

    addLamp();
end

return SkillCallFish;