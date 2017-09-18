cc.exports.FishGMF = {}

--------------------------------------------------------------------------
-----------------------------c++发送消息到lua--------------------------------
--------------------------------------------------------------------------
function FishGMF.CppToLua(valTab)
    --print("---------------------valTab.data.typeName =  "..valTab.type)
    local typeName = valTab.type
    local dataTab = valTab.data;

    if typeName == "bossComming" then
        FishGF.print("---bossComming----")
        FishGI.GameEffect:bossComming(valTab.data)
    elseif typeName == "bossLeave" then
        FishGF.print("---bossLeave----")
        FishGI.GameEffect:bossLeave(valTab.data)
    elseif typeName == "fishGroupCome" then
        FishGF.print("---fishGroupCome----")
    elseif typeName == "sendNetCollision" then
        local bulletId = dataTab.bulletId;
        local bulletPos = dataTab.bulletPos;
        local frame = dataTab.frame;
        local collisionTab = dataTab.collisionFishTab;
        local effectedFishTab = dataTab.effectedFishTab;
        FishGI.gameScene.net:sendHit(bulletId, frame,collisionTab, effectedFishTab);
    elseif typeName == "otherBulletCollision" then
    elseif typeName == "playEffect" then
        local music_res = dataTab.music_res;
        FishGI.AudioControl:playEffect("sound/"..music_res)
    elseif typeName == "addLoading" then
    elseif typeName == "dropThings" then  
          FishGI.GameEffect:dropThings( valTab.data)
    elseif typeName == "gainCoin" then  
          FishGI.GameEffect:gainCoin( valTab.data)
    elseif typeName == "thunderEffect" then
        FishGI.GameEffect:thunderAnimation(valTab.data);
    elseif typeName == "bombEffect" then
        FishGI.GameEffect:bombEffect(cc.p(dataTab.posX, dataTab.posY));
    elseif typeName == "shakeBackground" then
        FishGI.gameScene:shakeBackground(1/15, 20);
    elseif typeName == "propMegaWin" then
        FishGI.GameEffect:propMegaWin(dataTab, "sound/lvup_01.mp3");
    elseif typeName == "propWindfall" then
        FishGI.GameEffect:propWindfall(dataTab, "sound/lvup_01.mp3");
    elseif typeName == "OnPlayerBankup" then
        FishGI.eventDispatcher:dispatch("OnPlayerBankup", dataTab);
    elseif typeName == "updataGemUI" then
        FishGI.eventDispatcher:dispatch("myGunUpData", dataTab);
    elseif typeName == "updataPropUI" then  --刷新道具數量
        local mGameState = dataTab.mGameState
        if mGameState == 3 then
            local playerId = dataTab.playerId
            if playerId == FishGI.myData.playerId then
                FishGI.eventDispatcher:dispatch("updataPropUI", dataTab);
                FishGI.eventDispatcher:dispatch("propCountChange", dataTab);
            end
        elseif mGameState == 2 then
            local playerId = dataTab.playerId
            local propId = dataTab.propId
            local propCount = dataTab.propCount
            local realCount = dataTab.realCount
            local propItemId = dataTab.propItemId
            local seniorData = dataTab.seniorData
            --print("--2---typeName--propId="..propId.."---propCount="..propCount)
            if propId == 1 then
                if realCount == 0 then
                    FishGI.hallScene.net.roommanager:sendAlmInfo();
                else
                    FishGI.hallScene.view:initAlm()
                end
            end
            FishGI.hallScene:upDataPropViewData(playerId,propId,propCount,propItemId,seniorData)
        end

    elseif typeName == "gunRateRevert" then  --炮倍回复
--        print("--------typeName--gunRateRevert-------------------gunRate="..dataTab.gunRate)
        local gunRate = dataTab.gunRate
        local playerId = dataTab.playerId
        local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(playerId)
        player.cannon:setMultiple(gunRate)
        FishGI.gameScene.net:sendNewGunRate(gunRate)
    elseif typeName == "enableUseSkill" then
        FishGI.isFishGroupCome = false

    elseif typeName == "resetRankList" then
        local playerId = dataTab.playerId
        local score = dataTab.score
        local chairId = FishGI.gameScene.playerManager:getPlayerChairId(playerId)
        --print("--------typeName--resetRankList-------------------playerId="..playerId.."--------score="..score.."----------chairId="..chairId)
        
        FishGI.gameScene.uiMainLayer.uiGameData:setPlayerScore(score, chairId)
        if playerId == FishGI.myData.playerId then 
            FishGI.gameScene.uiMainLayer.uiBox:setScore(score)
        end 
    elseif typeName == "playBossRateChange" then
        FishGI.GameEffect:bossRateChange( dataTab)
    end

