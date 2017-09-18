local BaseClient = require("Other/BaseClient");
local WebTool = require("Other/WebTool");


local GameFriendNet = class("GameFriendNet", BaseClient)
local proto = FishGI.gameNetMesProto
function GameFriendNet:ctor()
	self.msg = FishNM;
	BaseClient.ctor(self);
    FishGI.eventDispatcher:removeAllListener();
	--注册网络事件
    self:RegisterMsgProcess(FishNM.HEAD.MSG_S2C_JMSG, self.OnJMsg, "OnJMsg");

    self.needRefrshGold = false;
end

function GameFriendNet:OnCreateScene()
    local scene = require("Game/Friend/GameFriendScene").create(self);
    FishGI.gameScene = scene;
    return FishGI.gameScene;
end

function GameFriendNet:OnInitialize()
  return true;
end

function GameFriendNet:openNetSchedule()
    local count = FishCD.HEART_DELAYTIME;
    local function updateInline()
        if self.isSend then
            if self.isRecv then
                count = FishCD.HEART_DELAYTIME;
                self.isRecv = false;
            else
                count = count-1;
                if count <= 0 then
                    self.isSend = false;
                    self.isRecv = false;
                    FishGF.print("cannot recv heart data close net");
                    count = FishCD.HEART_DELAYTIME;
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.netScheduleId);
                    self:disconnectTips();
                end
            end
        end
    end
    self.netScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateInline, 1.0, false);
end

function GameFriendNet:openUpdateInline()
    local function updateInline()
        FishGMF.updateInline()
    end
    self.onRefreshDataId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateInline, 1/20, false);
end

function GameFriendNet:closeSchedule()
    if self.netScheduleId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.netScheduleId);
        self.netScheduleId = nil
    end
    if self.onRefreshDataId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onRefreshDataId);
        self.onRefreshDataId = nil
    end
end

function GameFriendNet:disconnectTips()
    local msg = FishGI.GameConfig:getLanguageFromBin("language", "800000036");
    FishGF.createCloseSocketNotice(msg,"GameFriendNetdisconnectTips")
end

------------------------------------------------------------------------------------------------
-------------------------------------------从服务器接收消息-------------------------------------
------------------------------------------------------------------------------------------------
function GameFriendNet:OnJMsg(msg)
    local ptr = msg:ReadData(0)
    local data, typeName = jmsg.decodeBinary(proto, ptr)
    if self.isWaitLoaded ~= nil and self.isWaitLoaded == true and  typeName ~= "MSGS2CFriendGameLoaded" then
        return
    end
    self.isWaitLoaded = false

    --print("-------------------------------onJmsg, typeName="..typeName)
    self.isRecv = true;
    self.isSend = false;
    if typeName == "MSGS2CHeartBeat" then
        self:OnServerHeartBeat(data)
    elseif typeName == "MSGS2CFriendPlayerShoot" then
        self:OnPlayerShoot(data)
    elseif typeName == "MSGS2CFriendPlayerHit" then
        self:OnHit(data)
    elseif typeName == "MSGS2CFriendGameLoaded" then
        self:OnGameLoaded(data)
    elseif typeName == "MSGS2CFriendOtherPlayerJoin" then
        self:OnFriendOtherPlayerJoin(data)
    elseif typeName == "MSGS2CFriendReady" then
        self:OnReady(data)
    elseif typeName == "MSGS2CFriendLeaveGame" then
        self:OnLeaveGame(data)
    elseif typeName == "MSGS2CFriendStartGame" then
        self:OnStartGame(data)
    elseif typeName == "MSGS2CFriendPlayerDisconnect" then
        self:OnPlayerDisconnect(data)
    elseif typeName == "MSGS2CFriendPlayerReconnect" then
        self:OnPlayerReconnect(data)
    elseif typeName == "MSGS2CFriendServerReady" then
        self:OnServerReady(data)
    elseif typeName == "MSGS2CFriendPlayerGunRateChange" then
        self:OnPlayerGunRateChange(data)
    elseif typeName == "MSGS2CFriendSendReward" then
        self:OnSendReward(data)
    elseif typeName == "MSGS2CFriendGameOver" then
        self:OnGameOver(data)
    elseif typeName == "MSGS2CFriendUseProp" then
        self:OnUsePropSkill(data)
    elseif typeName == "MSGS2CEmoticon" then
        self:onEmotionIcon(data)
    elseif typeName == "MSGS2CMagicprop" then
        self:onMagicprop(data)
    elseif typeName == "MSGS2CGunTpyeChange" then
        self:OnGunTpyeChange(data)
    elseif typeName == "MSGS2CFriendGetPlayerInfo" then
        self:OnFriendGetPlayerInfo(data)
    elseif typeName == "MSGS2CFriendEffectUpdate" then
        self:OnUpdateSkillEffect(data)
    elseif typeName == "MSGS2CFriendKickOut" then
        self:OnFriendKickOut(data)
    elseif typeName == "MSGS2CBulletTargetChange" then
        self:OnBulletTargetChange(data);
    elseif typeName == "MSGS2CGetVipDailyReward" then
        FishGI.eventDispatcher:dispatch("GetVipDailyReward", data);
    end

    return true;
