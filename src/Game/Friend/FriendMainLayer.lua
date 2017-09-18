local FriendMainLayer = class("FriendMainLayer", cc.load("mvc").ViewBase)

FriendMainLayer.AUTO_RESOLUTION   = true
FriendMainLayer.RESOURCE_FILENAME = "ui/battle/friend/uifriendlayer"
FriendMainLayer.RESOURCE_BINDING  = {
}

function FriendMainLayer:onCreate( ... )
    self:init()
    self:initView()
end

function FriendMainLayer:init() 
    self:openTouchEventListener()
    FishGI.eventDispatcher:registerCustomListener("updataPropUI", self, function(valTab) self:updataPropUI(valTab) end);
end

function FriendMainLayer:initView()
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()

    --设置背景
    local keyID = tostring(FishGI.curGameRoomID + 910000000)
    local bgName = tostring(FishGI.GameConfig:getConfigData("room", keyID, "bg_img"));
    self.bg = cc.Sprite:create("battle/battleUI/"..bgName)
    self.bg:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self.bg:setScale(1.03);
    self:addChild(self.bg)

    --播放粒子特效文件1  
    local emitter1 = FishGI.GameEffect.createBubble(2) 
    emitter1:setPosition(cc.p(195*self.scaleX_,160*self.scaleY_))
    self:addChild(emitter1,2)  

    --播放粒子特效文件2  
    local emitter2 = FishGI.GameEffect.createBubble(2) 
    emitter2:setPosition(cc.p(1147*self.scaleX_,212*self.scaleY_))
    self:addChild(emitter2,2)

    --水波纹
    local spr_wave_1 = cc.Sprite:create("battle/effect/wave_1_00.png")
    spr_wave_1:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(spr_wave_1,1)
    spr_wave_1:setScale(2)
    spr_wave_1:setOpacity(0)
    local time = 0.9
    local seq = cc.Sequence:create(cc.FadeTo:create(time,255),cc.FadeTo:create(time,0))
    spr_wave_1:runAction(cc.RepeatForever:create(seq))

    local spr_wave_2 = cc.Sprite:create("battle/effect/wave_1_01.png")
    spr_wave_2:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(spr_wave_2,1)
    spr_wave_2:setScale(2)
    spr_wave_2:setOpacity(255)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ( ... )
        local seq2 = cc.Sequence:create(cc.FadeTo:create(time,255),cc.FadeTo:create(time,0))
        spr_wave_2:runAction(cc.RepeatForever:create(seq2))
    end)))

    if FishGI.isOpenDebug then
        --秘籍
        self:secretUseLayer(self);
    end

    --道具列表
    self.uiPropList = require("Game/Friend/FriendPropList").create()
    self.uiPropList:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,0))
    self:addChild(self.uiPropList,FishCD.ORDER_GAME_player)
    self.uiPropList:setScale(self.scaleMin_)
    self.uiPropList:setVisible(false)

    --游戏数据
    self.uiGameData = require("Game/Friend/FriendGameData").create()
    self.uiGameData:setPosition(cc.p(0,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiGameData,FishCD.ORDER_GAME_player)
    self.uiGameData:setScale(self.scaleMin_)
    local function callBackTimeout( )
        print("callBackTimeout")
    end
    self.uiGameData:setTimeoutCallBack(callBackTimeout)

    --宝箱
    self.uiBox = require("Game/Friend/FriendBox").create()
    self.uiBox:setPosition(cc.p(cc.Director:getInstance():getWinSize().width*0.92,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiBox,FishCD.ORDER_GAME_player)
    self.uiBox:setScale(self.scaleMin_)

    --道具选择
    self.uiSelectProp = require("Game/Friend/FriendSelectProp").create()
    self.uiSelectProp:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiSelectProp,FishCD.ORDER_LAYER_TRUE)
    self.uiSelectProp:setScale(self.scaleMin_)
    self.uiSelectProp:setVisible(false)

    --邀请好友与开始游戏
    self.uiStartGame = require("Game/Friend/FriendStartGame").create()
    self.uiStartGame:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiStartGame,FishCD.ORDER_LAYER_TRUE)
    self.uiStartGame:setScale(self.scaleMin_)
    self.uiStartGame:setVisible(false)

    --开始游戏动画
    self.uiStartAni = require("Game/Friend/FriendStartAni").create()
    self.uiStartAni:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiStartAni,FishCD.ORDER_LAYER_TRUE)
    self.uiStartAni:setVisible(false)

    --结算
    self.uiSettlement = require("Game/Friend/FriendSettlement").create()
    self.uiSettlement:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiSettlement,FishCD.ORDER_LAYER_TRUE)
    self.uiSettlement:setScale(self.scaleMin_)
    self.uiSettlement:setVisible(false)

    --玩家信息层
    self.uiPlayerInfoLayer = require("Game/Friend/FriendPlayerInfoLayer").create()
    self.uiPlayerInfoLayer:setPosition(cc.p(0, 0))
    self:addChild(self.uiPlayerInfoLayer,FishCD.ORDER_LAYER_TRUE)
    self.uiPlayerInfoLayer:setVisible(false)

    --右边按键面板
    self.uiSetButton = require("Game/SetButton").create()
    self.uiSetButton:setPosition(cc.p(cc.Director:getInstance():getWinSize().width,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiSetButton,FishCD.ORDER_SCENE_UI)
    self.uiSetButton:setScale(self.scaleMin_)

    --鱼表
    self.uiFishForm = require("Game/FishForm").create()
    self.uiFishForm:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiFishForm,FishCD.ORDER_LAYER_TRUE+2)
    self.uiFishForm:setScale(self.scaleMin_)
    self.uiFishForm:initFishForm(FishGI.curGameRoomID)
    self.uiFishForm:setVisible(false)
    FishGI.gameScene.uiFishForm = self.uiFishForm

    --声音设置
    self.uiSoundSet = require("AudioManager/SoundSet").create()
    self.uiSoundSet:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiSoundSet,FishCD.ORDER_LAYER_TRUE)
    self.uiSoundSet:setScale(self.scaleMin_)
    self.uiSoundSet:setVisible(false)
    FishGI.gameScene.uiSoundSet = self.uiSoundSet

    --换炮层
    self.uiSelectCannon = require("Game/SelectCannon/SelectCannon").create()
    self.uiSelectCannon:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiSelectCannon,FishCD.ORDER_LAYER_TRUE)
    self.uiSelectCannon:setScale(self.scaleMin_)
    self.uiSelectCannon:setVisible(false)
    FishGI.gameScene.uiSelectCannon = self.uiSelectCannon

    --商店
    self.uiShopLayer = require("Shop/Shop").create()
    self.uiShopLayer:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiShopLayer,FishCD.ORDER_LAYER_TRUE)
    self.uiShopLayer:setScale(self.scaleMin_)
    self.uiShopLayer:setVisible(false)   
    FishGI.gameScene.uiShopLayer = self.uiShopLayer

    --VIP特权
    self.uiVipRight = require("VipRight/VipRight").create()
    self.uiVipRight:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiVipRight,FishCD.ORDER_LAYER_TRUE)
    self.uiVipRight:setScale(self.scaleMin_)
    self.uiVipRight:setVisible(false)
    FishGI.gameScene.uiVipRight = self.uiVipRight

    if not FishGI.isGetMonthCard then
        --月卡
        self.uiMonthcard = require("hall/Monthcard/Monthcard").create()
        self.uiMonthcard:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
        self:addChild(self.uiMonthcard,FishCD.ORDER_LAYER_TRUE)
        self.uiMonthcard:setScale(self.scaleMin_)
        self.uiMonthcard:setVisible(false)
        FishGI.gameScene.uiMonthcard = self.uiMonthcard
    end 

    self.uiGameData:updateGameStatus(false)