end

--------------------------------------------------------------------------
-----------------------------延时发送到c++--------------------------------
--------------------------------------------------------------------------

--更新列表数据到c++
function FishGMF.updateInline()
    if table.maxn(FishGI.refreshDataList)  > 0 then
       local  data = {};
       data.funName = "updateInline"
       data.data = FishGI.refreshDataList
       LuaCppAdapter:getInstance():luaUseCppFun(data);
       FishGI.refreshDataList = {}
    end
end

--插入数据
function FishGMF.pushRefreshData(data)
    table.insert(FishGI.refreshDataList,data)
    if FishGI.GAME_STATE == 2 then
        FishGMF.updateInline()
    end 
end

--清除数据
function FishGMF.clearRefreshData()
    FishGI.refreshDataList = {}
end

--更新数据   --玩家id    道具id   总的真实数   ，是否马上显示   飞行数量   延时时间
function FishGMF.upDataByPropId(playerId,propId,propCount,isShow,flyingCount,delayTime)
    local data = {};
    data.upDataType = "upDataByPropId"
    data.playerId = playerId
    data.propId = propId
    data.propCount = propCount

    if isShow == nil then
        isShow = true
    end
    if flyingCount == nil then
        flyingCount = 0
    end
    if delayTime == nil then
        delayTime = 0
    end
    data.isShow = isShow
	data.flyingCount = flyingCount
	data.delayTime = delayTime

    FishGMF.pushRefreshData(data)

end

--增加真实数据   --玩家id    道具id   增加的真实数   ，是否马上显示   飞行数量   延时时间
function FishGMF.addTrueAndFlyProp(playerId,propId,addCount,isShow,flyingCount,delayTime)
    local data = {};
    data.upDataType = "addTrueAndFlyProp"
    data.playerId = playerId
    data.propId = propId
    data.propCount = addCount

    if isShow == nil then
        isShow = true
    end
    if flyingCount == nil then
        flyingCount = 0
    end
    if delayTime == nil then
        delayTime = 0
    end

    data.isShow = isShow
	data.flyingCount = flyingCount
	data.delayTime = delayTime

    FishGMF.pushRefreshData(data)

end

--设置已确定获得的数值的缓存
function FishGMF.setAddFlyProp(playerId,propId,propCount,isSure)
    local data = {};
    data.upDataType = "setAddFlyProp"
    data.playerId = playerId
    data.propId = propId
    data.propCount = propCount
    data.isSure = isSure
    FishGMF.pushRefreshData(data)

end

--设置未确定使用的数值的缓存
function FishGMF.isSurePropData(playerId,propId,propCount,isSure)
    local data = {};
    data.upDataType = "isSurePropData"
    data.playerId = playerId
    data.propId = propId
    data.propCount = propCount
    data.isSure = isSure
    FishGMF.pushRefreshData(data)

end

--普通到道具的操作删除,使用  //useType 
--1.直接增加或者直接删除（updateDelayTime为延时显示时间，已包含缓存，propCount的正负表示加减） 
--2.使用,假扣，加入缓存
--3.使用, 删除缓存 
--4.使用,真扣，删除缓存
--5.收到道具增加真实数值，并加入缓存，等待lua清除缓存
--6.收到道具，删除缓存
--7.刷新道具真实数量，不显示
--8.刷新道具真实数量（updateDelayTime为延时显示时间）
function FishGMF.refreshNormalPropData(playerId,propId,propCount,useType,updateDelayTime)
    local data = {};
    data.upDataType = "refreshNormalPropData"
    data.playerId = playerId
    local propData = {}
    propData.propId = propId
    propData.propCount = propCount
    data.propData = propData
    data.useType = useType
    if updateDelayTime == nil then
        updateDelayTime = 0
    end
    data.updateDelayTime = updateDelayTime
    FishGMF.pushRefreshData(data)
end

