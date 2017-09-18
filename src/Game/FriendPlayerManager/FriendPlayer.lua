local FriendPlayer = class("FriendPlayer", cc.load("mvc").ViewBase)

FriendPlayer.AUTO_RESOLUTION   = true
FriendPlayer.RESOURCE_FILENAME = "ui/battle/friend/uifriendplayer"
FriendPlayer.RESOURCE_BINDING  = {
    ["node_player_data"]            = { ["varname"] = "node_player_data" },
    ["img_integral_bg"]             = { ["varname"] = "img_integral_bg" },
    ["fnt_integral"]                = { ["varname"] = "fnt_integral" },
    ["img_bullet_bg"]               = { ["varname"] = "img_bullet_bg" },
    ["fnt_bullet"]                  = { ["varname"] = "fnt_bullet" },
    ["img_diamonds_bg"]             = { ["varname"] = "img_diamonds_bg" },
    ["fnt_diamonds"]                = { ["varname"] = "fnt_diamonds" },
    ["node_prop_buff"]              = { ["varname"] = "node_prop_buff" },
    ["node_prop_buff_1"]            = { ["varname"] = "node_prop_buff_1" },
    ["node_prop_buff_2"]            = { ["varname"] = "node_prop_buff_2" },
    ["node_prop_buff_3"]            = { ["varname"] = "node_prop_buff_3" },
    ["node_prop_buff_4"]            = { ["varname"] = "node_prop_buff_4" },
    ["node_prop_buff_5"]            = { ["varname"] = "node_prop_buff_5" },
    ["fnt_curadd"]                  = { ["varname"] = "fnt_curadd" },
    ["node_player_cannon"]          = { ["varname"] = "node_player_cannon" },
    ["node_fun_promote_ani"]        = { ["varname"] = "node_fun_promote_ani" }, 
    ["node_game_status"]            = { ["varname"] = "node_game_status" },
    ["spr_no_ready"]                = { ["varname"] = "spr_no_ready" },
    ["spr_ready"]                   = { ["varname"] = "spr_ready" },
    ["spr_offline"]                 = { ["varname"] = "spr_offline" },
    ["spr_exit"]                    = { ["varname"] = "spr_exit" },
    ["spr_wait_join"]               = { ["varname"] = "spr_wait_join" },
}

function FriendPlayer:onCreate( ... )
    self:openTouchEventListener()
    self.spr_no_ready:setVisible(false)
    self.spr_ready:setVisible(false)
    self.spr_offline:setVisible(false)
    self.spr_exit:setVisible(false)
    self.fnt_curadd:setOpacity(0)
    self.spr_wait_join:setVisible(false)
    self.cannon = require("Game/FriendPlayerManager/FriendCannon").new(self, self.node_player_cannon)
    self.tPropBuffInfo = {}
    self.tPropBuffInfo.count = 5
    self.tPropBuffInfo.spr_index = {}
    self.tPropBuffInfo.spr_prop_buff = {}
    for i = 1, self.tPropBuffInfo.count, 1 do 
        self.tPropBuffInfo.spr_index[i] = 0
        self.tPropBuffInfo.spr_prop_buff[i] = require("Game/Friend/FriendPropBuff").new(self, self["node_prop_buff_"..i])
        self.tPropBuffInfo.spr_prop_buff[i]:setVisible(false)
    end 
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()
    self.iChairId = 0


    local dataStr = tostring(FishGI.GameConfig:getConfigData("config", tostring(990000079), "data"))
    self.RateData = {}
    local tab = string.split(dataStr,";")
    for i,val in ipairs(tab) do
        local data = string.split(val,",")
        data.Rate = tonumber(FishGI.GameConfig:getConfigData("cannon", tostring(920000000+tonumber(data[2])), "times"))
        table.insert( self.RateData, data )
    end

    self:runAction(self.node_fun_promote_ani["animation"])

end

function FriendPlayer:onTouchBegan(touch, event)
    return false