end

--[[
* @brief 玩家进入桌子，
* @param player 进入的玩家对象
* @param isSelf 是否是自己
--]]
function GameFriendNet:OnPlayerJoin(player, isSelf)
    
    local function exchange(tab, index1, index2)
        local temp = tab[index1];
        tab[index1] = tab[index2];
        tab[index2] = temp;
        return tab;
    end
    if isSelf then
        FishGI.deskId = player.deskid;
        print("------FishGI.deskId="..FishGI.deskId)
    end
    local temp1 = FishGI;
    local temp2 = player.deskid;
    print("GameFriendNet OnPlayerJoin---player.id="..player.id);
    print(isSelf);

    local chairId = player.chairid+1;
    local playerTab = {};
    playerTab.player = {};
    playerTab.player.chairId = chairId;
    playerTab.player.id = player.id;
    playerTab.isSelf = isSelf;

    if FishGI.isPlayerFlip then
        if chairId == 1 then
            playerTab.player.chairId = 3;
        elseif chairId == 2 then
            playerTab.player.chairId = 4;
        elseif chairId == 3 then
            playerTab.player.chairId = 1;
        elseif chairId == 4 then
            playerTab.player.chairId = 2;
        end
        self.mPlayer[playerTab.player.chairId] = playerTab;
    else
        if isSelf then
        --是玩家
            if chairId == 3 then
                --换位置
                playerTab.player.chairId = 1;
                self.mPlayer[playerTab.player.chairId] = playerTab;
                FishGI.isPlayerFlip = true;
            elseif chairId == 4 then
                playerTab.player.chairId = 2;
                self.mPlayer[playerTab.player.chairId] = playerTab;
                FishGI.isPlayerFlip = true;
            else
                self.mPlayer[chairId] = playerTab;
            end
        else

            self.mPlayer[chairId] = playerTab;
        end
    end 
    local tempTab = self.mPlayer;
    --FishGI.eventDispatcher:dispatch("PlayerJoin", playerTab);
    FishGI.gameScene:OnPlayerJoin(player.id)
end

--玩家加入游戏场景
function GameFriendNet:OnFriendOtherPlayerJoin(data)
    print("GameFriendNet OnFriendOtherPlayerJoin");
    FishGI.gameScene.playerManager:playerJoin(data.info)
end

--[[
* @brief 玩家离开桌子
* @param player 玩家对象
--]]
function GameFriendNet:OnPlayerLeave(player)
    print(player);
    local chairId = player.chairid;
    print("玩家离开_____________________"..chairId);   
    
    if FishGI.isPlayerFlip then
    end
    local playerTab = self.mPlayer;
    if FishGI.isPlayerFlip then
        if chairId+1 == 1 then
            self.mPlayer[3] = nil;
        elseif chairId+1 == 2 then
            self.mPlayer[4] = nil;
        elseif chairId+1 == 3 then
            self.mPlayer[1] = nil;
        elseif chairId+1 == 4 then
            self.mPlayer[2] = nil;
        end
    else
        self.mPlayer[chairId+1] = nil;
    end
    local valTab = {};
    valTab.player = {};
    valTab.player.id = player.id;
    valTab.player.chairId = chairId+1;
    local playerIdTab = {};
    playerIdTab.id = player.id;
         

end

function GameFriendNet:OnGameLoaded(data)
    self.isLoaded = true
    if data.roomInfo.started then 
        FishGI.SERVER_STATE = 1
    end 
    FishGI.gameScene.playerManager:onAllPalyerInfo(data)
    FishGI.gameScene:onGameLoaded(data)