end

function FriendMainLayer:onClickSecret( sender )
    self.img_input_bg:setVisible(true)
end

function FriendMainLayer:onClickSecretClose( sender )
    self.img_input_bg:setVisible(false)
end

function FriendMainLayer:onClickSecretAdd( sender )
    local num = tonumber(self.tf_secret_number:getString());
    local id = tonumber(self.tf_secret_id:getString());
    local data = {}
    data.newProps = {}
    local prop = {}
    prop.propId = id;
    prop.propCount = num;
    table.insert(data.newProps,prop)
    FishGI.gameScene.net:sendAddMoney(data)
    FishGI.gameScene.net:sendFriendGetPlayerInfo(FishGI.gameScene.playerManager.selfIndex)
end

function FriendMainLayer:buttonClicked(viewTag, btnTag)
    if viewTag == "FriendSelectProp" then 
        if btnTag == "Select" then 
            self.uiSelectProp:setVisible(false)
            local tPropList = {}
            tPropList.initFriendProps = {}
            tPropList.initFriendProps[1] = self.uiSelectProp.tSelectList[1]
            if self.tGameInfo.creatorPlayerId == FishGI.myData.playerId then 
                tPropList.initFriendProps[2] = self.uiSelectProp.tSelectList[2]
                self.uiPlayerInfoLayer:setVisible(true)
                self.uiPlayerInfoLayer:setOwnerIndex(FishGI.gameScene.playerManager:getPlayerChairId(FishGI.myData.playerId))
                self.uiPlayerInfoLayer:showBtns(true)
                self.uiStartGame:showLayer(true, 127)
                self.uiStartGame:setRoomOwner(true)
            end
            self.net:sendClientReadyMessage(tPropList)
            self.uiPropList:setVisible(true)
        end
    elseif viewTag == "FriendStartGame" then 
        if btnTag == "InviteFriend" then 
            print("----------------------------InviteFriend------------------------------")
            --FishGI.isEnterBg = true
            local shareInfo = FishGI.WebUserData:GetShareDataTable();
            local url = shareInfo.url
            if url == nil then
                url = "https://client-fish.weile.com/share/fish/channel_id/"..CHANNEL_ID.."/from_app/"..APP_ID.."/from_region/0"
            end
            local wechatAppId = shareInfo.id
            if wechatAppId == nil then
                wechatAppId = WX_APP_ID_LOGIN
            end
            local title = FishGF.getChByIndex(800000241)..FishGF.getChByIndex(800000218)..FishGI.FRIEND_ROOMNO
            local targetPlatform = cc.Application:getInstance():getTargetPlatform()
            if (cc.PLATFORM_OS_WINDOWS ~= targetPlatform) then
                FishGI.ShareHelper:doShareAppWebType(title,FishGF.getChByIndex(800000294),url,0,wechatAppId)
            end

        elseif btnTag == "StartGame" then 
            self.net:sendClientStartGameMessage()
        elseif btnTag == "ReadyGame" then
            self.uiPlayerInfoLayer:showBtns(false)
            self.uiStartGame:setVisible(false)
            self.uiSelectProp:showLayer(true, 127)
            self.uiSelectProp:setRoomOwner(false)
        elseif btnTag == "DissolveRoom" then 
            FishGF.playerLeaveNotive(FishGF.getChByIndex(800000253))
            --self.net:sendClientLeaveGameMessage({})
        end 
    elseif viewTag == "FriendPropItem" then 
        self.parent_:buttonClicked(viewTag, btnTag)
    elseif viewTag == "FriendSettlement" then 
        if btnTag == "Close" then 
            FishGF.doMyLeaveGame(4)
        elseif btnTag == "Share" then
            local fileName = "/sdcard/buyuShareResult.jpg"
            local targetPlatform = cc.Application:getInstance():getTargetPlatform()
            if (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
                fileName = "buyuShareResult.jpg"
            elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
                local writablePath =cc.FileUtils:getInstance():getWritablePath()
                fileName = writablePath.."buyuShareResult.jpg"
            end
            --截屏回调方法  
            local function afterCaptured(succeed, outputFile)  
                if succeed then  
                    fileName = outputFile  
                    print("------------0000-----------------------------------------------------------afterCaptured-------------fileName="..fileName)
                    local shareInfo = FishGI.WebUserData:GetShareDataTable();
                    local wechatAppId = shareInfo.id
                    if wechatAppId == nil then
                        wechatAppId = WX_APP_ID_LOGIN
                    end
                    FishGI.ShareHelper:doShareImageType(outputFile,1,wechatAppId)
                else  
                    print("Capture screen failed.")  
                end  
            end 
            cc.utils:captureScreen(afterCaptured, fileName)
        end 
    elseif viewTag == "SetButton" then 
        if btnTag == "exit" then 
            local CreatorPlayerId = FishGI.gameScene.playerManager:getCreatorPlayerId()
            local index = 0
            if FishGI.SERVER_STATE == 2 then
                FishGF.doMyLeaveGame(4)
                return
            elseif FishGI.SERVER_STATE == 0 then
                if CreatorPlayerId == FishGI.myData.playerId then
                    index = 800000253
                else
                    index = 800000069
                end
            else
               index = 800000265
            end

            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    if FishGI.SERVER_STATE == 0 and CreatorPlayerId == FishGI.myData.playerId then --解散
                        FishGI.gameScene.net:sendFriendCloseGame()
                        FishGF.doMyLeaveGame(7)
                    else 
                        FishGI.gameScene.net:sendFriendLeaveGame()
                        FishGF.doMyLeaveGame(5)
                    end 
                end
            end   
            FishGF.showExitMessage(FishGF.getChByIndex(index),callback)
        end 
    else
        self.parent_:buttonClicked(viewTag, btnTag)
    end 
end

function FriendMainLayer:onTouchBegan(touch, event)
    FishGI.gameScene.playerManager:onTouchBegan(touch, event);
    return true;
end

function FriendMainLayer:onTouchMoved(touch, event)
    FishGI.gameScene.playerManager:onTouchMoved(touch, event);
end

function FriendMainLayer:onTouchEnded(touch, event)
    FishGI.gameScene.playerManager:onTouchEnded(touch, event);
end

function FriendMainLayer:onGameLoaded(data)
    self.tGameInfo = data.roomInfo
    if self.tGameInfo.started then 
        self.uiPropList:setVisible(true)
        self.uiGameData:updateGameStatus(true)
        self.uiPlayerInfoLayer:setVisible(true)
        self.uiPlayerInfoLayer:showBtns(false)
    else 
        if self.tGameInfo.creatorPlayerId == FishGI.myData.playerId then 
            local isReady = FishGI.gameScene.playerManager:getMyData().playerInfo.ready
            if isReady then 
                self.uiPlayerInfoLayer:setVisible(true)
                self.uiPlayerInfoLayer:setOwnerIndex(FishGI.gameScene.playerManager:getPlayerChairId(FishGI.myData.playerId))
                self.uiPlayerInfoLayer:showBtns(true)
                self.uiStartGame:showLayer(true, 127)
                self.uiStartGame:setRoomOwner(true)
                self.uiPropList:setVisible(true)
            else
                self.uiSelectProp:showLayer(true, 127)
                self.uiSelectProp:setRoomOwner(true)
            end 
        else 
            self.uiPlayerInfoLayer:setVisible(true)
            self.uiPlayerInfoLayer:setOwnerIndex(FishGI.gameScene.playerManager:getPlayerChairId(FishGI.myData.playerId))
            self.uiPlayerInfoLayer:showBtns(true)
            self.uiStartGame:showLayer(true, 127)
            self.uiStartGame:setRoomOwner(false)
        end 
    end 
end

function FriendMainLayer:OnPlayerJoin(iPlayerId)
end

function FriendMainLayer:onReady(data)
    self.uiPropList:setVisible(true)
    for i, v in pairs(data.initFriendProps) do 
        self:setPropCount(v.propId, FishGMF.getPlayerPropData(FishGI.myData.playerId,v.propId+FishCD.FRIEND_INDEX).realCount)
    end 
end

function FriendMainLayer:onStartGame(data)
    self.uiPlayerInfoLayer:isOpenShowBtns(false)
    self.uiStartGame:setVisible(false)
    self.uiGameData:updateGameStatus(true)
    self.uiStartAni:showLayer(true, 127)
end

--更新道具数量
function FriendMainLayer:updataPropUI(data)
    self.uiPropList:updataPropUI(data)
end

--设置道具数量
function FriendMainLayer:setPropCount(iPropId, iCount)
    self.uiPropList:setPropCount(iPropId, iCount)
end 

--开始道具CD
function FriendMainLayer:runPropTimer(iPropId, callback)
    self.uiPropList:runPropTimer(iPropId, callback)
end

--更新道具CD
function FriendMainLayer:upDatePropTimer(iPropId, callback)
    self.uiPropList:upDatePropTimer(iPropId, callback)
end

--关闭道具CD
function FriendMainLayer:stopPropTimer(iPropId)
    self.uiPropList:stopPropTimer(iPropId)
end

--设置道具buff数据
function FriendMainLayer:setPropBuff(iPlayerId, iPropId, iCount, data)
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(iPlayerId)
    if player then
        player:setPropBuff(iPropId, iCount, data)
    end
end 

--开始火力动画
function FriendMainLayer:startFirePowerAni(iPlayerId)
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(iPlayerId)
    if player then
        player:startFirePowerAni()
    end
end

--停止火力动画
function FriendMainLayer:stopFirePowerAni(iPlayerId)
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(iPlayerId)
    if player then
        player:stopFirePowerAni()
    end
end

--获取炮台上下层动画节点
function FriendMainLayer:getAniNodeLayer(iPlayerId)
    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(iPlayerId)
    if player then
        return player:getAniNodeLayer()
    end
    return nil
end 

--游戏开始的界面处理
function FriendMainLayer:gameStartAct() 
    local delatTime = 0

    --提示是我自己
    local nodePlayerCannon = FishGI.gameScene.playerManager.playerTab[FishGI.myData.playerId]
    nodePlayerCannon:isShowPlayer(true)
    local noticeMine_word = cc.Sprite:create("battle/battleUI/bl_pic_ndwz.png")
    noticeMine_word:setPosition(cc.p(FishGF.getMyPos().x,FishGF.getMyPos().y + 180*self.scaleY_))
    self:addChild(noticeMine_word,902)
    local noticeMine_arrow = cc.Sprite:create("battle/battleUI/bl_pic_arrow.png")
    noticeMine_word:addChild(noticeMine_arrow)
    noticeMine_arrow:setPositionX(noticeMine_word:getContentSize().width/2)
    noticeMine_arrow:setPositionY(-noticeMine_word:getContentSize().height/2)
    noticeMine_word:runAction(cc.Sequence:create( 
        cc.DelayTime:create(delatTime),
        cc.MoveBy:create(0.5,cc.p(0,-10)),cc.MoveBy:create(0.5,cc.p(0,10)),
        cc.MoveBy:create(0.5,cc.p(0,-10)),cc.MoveBy:create(0.5,cc.p(0,10)),
        cc.RemoveSelf:create(true)
         ))

    local fScaleX = display.width / CC_DESIGN_RESOLUTION.width
    self:runAction(cc.Sequence:create(cc.DelayTime:create(delatTime),cc.CallFunc:create(function ( ... )
        if not self.uiSetButton.isOpen then
            self.uiSetButton:setIsOpen();
        end
    end),cc.DelayTime:create(2),cc.CallFunc:create(function ( ... )
        if self.uiSetButton.isOpen then
            self.uiSetButton:setIsOpen();
        end
    end) ))

    --获取游戏消息
    --FishGI.gameScene.net:sendClientGameLoadedMessage()

end

--秘籍面板
function FriendMainLayer:secretUseLayer(layer)
    local winSize = cc.Director:getInstance():getWinSize();
    local openSecretBt = nil;

    local function openSecretLayerFunc(pSender, eventName)
        if eventName == ccui.TouchEventType.ended then
            openSecretBt:setVisible(false);
            local secretLayer = cc.Layer:create();
            layer:addChild(secretLayer, 1999);
            local inputLayer = ccui.ImageView:create("common/layerbg/com_pic_infobg.png");
            inputLayer:setSwallowTouches(true);
            inputLayer:setScale9Enabled(true);
            inputLayer:setAnchorPoint(cc.p(0.5, 0.5))
            inputLayer:setPosition(cc.p(winSize.width*0.1, winSize.height*0.8));
            inputLayer:setContentSize(cc.size(200, 200));
            layer:addChild(inputLayer, 1888);

            local closeBt = ccui.Button:create("common/btn/com_btn_close_ex_0.png", "common/btn/com_btn_close_ex_1.png");
            closeBt:setScale9Enabled(true);
            closeBt:setContentSize(cc.size(60, 60));
            closeBt:setTitleFontSize(30);
            closeBt:setPosition(cc.p(inputLayer:getContentSize().width*0.8, inputLayer:getContentSize().height*0.78))
            closeBt:addTouchEventListener(function (pSender, eventName) if eventName == ccui.TouchEventType.ended then layer:removeChild(inputLayer); openSecretBt:setVisible(true); end end);
            inputLayer:addChild(closeBt);

            local propNumEdit = ccui.EditBox:create(cc.size(150 , 40 ), "we");
            propNumEdit:setPosition(cc.p(inputLayer:getContentSize().width/2, inputLayer:getContentSize().height*0.4));
            propNumEdit:setAnchorPoint(cc.p(0.5, 0.5))
            propNumEdit:setPlaceHolder("NUMBER")
            propNumEdit:setPlaceholderFontColor(cc.c3b(255, 100, 100))
            propNumEdit:setFontColor(cc.c3b(100, 100, 100))
            propNumEdit:setInputFlag(5);
            propNumEdit:setFontSize(25)
            propNumEdit:setPlaceholderFontSize(20)
            inputLayer:addChild(propNumEdit);

            local propIdEdit = ccui.EditBox:create(cc.size(150 , 40 ), "we");
            propIdEdit:setPosition(cc.p(inputLayer:getContentSize().width/2, inputLayer:getContentSize().height*0.6));
            propIdEdit:setAnchorPoint(cc.p(0.5, 0.5))
            propIdEdit:setPlaceHolder("ID")
            propIdEdit:setPlaceholderFontColor(cc.c3b(255, 100, 100))
            propIdEdit:setFontColor(cc.c3b(100, 100, 100))
            propIdEdit:setInputFlag(5);
            propIdEdit:setFontSize(25)
            propIdEdit:setPlaceholderFontSize(20)
            inputLayer:addChild(propIdEdit);

            local function sendSecretMessage(pSender, eventName)
                if eventName == ccui.TouchEventType.ended then
                    local num = tonumber(propNumEdit:getText());
                    local id = tonumber(propIdEdit:getText());
                    local data = {}
                    data.newProps = {}
                    local prop = {}
                    prop.propId = id;
                    prop.propCount = num;
                    table.insert(data.newProps,prop)
                    FishGI.gameScene.net:sendAddMoney(data)
                    FishGI.gameScene.net:sendFriendGetPlayerInfo(FishGI.myData.playerId)
                end
            end

            local addBt = ccui.Button:createInstance();
            addBt:setTitleText("add");
            addBt:setTitleFontSize(30);
            addBt:setTag(2);
            addBt:setPosition(cc.p(inputLayer:getContentSize().width/2, inputLayer:getContentSize().height*0.2))
            addBt:addTouchEventListener(sendSecretMessage);
            inputLayer:addChild(addBt);

            --[[local addMoneyBt = ccui.Button:createInstance();
            addMoneyBt:setTitleText("add Money");
            addMoneyBt:setTitleFontSize(15);
            addMoneyBt:setTag(1);
            addMoneyBt:setPosition(cc.p(inputLayer:getContentSize().width/2, inputLayer:getContentSize().height*0.1))
            addMoneyBt:addTouchEventListener(sendSecretMessage);
            inputLayer:addChild(addMoneyBt);]]--
        end
    end

    openSecretBt = ccui.Button:create("common/btn/com_btn_blue_0.png", "common/btn/com_btn_blue_1.png");

    openSecretBt:setTitleText("Secret");
    openSecretBt:setTitleFontSize(30);
    openSecretBt:addTouchEventListener(openSecretLayerFunc);
    openSecretBt:setPosition(cc.p(winSize.width*0.1, winSize.height*0.8));
    layer:addChild(openSecretBt, 1002);
end

function FriendMainLayer:closeAllSchedule()
    if FishGI.gameScene.heartBeatUpdateId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(FishGI.gameScene.heartBeatUpdateId);
    end
    if FishGI.gameScene.loadingLayer ~= nil then
        FishGI.gameScene.loadingLayer:closeAllSchedule()
    end
    FishGI.gameScene.net:closeSchedule();
    self.uiGameData:unscheduleTimes()
end

--设置是否开启微信
function FriendMainLayer:setWechatIsOpen(isOpen)
    self.uiStartGame:setWechatIsOpen(isOpen)
    self.uiSettlement:setWechatIsOpen(isOpen)
end


return FriendMainLayer