end

function FriendPlayer:init(val)
    self.timelineId = 0 
    self.fishArrayId = 0
    self.isShoot = false;

    self:initWithData(val)

    --self.cannon:setDir(self.playerInfo.chairId,self.playerInfo.isSelf,self.playerInfo.playerId)

    LuaCppAdapter:getInstance():setCannon(self.cannon.node_gun,self.playerInfo.playerId)

end

function FriendPlayer:initWithData(val)
    self.playerInfo = val
    self.isSelf = val.isSelf

    --设置炮的类型
    if self.playerInfo.gunType == nil or self.playerInfo.gunType == 0 then 
        self.playerInfo.gunType = 1
    end 
    local gunType = self.playerInfo.gunType
    self.cannon:gunChangeByData(gunType)
    --设置c++方面换炮
    FishGMF.setGunChange(self.playerInfo.playerId,gunType +930000000)
    
    --初始准备中
    local state = 0
    --玩家状态设置
	if self.playerInfo.ready then
        state = 1
	end
    if FishGI.SERVER_STATE ~= 0 then
        state = 3
    end
	if self.playerInfo.isDisonnected then
        state = 2
	end 
    if self.playerInfo.isLeave then 
        state = 4
    end 
    self:setPlayerGameStatus(state)


	self.playerInfo.vip_level = FishGI.GameTableData:getVIPByCostMoney(self.playerInfo.vipExp).vip_level
	self.playerInfo.grade = FishGI.GameTableData:getLVByExp(self.playerInfo.gradeExp).level

    self.cannon:setMultiple(self.playerInfo.currentGunRate)
    self:setScore(self.playerInfo.score)

    for k,val in pairs(self.playerInfo.friendProps) do
        if val.propId == 7 then 
            self:setBullet(val.propCount)
        elseif self.isSelf then 
            FishGI.gameScene.uiMainLayer:setPropCount(val.propId,val.propCount)
        end 
    end

    if self.playerInfo.isSelf ~= true then
        self.fnt_curadd:setFntFile("fnt/bonus_num_2.fnt")
        self.img_diamonds_bg:setVisible(false)
        if self.playerInfo.chairId <= 2 then
            self.node_prop_buff:setPositionY(self.node_prop_buff_pos_y-37)
            self.fnt_curadd:setPositionY(self.fnt_curadd_pos_y-37)
        else 
            self.node_prop_buff:setPositionY(self.node_prop_buff_pos_y+37)
            self.fnt_curadd:setPositionY(self.fnt_curadd_pos_y+37)
        end
    else
        self:setDiamonds(self.playerInfo.crystal)
        FishGI.gameScene.uiMainLayer.uiBox:setScore(self.playerInfo.score)
        FishGI.gameScene.uiMainLayer.uiGameData:setOwnerIndex(self.playerInfo.chairId)
    end

    FishGI.gameScene.uiMainLayer.uiGameData:setPlayerScore(self.playerInfo.score, self.playerInfo.chairId)
    if FishGI.gameScene.playerManager:getCreatorPlayerId() == FishGI.myData.playerId and FishGI.SERVER_STATE == 0 then 
        self.playerInfoLayer:openKickOut(true)
    else
        self.playerInfoLayer:openKickOut(false)
    end 

    self.cannon:setDir(self.playerInfo.chairId,self.playerInfo.isSelf,self.playerInfo.playerId)
end