end

function GameFriendNet:OnReady(data)
    if data.playerId == FishGI.gameScene.playerManager.selfIndex then
        FishGF.waitNetManager(false,nil,"MSGC2SFriendReady")
    end
    FishGI.gameScene:onReady(data)
end

function GameFriendNet:OnStartGame(data)
    FishGF.waitNetManager(false,nil,"StartGame")
    FishGI.gameScene:onStartGame(data)
end

--玩家离开
function GameFriendNet:OnLeaveGame(data)
    data.leaveType = 5
    FishGI.gameScene:onLeaveGame(data)
end

function GameFriendNet:OnServerHeartBeat(data)
--     print("收到心跳回复,服务端帧号:"..data.frameCount)
    FishGI.eventDispatcher:dispatch("SyncFrame", data)      
end

--设置道具
function GameFriendNet:sendAddMoney(data)
    if data == nil then
        return
    end
    self:sendJMsg("MSGC2SSetProp", data)
end

--玩家断线
function GameFriendNet:OnPlayerDisconnect(data)
    local tab = {}
    tab.playerId = data.playerId
    tab.status = 2
    FishGI.gameScene.playerManager:setPlayerGameStatus(tab)
    --FishGI.gameScene.skillManager:pausePlayerAllBuff(data.playerId);
end

--断线重连
function GameFriendNet:OnPlayerReconnect(data)
    FishGI.gameScene.playerManager:OnPlayerReconnect(data)
    --FishGI.gameScene.skillManager:resumePlayerAllBuff(data.playerInfo.playerId);
end

--房间结束
function GameFriendNet:OnGameOver(data)
    local reason = data.reason
    print("------------------------OnFriendGameOver--------reason="..reason)

    if reason == 1 then         --1：房主解散
        if FishGI.gameScene.playerManager.selfIndex == FishGI.gameScene.playerManager.creatorPlayerId then
            FishGF.doMyLeaveGame(7)
        else
            FishGF.doMyLeaveGame(3)
        end
        
    elseif reason == 2 then       --游戏结束
        FishGI.exitType = 4
        FishGI.SERVER_STATE = 2
        --停止发炮
        local mySelf = FishGI.gameScene.playerManager:getMyData()
        if FishGI.isAutoFire then
            mySelf.cannon.uiCannonChange:setAutoFire(false)
        end
        mySelf:endShoot()
        FishGI.gameScene.skillManager:clearBuffType(3);

        --清除子弹缓存
        FishGMF.clearUnSureData(mySelf.playerInfo.playerId)

        local items = data.items
        local tRankListInfo = {}
        tRankListInfo.data = {}
        local tSortList = {}
        local myPlayerId = mySelf.playerInfo.playerId
        local myDir = 0
        for i,val in ipairs(items) do
            local playerId = val.playerId
            local chairdId = FishGI.gameScene.playerManager:getPlayerChairId(playerId)
            local item = {}
            table.insert( item,val.nickName )
            table.insert( item,val.score )
            --重新刷新积分排名
            FishGI.gameScene.uiMainLayer.uiGameData:setPlayerScore(val.score, chairdId)
            if playerId == FishGI.myData.playerId then 
                myDir = chairdId
            end 
            tRankListInfo.data[chairdId] = item
            tSortList[val.order] = chairdId
        end
        tRankListInfo.owner = myDir
        FishGI.gameScene.uiMainLayer.uiSettlement:resetRankList(tRankListInfo, tSortList)
        FishGI.gameScene.uiMainLayer.uiSettlement:showLayer()
        FishGI.gameScene.uiMainLayer.uiSettlement:setTimeout()

    elseif reason == 3 then         --4：超時未開始
        FishGF.doMyLeaveGame(6)
    else
        FishGF.doMyLeaveGame(100)
    end 

end