--高级到道具的操作删除,使用  //useType 1.直接添加 2.延时增加  3.直接删除,直接使用  4.延时删除  5.使用,假扣，加入缓存  6.使用, 删除缓存 7.使用,真扣，删除缓存  8.收到道具，并加入缓存，等待lua清除缓存
function FishGMF.refreshSeniorPropData(playerId,propData,useType,updateDelayTime)
    local data = {};
    data.upDataType = "refreshSeniorPropData"
    data.playerId = playerId
    data.propId = propData.propId
    data.useType = useType
    if updateDelayTime == nil then
        updateDelayTime = 0
    end
    data.updateDelayTime = updateDelayTime    
    data.propData = propData    
    FishGMF.pushRefreshData(data)
end

--清除高级道具
function FishGMF.clearAllSeniorProp(playerId,clearType)
    local data = {};
    data.upDataType = "clearAllSeniorProp"
    data.playerId = playerId
    data.clearType = clearType
    FishGMF.pushRefreshData(data)
end

--申请救济金结果
function FishGMF.ApplyAlmResult(playerId,propCount)
    local data = {};
    data.upDataType = "ApplyAlmResult"
    data.playerId = playerId
    data.newFishIcon = propCount
    data.coinNum = 2
    data.chairId = FishGI.gameScene.playerManager:getPlayerChairId(playerId)
    FishGMF.pushRefreshData(data)
end

--升炮结果
function FishGMF.CannonUpgrade(playerId,newFishIcon,newCrystal)
    local data = {};
    data.upDataType = "CannonUpgrade"
    data.playerId = playerId
    data.newFishIcon = newFishIcon
    data.newCrystal = newCrystal
    data.coinNum = 6
    data.chairId = FishGI.gameScene.playerManager:getPlayerChairId(playerId)
    FishGMF.pushRefreshData(data)
end

--清楚未确定的缓存
function FishGMF.clearUnSureData(playerId)
    local data = {};
    data.upDataType = "clearUnSureData"
    data.playerId = playerId
    FishGMF.pushRefreshData(data)
end

--变倍率boss转盘转完后回调c++播放金币动画
function FishGMF.bossRateChangeEnd(cppData)
    local data = {};
    data = cppData
    data.upDataType = "bossRateChangeEnd"
    FishGMF.pushRefreshData(data)
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-----------------------------即时发送到c++--------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------

--根据表名得到表数据
function FishGMF.getTableByName(tableName)
    local dataTab = {}
    dataTab.funName = "getTableByName"
    dataTab.name = tableName
    local back = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
    if back == nil then
        back = {}
        back.result = {}
    end
    return back.result
end

--设置我的playerId
function FishGMF.setMyPlayerId(playerId)
    local dataTab = {}
    dataTab.funName = "setMyPlayerId"
    dataTab.playerId = playerId
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

--切換炮倍和设置最高炮倍
function FishGMF.changeGunRate(playerId,newCannonRate,maxGunRate)
    if playerId == nil then
        playerId = FishGI.gameScene.playerManager.selfIndex
    end
    FishGF.print("-----------changeGunRate--------------newCannonRate="..newCannonRate)
    local dataTab = {}
    dataTab.funName = "changeGunRate"
    dataTab.playerId = playerId
    dataTab.maxGunRate = maxGunRate
    dataTab.currentGunRate = newCannonRate
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)

end

--设置鱼的状态
function FishGMF.setFishState(state)
    local data =  {}
    data.funName = "setFishState"
    data.state = state
    LuaCppAdapter:getInstance():luaUseCppFun(data);
end

--通过type得到想要的炮倍
function FishGMF.getNextRateBtType(type)
    local myData = FishGI.gameScene.playerManager:getMyData()
    local dataTab = {}
    dataTab.funName = "getGunRate"
    dataTab.playerId = FishGI.gameScene.playerManager.selfIndex
    dataTab.type = type
    dataTab.maxGunRate = myData.playerInfo.maxGunRate
    dataTab.currentGunRate = myData.playerInfo.currentGunRate
    local gunData = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
    local nextRate = gunData["Rate"];
    return nextRate,gunData
end

--创建我自己的子弹，并返回结果
function FishGMF.myCreateBullet(data)
    local dataTab = {}
    dataTab.funName = "myCreateBullet"
    dataTab.data = data
    local data = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)

    return data
end