function FriendPlayer:initPos(iChairId)
    if self.iChairId == iChairId then 
        return
    end 
    self.iChairId = iChairId
    if iChairId == 1 then 
        self:setPosition(cc.p(0, 0))
    elseif iChairId == 2 then 
        self:setPosition(cc.p(cc.Director:getInstance():getWinSize().width, 0))
    elseif iChairId == 3 then 
        self:setPosition(cc.p(cc.Director:getInstance():getWinSize().width, cc.Director:getInstance():getWinSize().height))
    elseif iChairId == 4 then 
        self:setPosition(cc.p(0, cc.Director:getInstance():getWinSize().height))
    end 
    --X、Y轴坐标正负值
    local iPosXPositive = 1
    local iPosYPositive = 1
    if iChairId == 1 then 
        iPosXPositive = 1
        iPosYPositive = 1
    elseif iChairId == 2 then 
        iPosXPositive = -1
        iPosYPositive = 1
    elseif iChairId == 3 then 
        iPosXPositive = -1
        iPosYPositive = -1
    elseif iChairId == 4 then 
        iPosXPositive = 1
        iPosYPositive = -1
    end 
    self.img_integral_bg:setPosition(cc.p(math.abs( self.img_integral_bg:getPositionX() )*iPosXPositive, 
        math.abs( self.img_integral_bg:getPositionY() )*iPosYPositive))
    self.img_bullet_bg:setPosition(cc.p(math.abs( self.img_bullet_bg:getPositionX() )*iPosXPositive, 
        math.abs( self.img_bullet_bg:getPositionY() )*iPosYPositive))
    self.img_diamonds_bg:setPosition(cc.p(math.abs( self.img_diamonds_bg:getPositionX() )*iPosXPositive, 
        math.abs( self.img_diamonds_bg:getPositionY() )*iPosYPositive))
    self.node_prop_buff:setPosition(cc.p(math.abs( self.node_prop_buff:getPositionX() )*iPosXPositive, 
        math.abs( self.node_prop_buff:getPositionY() )*iPosYPositive))
    for i = 1, 5, 1 do 
        self.tPropBuffInfo.spr_prop_buff[i]:setPosition(cc.p(math.abs( self.tPropBuffInfo.spr_prop_buff[i]:getPositionX() )*iPosXPositive, 
            math.abs(self.tPropBuffInfo.spr_prop_buff[i]:getPositionY() )*iPosYPositive))
    end 
    self.fnt_curadd:setPosition(cc.p(math.abs( self.fnt_curadd:getPositionX() )*iPosXPositive, 
        math.abs( self.fnt_curadd:getPositionY() )*iPosYPositive))
    self.cannon:setPosition(cc.p(math.abs( self.cannon:getPositionX() )*iPosXPositive, 
        math.abs( self.cannon:getPositionY() )*iPosYPositive))
    self.node_fun_promote_ani:setPosition(cc.p(math.abs( self.node_fun_promote_ani:getPositionX() )*iPosXPositive, 
        math.abs( self.node_fun_promote_ani:getPositionY() )*iPosYPositive))
    self.node_game_status:setPosition(cc.p(math.abs( self.node_game_status:getPositionX() )*iPosXPositive, 
        math.abs( self.node_game_status:getPositionY() )*iPosYPositive))
    self.spr_wait_join:setPosition(cc.p(math.abs( self.spr_wait_join:getPositionX() )*iPosXPositive, 
        math.abs( self.spr_wait_join:getPositionY() )*iPosYPositive))
    if iChairId == 3 or iChairId == 4 then 
        for i = 1, self.tPropBuffInfo.count, 1 do 
            self.tPropBuffInfo.spr_prop_buff[i].node_data:setPositionY(-math.abs(self.tPropBuffInfo.spr_prop_buff[i].node_data:getPositionY()))
        end 
        self.cannon:setRotation(180)
    else 
        for i = 1, self.tPropBuffInfo.count, 1 do 
            self.tPropBuffInfo.spr_prop_buff[i].node_data:setPositionY(math.abs(self.tPropBuffInfo.spr_prop_buff[i].node_data:getPositionY()))
        end 
        self.cannon:setRotation(0)
    end 
    self.node_prop_buff_pos_y = self.node_prop_buff:getPositionY()
    self.fnt_curadd_pos_y = self.fnt_curadd:getPositionY()
end 

