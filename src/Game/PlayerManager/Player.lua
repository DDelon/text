local Player = class("Player", function()
    return cc.Node:create();
end)

function Player.create(val)
    local player = Player.new();
    player:init(val);
    return player;
end

function Player:init(val)
    self.timelineId = 0
    self.fishArrayId = 0
    self.playerInfo = val.playerInfo
    if self.playerInfo.gradeExp ~= nil then
        self.playerInfo.grade = FishGI.GameTableData:getLVByExp(self.playerInfo.gradeExp).level
        print(self.playerInfo.playerId.."----self.playerInfo.gradeExp="..self.playerInfo.gradeExp.."------------self.playerInfo.grade="..self.playerInfo.grade)
    end

    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()
    self.mIsGoldEnough = true
    self.isShoot = false;
    self.cannon = require("Game/PlayerManager/cannon").create();
    self:addChild(self.cannon,10);
    self.cannon:setDir(self.playerInfo.chairId,self.playerInfo.isSelf,self.playerInfo.playerId);
    self.cannon:setCoins(self.playerInfo.fishIcon);
    self.cannon:setDiamonds(self.playerInfo.crystal);
    if not self.playerInfo.isSelf then
        self.cannon:setMultiple(self.playerInfo.currentGunRate)
    end
    if self.playerInfo.fishIcon <= 0 then
        self.cannon:playBankrupt(true)
    end
    
    LuaCppAdapter:getInstance():setCannon(self.cannon.node_gun,self.playerInfo.playerId);

    --设置炮的类型
    local gunType = self.playerInfo.gunType
    self.cannon:gunChangeByData(gunType)
    --设置c++方面换炮
    FishGMF.setGunChange(self.playerInfo.playerId,gunType +930000000)

    --是否使用狂暴
    local effectId = val.playerInfo.effectId;
    if effectId ~= 0 then
        self.cannon:playEffectAni(effectId);
    end
end

function Player:initMyData()

    if self.playerInfo.isSelf then
        FishGI.myData = self.playerInfo
        self.cannon:setMultiple(self.playerInfo.maxGunRate)
        self.cannon:runCircle()
        FishGI.gameScene.net:sendNewGunRate(self.playerInfo.maxGunRate)
        if FishGI.gameScene.uiGunUpGrade ~= nil then
            FishGI.gameScene.uiGunUpGrade:setCurMultiple(self.playerInfo.maxGunRate)
            FishGI.gameScene.uiGunUpGrade:setCurCrystal(self.playerInfo.crystal)
            if self.playerInfo.maxGunRate >= 1000 then
                FishGI.gameScene:hideGunUpGradePanel()
            end
        end
        local props = self.playerInfo.props
        for k,val in pairs(props) do
            if val.propId > 2  then
                FishGI.gameScene.uiSkillView:setSkillByTag(val);
            end
        end
        FishGI.gameScene.uiAlmInfo:setPosition(cc.p(self.cannon:getPositionX(),self.cannon:getPositionY() +200))

        --发送申请救济金消息
        if self.playerInfo.fishIcon <= 0 then
            FishGI.gameScene.net:sendAlmInfo()
            FishGI.gameScene.uiAlmInfo.isSendEnd = true
            FishGMF.setIsBankup(self.playerInfo.playerId,true)
            FishGI.gameScene.uiAddFishCoin.animation:play("jump", true)
        end

            --更新月卡
        if FishGI.gameScene.uiMonthcard ~= nil then
            FishGI.gameScene.uiMonthcard:setLeftMonthCardDay(self.playerInfo.leftMonthCardDay ,self.playerInfo.monthCardRewardToken)
        end

    end
end

function Player:startEffectId(effectId)
    self.playerInfo.effectId = effectId;

    if effectId ~= 0 then
        self.cannon:playEffectAni(effectId);
    end
end

function Player:endEffectId()
    if self.playerInfo.effectId ~= 0 then
        self.cannon:endEffectAni(self.playerInfo.effectId);
    end
    self.playerInfo.effectId = 0;
end

function Player:shootByDegree(degree)
    --BreakPoint()
    self.isEnd = false;
    if self.isShoot == false then
        self.isShoot = true;
        local degree = degree
        
        local function fire()
            if self.isEnd then
                self.isShoot = false;
                self:stopAllActions();
                self.isEnd = false;
            else
                --检查狂暴是否过期
                FishGI.gameScene.uiSkillView.Skill_17:checkIsEnd();

                --自己提前发射子弹，假扣钱
                local dataTab = {};
                dataTab.createType = "normal"
                dataTab.pos = self.cannon:getLauncherPos();
                dataTab.degree = self.degree - 90;
                dataTab.playerId = self.playerInfo.playerId
                dataTab.lifeTime = 0
                dataTab.bulletId = dataTab.playerId..FishGI.bulletCount
                dataTab.timelineId = self.timelineId
                dataTab.fishArrayId = self.fishArrayId
                dataTab.effectId = self.playerInfo.effectId;
                dataTab.fireType = 1

                --c++创建子弹，若不成功返回失败，并且自动切换炮倍
                local backData = FishGMF.myCreateBullet(dataTab)
                

                --失败类型，0.成功   1.没有玩家  2.子弹数太多 3.切换炮倍  4.当前炮倍大于自己最高炮倍   
                            --5.没钱了 6,当前炮倍大于自己最高炮倍并且炮倍大于1000
                local result = self:isCanShoot(backData)
                if not result then
                    return
                end
                dataTab.frameId = backData.frameId
                print("------------------------------------------------backData.frameId="..backData.frameId)
                dataTab.bulletRate = backData.bulletRate
                FishGI.bulletCount = FishGI.bulletCount +1
                FishGI.eventDispatcher:dispatch("sendPlayerFire", dataTab);


                
            end
        end
        self.degree = degree;
        self.cannon:setCannonRotation(degree-90);
        local act = self:getActionByTag(10101);
        if act == nil then
            local seq = cc.Sequence:create(cc.CallFunc:create(fire), cc.DelayTime:create(FishCD.PLAYER_SHOOT_INTERVAL))
            local act = cc.RepeatForever:create(seq);
            act:setTag(10101);
            self:runAction(act);
        end
    end
    