--发射子弹
function GameFriendNet:OnPlayerShoot(data)
    if FishGI.SERVER_STATE == 0 then
        --还没有OnGameStatus
        return;
    end

    local isCost = true     --根据子弹状态设置是否扣子弹数量

    for key, val in pairs(data.effects) do
        if val == FishCD.FRIEND_PROP_01 then
            isCost = false;
            break;
        end
    end
    
    local skillDataTab = {}
    skillDataTab.playerId = data.playerId;
    skillDataTab.effects = data.effects;
    local event = cc.EventCustom:new("OnPlayerShoot")
    event._usedata = skillDataTab
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    --自己确认发射成功，真的减钱
    if data.playerId == FishGI.gameScene.playerManager.selfIndex then
        local dataTab = {};
        dataTab.upDataType = "onPlayerShoot"
        dataTab.createType = "friend"
        dataTab.isCost = isCost
        dataTab.playerId = data.playerId;
        dataTab.bulletRate = data.gunRate
        dataTab.fireType = 2
        FishGMF.pushRefreshData(dataTab)
        return;
    end   
  
    data.angle = FishGF.getCustomAngle(data.angle)
    --添加子弹翻转
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    if FishGI.isPlayerFlip then
        local winSize = cc.Director:getInstance():getWinSize();
        local cfg_ds= CC_DESIGN_RESOLUTION
        data.pointX = cfg_ds.width-data.pointX;
        data.pointY = cfg_ds.height-data.pointY;
    end
    --计算子弹发射点的位置
    data.pos = {}
    data.pos.x= data.pointX*scaleX_
    data.pos.y= data.pointY*scaleY_
    data.frameId = 0;

    --其他玩家子弹的生成
    --其他玩家炮塔转动
    FishGI.eventDispatcher:dispatch("OtherPlayerShoot", data);
    
    local dataTab = {};
    dataTab.upDataType = "onPlayerShoot"
    dataTab.createType = "friend"
    dataTab.isCost = isCost
    dataTab.pos = cc.p(data.pos.x, data.pos.y);
    dataTab.degree = data.angle - 90
    local chairId = FishGI.gameScene.playerManager:getPlayerChairId(data.playerId)
    if chairId == nil then
        print("*********************OnPlayerShoot chairId nil!!");
        return
    end
    if chairId >=3 then
        dataTab.degree = dataTab.degree +180
    end
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(data.playerId)
    dataTab.pos = player.cannon:getLauncherPos()

    dataTab.playerId = data.playerId;
    dataTab.lifeTime = 0
    dataTab.bulletId = data.bulletId
    dataTab.timelineId = data.timelineId
    dataTab.fishArrayId = data.fishArrayId  
    dataTab.bulletRate = data.gunRate
    dataTab.fireType = 0
    FishGMF.pushRefreshData(dataTab)


end

--击中结果
function GameFriendNet:OnHit(data) 
    if FishGI.SERVER_STATE == 0 then
        --还没有OnGameStatus
        return;
    end

    local dataValue = data;
    dataValue.chairId = FishGI.gameScene.playerManager:getPlayerChairId(data.playerId);
    if table.maxn(data.killedFishes) == 0 then
        dataValue.killedFishes = nil;
    end

    dataValue.upDataType = "onHit"
    dataValue.hitType = "friendHit"
    local effects = dataValue.effects
    if table.maxn(effects) == 0  then effects = nil end
    dataValue.effects = effects
    local dropProps = dataValue.dropProps
    if table.maxn(dropProps) == 0  then
         dropProps = nil 
    else 
        for k,v in pairs(dropProps) do
            dropProps[k].propId = v.propId + FishCD.FRIEND_INDEX
        end
    end
    dataValue.dropProps = dropProps

    if table.maxn(data.dropSeniorProps) == 0 then
        dataValue.dropSeniorProps = nil;
    end

    FishGMF.pushRefreshData(dataValue)
  
end 

--收取宝箱
function GameFriendNet:OnSendReward(data) 
    if FishGI.SERVER_STATE == 0 then
        --还没有OnGameStatus
        return;
    end
    local playerId = data.playerId
    --转换为本地的道具id
    if data.props == nil then 
        data.props = {}
    end 
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(playerId)
    local endPos = player:getCannonPos()
    local props = data.props
    for k,val in pairs(props) do
        local propId = val.propId + FishCD.FRIEND_INDEX
        props[k].propId = propId
        FishGF.print("-----OnSendReward---------propId="..propId)
        if playerId == FishGI.gameScene.playerManager.selfIndex then
            FishGMF.addTrueAndFlyProp(playerId,propId,val.propCount,false)
            FishGMF.setAddFlyProp(playerId,propId,val.propCount,false)
        else
            FishGMF.addTrueAndFlyProp(playerId,propId,val.propCount,true)
        end
    end

    local seniorProps = data.seniorProps
    if seniorProps == nil then
        seniorProps = {}
    end
    for k,val in pairs(seniorProps) do
        val.propCount = 1
        if playerId == FishGI.gameScene.playerManager.selfIndex then
            FishGMF.refreshSeniorPropData(playerId,val,8,0)
        else
            FishGMF.refreshSeniorPropData(playerId,val,1,0)
        end
        table.insert( props,val)
    end


    if playerId ~= FishGI.gameScene.playerManager.selfIndex then
        return
    end

    --进度条
    if playerId == FishGI.gameScene.playerManager.selfIndex then
        FishGI.gameScene.uiMainLayer.uiBox:setLevelData(data.level, props)
    end