function FriendPlayer:initMyData()
    if self.playerInfo.isSelf then
        self.cannon:runCircle()
            --更新月卡
        if FishGI.gameScene.uiMainLayer.uiMonthcard ~= nil then
            FishGI.gameScene.uiMainLayer.uiMonthcard:setLeftMonthCardDay(self.playerInfo.leftMonthCardDay ,self.playerInfo.monthCardRewardToken)
        end

    end

end

--已有玩家加入
function FriendPlayer:isShowPlayer( bShowPlayer )
    bShowPlayer = bShowPlayer ~= nil and bShowPlayer or false
    self.bShowPlayer = bShowPlayer
    self.node_player_data:setVisible(self.bShowPlayer)
    self.node_player_cannon:setVisible(self.bShowPlayer)
    self.node_game_status:setVisible(self.bShowPlayer)
    self.spr_wait_join:setVisible(not self.bShowPlayer)
    self.spr_wait_join:stopAllActions()
    if not self.bShowPlayer then 
        self.playerInfoLayer:stopAllActions()
        self.playerInfoLayer:setVisible(false)
        self.spr_wait_join:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.FadeTo:create(0.8,0),cc.DelayTime:create(0.2),cc.FadeTo:create(0.8,255))))
    end 
end

--积分设置
function FriendPlayer:setScore( score )
    if score < 0 then
        score = 0
    end
    self.fnt_integral:setString(score)
end

function FriendPlayer:getScore( )
    return tonumber(self.fnt_integral:getString())
end

--子弹设置
function FriendPlayer:setBullet( bullet )
    if bullet < 0 then
        bullet = 0
    end
    self.fnt_bullet:setString(bullet)
end

function FriendPlayer:getBullet( )
    return tonumber(self.fnt_bullet:getString())
end

--钻石设置
function FriendPlayer:setDiamonds( diamonds )
    if diamonds < 0 then
        diamonds = 0
    end
    self.fnt_diamonds:setString(diamonds)
end

function FriendPlayer:getDiamonds( )
    return tonumber(self.fnt_diamonds:getString())
end

function FriendPlayer:shootByDegree(degree)
    if FishGI.SERVER_STATE == 0 then
        FishGF.showSystemTip(nil,800000274,1)
        return 
    end
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
                --自己提前发射子弹，假扣钱
                local dataTab = {};
                dataTab.createType = "friend"
                dataTab.isCost = (not FishGI.gameScene.skillManager:isFreeFire())       --是否花费子弹
                dataTab.pos = self.cannon:getLauncherPos();
                dataTab.degree = self.degree - 90;
                dataTab.playerId = self.playerInfo.playerId
                dataTab.lifeTime = 0
                dataTab.bulletId = dataTab.playerId..FishGI.bulletCount
                dataTab.timelineId = self.timelineId
                dataTab.fishArrayId = self.fishArrayId
                dataTab.cost = 1
                
                dataTab.fireType = 1

                --c++创建子弹，若不成功返回失败，并且自动切换炮倍
                local backData = FishGMF.myCreateBullet(dataTab)

                --失败类型，0.成功	1.没有玩家	2.飞行子弹数太多	3.没子弹了 
                local result = self:isCanShoot(backData)
                if not result then
                    return
                end

                dataTab.frameId = backData.frameId
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
function FriendPlayer:isCanShoot(backData)
    --失败类型，0.成功	1.没有玩家	2.飞行子弹数太多	3.没子弹了 
    if backData.isSucceed == 0 then
        self:isChangeRate(tonumber(backData.usedBulletShowCount),tonumber(backData.bulletRate))
        return true
    elseif backData.isSucceed == 1 then     --没有玩家
        print("------no FriendPlayer------------")
        return false
    elseif backData.isSucceed == 2 then     --子弹数太多 
        FishGF.showSystemTip(nil,800000090, 1)
        return false
    elseif backData.isSucceed == 3 then     --没子弹了
        FishGF.showSystemTip(nil,800000252, 1)
        --停止发炮
        if FishGI.isAutoFire then
            self.cannon.uiCannonChange:setAutoFire(false)
        end
        self:endShoot()

        return false
    end
    return false