end

--判断是否能开炮
function Player:isCanShoot(backData)
    --失败类型，0.成功   1.没有玩家  2.子弹数太多 3.切换炮倍  4.当前炮倍大于自己最高炮倍 5.破产 
                --6,当前炮倍大于自己最高炮倍并且炮倍大于1000
    if backData.isSucceed == 0 then
        return true
    elseif backData.isSucceed == 1 then     --没有玩家
        print("------no player------------")
        return false
    elseif backData.isSucceed == 3 then     --切换炮倍
        if backData.currentGunRate ~= 0 then
            self.cannon:setMultiple(backData.currentGunRate)
            FishGI.gameScene.net:sendNewGunRate(backData.currentGunRate)
        end
        return false
    elseif backData.isSucceed == 2 then     --子弹数太多 
        FishGF.showSystemTip(nil,800000090, 1)
        return false
    elseif backData.isSucceed == 4 then     --当前炮倍大于自己最高炮倍
        --停止发炮
        if FishGI.isAutoFire then
            self.cannon.uiCannonChange:setAutoFire(false)
            self:endShoot()
        else
            self:endShoot()
        end

        local result = FishGI.gameScene.uiGunUpGrade:isCanGunUpData() 
        if result and FishGI.gameScene.uiGunUpGrade:isVisible() then
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    --要发送解锁炮倍消息
                    FishGI.gameScene.net:sendUpgradeCannon()
                end
            end
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000095),callback)
        else
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    FishGI.gameScene.uiShopLayer:showLayer()
                    FishGI.gameScene.uiShopLayer:setShopType(2)
                end
            end
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000093),callback)
        end

        return false
    elseif backData.isSucceed == 5 then     --破产
        --停止发炮
        if FishGI.isAutoFire then
            self.cannon.uiCannonChange:setAutoFire(false)
            self:endShoot()
        else
            self:endShoot()
        end
        return false
    elseif backData.isSucceed == 6 then     --当前炮倍大于自己最高炮倍并且炮倍大于1000
        FishGF.showSystemTip(nil,800000208,1)
        return false
    end
    return false
end

function Player:shoot(pos)
    local degree = FishGF.getRotateDegreeRadians(pos, self.cannon:getRotatePos());
    self:shootByDegree(degree)
    
end

function Player:setRotateByDeg(degree)
    self.degree = degree;
    self.cannon:setCannonRotation(degree-90);
end

function Player:setRotateByPos(pos)
    if self.cannon:getCoins() < self.cannon:getMultiple() then
        return
    end
    local degree = FishGF.getRotateDegreeRadians(pos, self.cannon:getRotatePos());
    if degree >180 or degree < 0 then
        return
    end
    self.degree = degree;
    self.cannon:setCannonRotation(degree-90);
end

function Player:endShoot()
    if FishGI.isAutoFire then
        self.isEnd = false;
    else
        self.isEnd = true;
    end
end

function Player:setMyAimFish(timelineId,fishArrayId)
    self.timelineId = timelineId
    self.fishArrayId = fishArrayId
end

--玩家信息框弹出
function Player:showPlayerInfo()
    if self.playerInfoLayer:getIsCanSend() then
        --发送获取玩家消息
        FishGI.gameScene.net:sendUpDataPlayerData(self.playerInfo.playerId)
    end

    local data = {}
    data.nickName = self.playerInfo.nickName
    data.vip_level = self.playerInfo.vip_level
    data.maxGunRate = FishGMF.getAndSetPlayerData(self.playerInfo.playerId,false,"maxGunRate",0).maxGunRate
    data.playerId = self.playerInfo.playerId
    data.grade = self.playerInfo.grade
    data.gunType = self.playerInfo.gunType  
    self.playerInfoLayer:setPlayerData(data)

    self.playerInfoLayer:showAct()

end

function Player:getCannonPos()
    local pos = {}
    pos.x= FishCD.aimPosTab[self.playerInfo.chairId].x*self.scaleX_
    pos.y= FishCD.aimPosTab[self.playerInfo.chairId].y*self.scaleY_

    return pos
end

return Player;