end 

--炮倍变化消息
function GameFriendNet:OnPlayerGunRateChange(data) 
    FishGI.eventDispatcher:dispatch("GunRateChange", data);
end 

--表情
function GameFriendNet:onEmotionIcon(data)
    print("---onEmotion---")
    FishGI.eventDispatcher:dispatch("onEmotionIcon", data);
end

--魔法道具
function GameFriendNet:onMagicprop(data)
    print("---onMagicprop")
    FishGI.eventDispatcher:dispatch("onMagicprop", data);
end

--炮类型改变
function GameFriendNet:OnGunTpyeChange(data)
    print("--------OnGunTpyeChange-")
    FishGI.eventDispatcher:dispatch("changePlayerGun", data);
end

--获取玩家数据
function GameFriendNet:OnFriendGetPlayerInfo(data)
    print("--------OnFriendGetPlayerInfo-")
    FishGI.eventDispatcher:dispatch("OnGetPlayerInfo", data);
end

function GameFriendNet:OnUsePropSkill(data)
    local event = cc.EventCustom:new("UseFriendSKillResponse")
    event._usedata = data
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function GameFriendNet:OnUpdateSkillEffect(data)
    local event = cc.EventCustom:new("UpdateSkillResponse")
    event._usedata = data
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

--玩家踢人
function GameFriendNet:OnFriendKickOut(data)
    local errorCode = data.errorCode
    local playerId = data.playerId
    data.leaveType = 2
    if errorCode == 0 then
        FishGI.gameScene:onLeaveGame(data)
    elseif errorCode == 1 then
        FishGF.showToast(FishGF.getChByIndex(800000304))
    elseif errorCode == 2 then
        FishGF.showToast(FishGF.getChByIndex(800000302))
    elseif errorCode == 3 then
        FishGF.showToast(FishGF.getChByIndex(800000305))
    else
        FishGF.showToast("操作失败,错误码："..errorCode)
    end
end

--子弹转换目标
function GameFriendNet:OnBulletTargetChange(data)
    local event = cc.EventCustom:new("BulletTargetChange")
    event._userdata = data
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end



------------------------------------------------------------------------------------------------
-------------------------------------------向服务器发送消息-------------------------------------
------------------------------------------------------------------------------------------------
function GameFriendNet:sendJMsg( name, data )
    --设置发送消息的标识 判断断线的时候用
    
        local encoded, len = jmsg.encodeBinary(proto, name, data)
        local msg = CLuaMsgHeader.New()
        msg.id = self.msg.HEAD.MSG_C2S_JMSG
    --    print("encoded len="..len)
        msg:WriteData(encoded, len)

        self:SendData(msg)
        jmsg.freeBinary(encoded)
end

--[[
客户端准备就绪
]]
function  GameFriendNet:sendClientGameLoadedMessage()
    self.isWaitLoaded = true
    self:sendJMsg("MSGC2SFriendGameLoaded", {})
end

--准备消息
function  GameFriendNet:sendClientReadyMessage(data)
    FishGF.waitNetManager(true,nil,"MSGC2SFriendReady")
    self:sendJMsg("MSGC2SFriendReady", data)
end

--开始游戏
function  GameFriendNet:sendClientStartGameMessage()
    FishGF.waitNetManager(true,nil,"StartGame")
    self:sendJMsg("MSGC2SFriendStartGame", {})
end

--[[
发送心跳消息
frameCount:客户端帧号
]]
function GameFriendNet:sendHeartBeat(localFrameCount)
    local data = {
        frameCount = localFrameCount
    }
    self.isSend = true;
    self:sendJMsg("MSGC2SHeartBeat", data)
end