end

--是否切换炮倍
function FriendPlayer:isChangeRate(usedBulletShowCount,bulletRate)
    local datatab = self.RateData
    local count = #datatab
    local rate = tonumber(datatab[count].Rate)
    for i = 1,count do
        local aimAount = tonumber(datatab[i][1])
        if usedBulletShowCount < aimAount then
            rate = tonumber(datatab[i].Rate)
            break 
        end
    end

    if bulletRate ~= rate then 
        FishGF.print("-----------isChangeRate--------------newCannonRate="..rate)
        --切换炮倍
        FishGMF.changeGunRate(self.playerInfo.playerId,rate,0)
        self.cannon:setMultiple(rate)
    end

end 

function FriendPlayer:getCannonPos()
    local pos = cc.p(0, 0)
    local posTmp = cc.p((self.cannon:getPositionX()+self.cannon.node_gun:getPositionX())*self.scaleX_, 
            (self.cannon:getPositionY()+self.cannon.node_gun:getPositionY())*self.scaleY_)
    if self.iChairId == 1 then 
        pos = posTmp
    elseif self.iChairId == 2 then 
        pos = cc.p(display.width-math.abs(posTmp.x), posTmp.y)
    elseif self.iChairId == 3 then 
        pos = cc.p(display.width-math.abs(posTmp.x), display.height-math.abs(posTmp.y))
    elseif self.iChairId == 4 then 
        pos = cc.p(posTmp.x, display.height-math.abs(posTmp.y))
    end
    return pos
end

function FriendPlayer:shoot(pos)
    local degree = FishGF.getRotateDegreeRadians(pos, self:getCannonPos());
    self:shootByDegree(degree)
end

function FriendPlayer:setRotateByDeg(degree)
    self.degree = degree;
    self.cannon:setCannonRotation(degree-90);
end

function FriendPlayer:setRotateByPos(pos)
    local degree = FishGF.getRotateDegreeRadians(pos, self:getCannonPos());
    if degree >180 or degree < 0 then
        return
    end
    self.degree = degree;
    self.cannon:setCannonRotation(degree-90);
end

function FriendPlayer:endShoot()
    if FishGI.isAutoFire then
        self.isEnd = false;
    else
        self.isEnd = true;
    end
end

function FriendPlayer:setMyAimFish(timelineId,fishArrayId)
    self.timelineId = timelineId
    self.fishArrayId = fishArrayId
end

--玩家信息框弹出
function FriendPlayer:showPlayerInfo()
    if self.playerInfoLayer:getIsCanSend() then
        --发送获取玩家消息
        FishGI.gameScene.net:sendFriendGetPlayerInfo(self.playerInfo.playerId)
    end

    local data = {}
    data.nickName = self.playerInfo.nickName
    data.vip_level = self.playerInfo.vip_level
    data.maxGunRate = FishGMF.getAndSetPlayerData(self.playerInfo.playerId,false,"maxGunRate",0).maxGunRate
    data.playerId = self.playerInfo.playerId
    data.grade = self.playerInfo.grade
    data.chairId = self.playerInfo.chairId
    data.gunType = self.playerInfo.gunType
    self.playerInfoLayer:setPlayerData(data)

    self.playerInfoLayer:showAct()

end


--设置玩家状态  0准备中   1准备    2断线    3开始游戏  4离开游戏
function FriendPlayer:setPlayerGameStatus(status)
    self.status = status
    if status == 3 then 
        self.playerInfoLayer:openKickOut(false)
    end 
    self.spr_no_ready:setVisible(false)
    self.spr_ready:setVisible(false)
    self.spr_offline:setVisible(false)
    self.spr_exit:setVisible(false)
    self.cannon:setCannonIsGray(false)
    if status == 0 then
        self.spr_no_ready:setVisible(true)
    elseif status == 1 then
        self.spr_ready:setVisible(true)
    elseif status == 2 then
        self.spr_offline:setVisible(true)
        self.cannon:setCannonIsGray(true)
    elseif status == 4 then 
        self.spr_exit:setVisible(true)
        self.cannon:setCannonIsGray(true)
    end