--得到玩家所有数据
function FishGMF.getPlayerData(playerId)
    local data = {}
    data.funName = "getPlayerData"
    data.playerId = playerId
    local playerData = LuaCppAdapter:getInstance():luaUseCppFun(data)

    return playerData
end

--得到玩家道具数量
function FishGMF.getPlayerPropData(playerId,propId,propItemId)
    local data = {}
    data.funName = "getPlayerPropData"
    data.playerId = playerId
    data.propId = propId
    if propItemId == nil then
        propItemId = 0
    end
    data.propItemId = propItemId
    local propData = LuaCppAdapter:getInstance():luaUseCppFun(data)

    return propData
end

--设置玩家破产
function FishGMF.setIsBankup(playerId,isBankup)
    local dataTab = {}
    dataTab.funName = "setIsBankup"
    dataTab.playerId = playerId
    dataTab.isBankup = isBankup
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

--设置或者得到玩家数据
function FishGMF.getAndSetPlayerData(playerId,isGet,dataName,val)
    local dataTab = {}
    dataTab.funName = "getAndSetPlayerData"
    dataTab.playerId = playerId
    dataTab.isGet = isGet
    dataTab.dataName = dataName
    dataTab.val = val
    local propData = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)

    return propData
end

--设置玩家换炮换子弹 
function FishGMF.setGunChange(playerId,gunType)
    local dataTab = {}
    dataTab.funName = "setGunChange"
    dataTab.id = tostring(gunType)
    dataTab.playerId = playerId
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)

end

--设置玩家换炮换子弹 
function FishGMF.getGunChangeData(id)
    local dataTab = {}
    dataTab.funName = "getGunChangeData"
    dataTab.id = tostring(id)
    local gunData = LuaCppAdapter:getInstance():luaUseCppFun(dataTab);   

    return gunData
end

--设置当前锻造数据
function FishGMF.setForgedChange(id)
    local dataTab = {}
    dataTab.funName = "setForgedChange"
    dataTab.id = tostring(id)
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

--获取当前锻造数据
function FishGMF.getForgedChangeData(id, endId)
    local dataTab = {}
    dataTab.funName = "getForgedChangeData"
    dataTab.id = tostring(id)
    if endId ~= nil then
        dataTab.endId = tostring(endId)
    end
    local gunData = LuaCppAdapter:getInstance():luaUseCppFun(dataTab);
    return gunData
end

--设置玩家当前所在状态
function FishGMF.setGameState(gameState)
    FishGI.GAME_STATE = gameState
    local dataTab = {}
    dataTab.funName = "setGameState"
    dataTab.gameState = gameState
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
    
end

--设置玩家当前所在类型   0.普通场，   1.朋友场    --一定要先设置，不然有些不会生效
function FishGMF.setGameType(gameType)
    local dataTab = {}
    dataTab.funName = "setGameType"
    dataTab.gameType = gameType
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
    
end

--设置c++方面的目标鱼
function FishGMF.setCppAimFish(playerId, timelineId,fishArrayId)
    local dataTab = {}
    dataTab.funName = "setAimFish"
    dataTab.playerId = playerId
    dataTab.timelineId = timelineId
    dataTab.fishArrayId = fishArrayId
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

--播放c++方面的特效   1.爆炸   2.爆金币   3.爆光圈   4.背景震动
function FishGMF.playCppEffect(playType, delayTime,posX,posY)
    local dataTab = {}
    dataTab.funName = "playCppEffect"
    dataTab.playType = playType
    dataTab.delayTime = delayTime
    dataTab.posX = posX
    dataTab.posY = posY
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end

--播放c++方面的金币特效
function FishGMF.showGainCoinEffect(playerId, chairId,propId,propCount,dropCount,firstPosX,firstPosY,EndPosX,EndPosY,isShowAddCount)
    local dataTab = {}
    dataTab.funName = "showGainCoinEffect"
    dataTab.playerId = playerId
    dataTab.chairId = chairId
    dataTab.propId = propId
    dataTab.propCount = propCount
    dataTab.dropCount = dropCount
    dataTab.firstPosX = firstPosX
    dataTab.firstPosY = firstPosY
    dataTab.EndPosX = EndPosX
    dataTab.EndPosY = EndPosY
    dataTab.isShowAddCount = isShowAddCount
    LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
end



      