--离开朋友场游戏
function GameFriendNet:sendFriendLeaveGame()
    self:sendJMsg("MSGC2SFriendLeaveGame", {})
end

--锁定变换目标
function GameFriendNet:sendBulletTargetChange(data)
    FishGF.print("-0-sendBulletTargetChange----")
    if data == nil then
        return
    end
    self:sendJMsg("MSGC2SBulletTargetChange", data)
end

--解散房间，只有房主才能调用
function GameFriendNet:sendFriendCloseGame()
    self:sendJMsg("MSGC2SFriendCloseGame", {})
end

--[[
发射发送子弹事件
bulletId 子弹id
frameId 该时刻的帧号
angle 子弹的方向
gunRate 炮倍
--]]
function GameFriendNet:sendBullet(bulletId, frameId, angle, gunRate,timelineId,fishArrayId,posx, posy)

    local event = cc.EventCustom:new("PlayerShoot")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    angle = FishGF.getStandardAngle(angle)
    local scaleX_,scaleY_,scaleMin_  = FishGF.getCurScale()
    posx = posx/scaleX_
    posy = posy/scaleY_
    if FishGI.isPlayerFlip then
        local winSize = cc.Director:getInstance():getWinSize();
        local cfg_ds= CC_DESIGN_RESOLUTION
        posx = cfg_ds.width-posx;
        posy = cfg_ds.height-posy;
    end
    local data = {}
    data.bulletId = bulletId;
    --data.frameId = frameId;
    data.angle = angle;
    data.gunRate = gunRate;
    data.timelineId = timelineId;
    data.fishArrayId = fishArrayId;
    data.pointX = posx;
    data.pointY = posy;
    data.effects = FishGI.gameScene.skillManager:getPlayerBuffId(FishGI.gameScene.playerManager.selfIndex);
    self:sendJMsg("MSGC2SFriendPlayerShoot", data)
end

--[[
发送碰撞消息
]]
function GameFriendNet:sendHit(bulletId, frameId, fishes)
    local data = {
        bulletId = bulletId,
        frameId = frameId,
        killedFishes = fishes,
    }
  self:sendJMsg("MSGC2SFriendPlayerHit", data)
end

--显示表示
function GameFriendNet:sendEmotionIcon(emoticonId)
    print("--sendEmotion--")
    local data = {
        emoticonId = emoticonId,
    }

    self:sendJMsg("MSGC2SEmoticon", data)
end

--魔法道具
function GameFriendNet:sendMagicProp(magicpropId, toPlayerID)
    print("--sendMagicProp--")
    local data = {
        magicpropId = magicpropId,
        toPlayerID = toPlayerID,
    }

    self:sendJMsg("MSGC2SMagicprop", data)
end

--发送换炮类型
function GameFriendNet:sendNewGunType(newGunType)
    print("--sendNewGunType-")
    local data = {
        newGunType = newGunType,
    }
  self:sendJMsg("MSGC2SGunTpyeChange", data)
end

--刷新玩家数据
function GameFriendNet:sendFriendGetPlayerInfo(playerId)
    print("--FriendGetPlayerInfo--")
    local data = {
        playerId = playerId,
    }
    self:sendJMsg("MSGC2SFriendGetPlayerInfo", data)
end

--使用道具技能
function GameFriendNet:sendUsePropSkill(propId, playerId)
    print("--sendUsePropSkill--")
    local data = {
        targetPlayerId = playerId,
        propId = propId,
    }
    self:sendJMsg("MSGC2SFriendUseProp", data)
end

--房主踢人
function GameFriendNet:sendFriendKickOut(playerId)
    print("--sendFriendKickOut--")
    local data = {
        playerId = playerId,
    }
    self:sendJMsg("MSGC2SFriendKickOut", data)
end

--充值成功发送消息
function GameFriendNet:sendReChargeSucceed()
    print("--sendReChargeSucceed--")
    local data = {}
    self:sendJMsg("MSCC2SRechargeSuccess", data)
end

--发送vip每日领取
function GameFriendNet:sendGetVipDailyReward(tabVal)
    self:sendJMsg("MSGC2SGetVipDailyReward", tabVal)
end

--进入充值界面发送消息使不会被踢
function GameFriendNet:sendGotoCharge()
    print("--sendGotoCharge--")
end

--退出充值界面发送消息
function GameFriendNet:sendBackFromCharge()
    print("--sendBackFromCharge--")
end

GameFriendNet.new();