end

function FriendPlayer:getPlayerGameStatus()
    return self.status
end

function FriendPlayer:buttonClicked(viewTag, btnTag)
    self.parent_:buttonClicked(viewTag, btnTag)
end

function FriendPlayer:setPropBuff(iPropId, iCount, data) 
    if iCount > 0 then 
        local iSprIndex = self:initPropBuff(iPropId)
        if iSprIndex == 0 then 
            return 
        end 
        local sprPropBuff = self.tPropBuffInfo.spr_prop_buff[iSprIndex]
        sprPropBuff.iCount = iCount
        sprPropBuff:setData(data)
    else 
        self:removePropBuff(iPropId)
    end 
end 

function FriendPlayer:initPropBuff( iPropId )
    if self.tPropBuffInfo.spr_index[iPropId] == nil then 
        return 0
    end 
    local iSprIndex = self.tPropBuffInfo.spr_index[iPropId]
    if iSprIndex == 0 then 
        iSprIndex = 1
        while iSprIndex <= self.tPropBuffInfo.count and self.tPropBuffInfo.spr_prop_buff[iSprIndex].iPropId > 0 do 
            iSprIndex = iSprIndex + 1
        end 
        if iSprIndex > self.tPropBuffInfo.count then 
            iSprIndex = 0
        end 
        if iSprIndex ~= 0 then 
            local sprPropBuff = self.tPropBuffInfo.spr_prop_buff[iSprIndex]
            self.tPropBuffInfo.spr_index[iPropId] = iSprIndex
            sprPropBuff:setPropId(iPropId)
            sprPropBuff:setVisible(true)
        end
    end 
    return iSprIndex
end

function FriendPlayer:removePropBuff(iPropId)
    if self.tPropBuffInfo.spr_index[iPropId] == nil then 
        return 0
    end 
    local iSprIndex = self.tPropBuffInfo.spr_index[iPropId]
    if iSprIndex == 0 then 
        return 
    end 
    self.tPropBuffInfo.spr_index[iPropId] = 0
    local iMaxIndex = iSprIndex
    if iSprIndex < self.tPropBuffInfo.count then 
        for i = iSprIndex, self.tPropBuffInfo.count-1, 1 do 
            local sprPropBuff = self.tPropBuffInfo.spr_prop_buff[i]
            local sprPropBuffNew = self.tPropBuffInfo.spr_prop_buff[i+1]
            if sprPropBuffNew.iPropId > 0 then 
                sprPropBuff:setPropId(sprPropBuffNew.iPropId)
                sprPropBuff:setData(sprPropBuffNew.data)
                self.tPropBuffInfo.spr_index[sprPropBuff.iPropId] = i
                iMaxIndex = i+1
            else 
                iMaxIndex = i
                break 
            end 
        end 
    else 
        iMaxIndex = self.tPropBuffInfo.count
    end
    self.tPropBuffInfo.spr_prop_buff[iMaxIndex]:setPropId(0)
    self.tPropBuffInfo.spr_prop_buff[iMaxIndex]:setData("")
    self.tPropBuffInfo.spr_prop_buff[iMaxIndex]:setVisible(false)
end 

function FriendPlayer:startFirePowerAni()
    self.cannon:startFirePowerAni()
end

function FriendPlayer:stopFirePowerAni()
    self.cannon:stopFirePowerAni()
end

function FriendPlayer:getAniNodeLayer()
    return self.cannon:getAniNodeLayer()
end 

function FriendPlayer:startGunPromoteAni()
    self.node_fun_promote_ani["animation"]:play("start", false)
end

return FriendPlayer;
