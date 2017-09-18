local HallManager = class("HallManager", function()
	return cc.Scene:create();
end)

function HallManager.create(net)
	local manager = HallManager.new();
	manager:init(net);
	return manager;
end

function HallManager:setNet(net)
	self.net = net;
	self.net:setView(self.view);
	
end

function HallManager:init(net)
    self.sceneName = "hall"
    self:registerEnterBFgroundEvt()
	self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()
	
    self.view = require("hall/HallLayer").create();
	self:addChild(self.view,1)

    self.loadingLayer = require("Loading/LoadingLayer").new()
    self:addChild(self.loadingLayer,FishCD.ORDER_LOADING)
    
    --self:initLayer()
    --self:initFriendLayer()
    --self:initPlayerDataLayer()

	self.net = net;
	self.net:setView(self.view);

    local function onNodeEvent(event )
        if event == "enter" then
            self:onEnter()
        elseif event == "enterTransitionFinish" then

        elseif event == "exit" then
            self:onExit()
        elseif event == "exitTransitionStart" then

        elseif event == "cleanup" then

        end

    end
    self:registerScriptHandler(onNodeEvent)

	local function onKeyboardFunc(code, event)
		if code == cc.KeyCode.KEY_BACK then

            if FishGI.hallScene:getChildByTag(FishCD.TAG.RANK_WEB_TAG) ~= nil then
                FishGI.hallScene:removeChildByTag(FishCD.TAG.RANK_WEB_TAG)
            else
    			FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
                self:buttonClicked("HallLayer", "exit")
            end

            

		end
	end
	local listener = cc.EventListenerKeyboard:create();
	listener:registerScriptHandler(onKeyboardFunc, cc.Handler.EVENT_KEYBOARD_RELEASED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

--初始化层
function HallManager:firstInit( )
    if self.isFirstInit == nil then
        self:initLayer()
        self:initFriendLayer()
        self:initPlayerDataLayer()
        self.isFirstInit = true
    end
end

function HallManager:initLayer( )
	-- self.view = require("hall/HallLayer").create();
	-- self:addChild(self.view,1)

    FishGF.UpdataWechat()

    --大厅公告
    self.uiHallNotice = require("hall/HallNotice/HallNotice").create()
    self.uiHallNotice:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,612.14*self.scaleY_))
    self:addChild(self.uiHallNotice,FishCD.ORDER_SCENE_UI)
    self.uiHallNotice:setVisible(false)  
    
    --大厅房间图标
    self.uiAllRoomView = require("hall/Room/AllRoomView").create()
    self.uiAllRoomView:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,366.05*self.scaleY_))
    self:addChild(self.uiAllRoomView,2)
    --self.uiAllRoomView:setVisible(false)  
    self.uiAllRoomView:setScale(self.scaleMin_)

    --背包
    self.uiBagLayer = require("hall/Bag/Bag").create()
    self.uiBagLayer:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiBagLayer,FishCD.ORDER_LAYER_TRUE)
    self.uiBagLayer:setVisible(false)   
    self.uiBagLayer:setScale(self.scaleMin_)

    --兑换
    self.uiExchange = require("hall/Exchange/Exchange").create()
    self.uiExchange:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiExchange,FishCD.ORDER_LAYER_TRUE)
    self.uiExchange:setVisible(false)   
    self.uiExchange:setScale(self.scaleMin_)

    --商店
    self.uiShopLayer = require("Shop/Shop").create()
    self.uiShopLayer:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiShopLayer,FishCD.ORDER_LAYER_TRUE)
    self.uiShopLayer:setVisible(false)   
    self.uiShopLayer:setScale(self.scaleMin_)

    --月卡
    self.uiMonthcard = require("hall/Monthcard/Monthcard").create()
    self.uiMonthcard:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,330*self.scaleY_))
    self:addChild(self.uiMonthcard,FishCD.ORDER_LAYER_TRUE)
    self.uiMonthcard:setVisible(false)   
    self.uiMonthcard:setScale(self.scaleMin_)

    --VIP特权
    self.uiVipRight = require("VipRight/VipRight").create()
    self.uiVipRight:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiVipRight,FishCD.ORDER_LAYER_TRUE)
    self.uiVipRight:setVisible(false)
    self.uiVipRight:setScale(self.scaleMin_)

    --签到
    self.uiCheck = require("hall/Check/Check").create()
    self.uiCheck:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiCheck,FishCD.ORDER_LAYER_TRUE)
    self.uiCheck:setVisible(false)
    self.uiCheck:setScale(self.scaleMin_)

    --微信分享
    self.uiWeChatShare = require("hall/WeChatShare/WeChatShare").create()
    self.uiWeChatShare:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiWeChatShare,FishCD.ORDER_LAYER_TRUE)
    self.uiWeChatShare:setVisible(false)
    self.uiWeChatShare:setScale(self.scaleMin_)

    --邀请码邀请
    self.uiInviteFriend = require("hall/WeChatShare/InviteFriend").create()
    self.uiInviteFriend:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiInviteFriend,FishCD.ORDER_LAYER_TRUE)
    self.uiInviteFriend:setVisible(false)
    self.uiInviteFriend:setScale(self.scaleMin_)

    --邮箱
    self.uiMail = require("hall/Mail/Mail").create()
    self.uiMail:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiMail,FishCD.ORDER_LAYER_TRUE)
    self.uiMail:setVisible(false)
    self.uiMail:setScale(self.scaleMin_)

    --邮件正文
    self.uiMailBody = require("hall/Mail/MailBody").create()
    self.uiMailBody:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiMailBody,FishCD.ORDER_LAYER_TRUE)
    self.uiMailBody:setVisible(false)
    self.uiMailBody:setScale(self.scaleMin_)
    
    --锻造
    self.uiForgedLayer = require("hall/Forged/Forged").create()
    self.uiForgedLayer:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiForgedLayer,FishCD.ORDER_LAYER_TRUE)
    self.uiForgedLayer:setVisible(false)   
    self.uiForgedLayer:setScale(self.scaleMin_)

    --每日任务
    self.taskPanel = require("hall/Task/TaskUI/TaskMain").new()
    self.taskPanel:setAnchorPoint(0.5, 0.5)
    self.taskPanel:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.taskPanel, FishCD.ORDER_GAME_task);
    self.taskPanel:setVisible(false)
end

--初始化朋友场
function HallManager:initFriendLayer( )
	self.uiFriendRoom = require("hall/FriendRoom/FriendRoom").create();
	self:addChild(self.uiFriendRoom,1)

    --规则介绍
    self.uiRuleIntroduction = require("hall/FriendRoom/RuleIntroduction").create()
    self.uiRuleIntroduction:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiRuleIntroduction,FishCD.ORDER_LAYER_TRUE)
    self.uiRuleIntroduction:setVisible(false)   
    self.uiRuleIntroduction:setScale(self.scaleMin_)

    --加入房间
    self.uiJoinRoom = require("hall/FriendRoom/JoinRoom").create()
    self.uiJoinRoom:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiJoinRoom,FishCD.ORDER_LAYER_TRUE)
    self.uiJoinRoom:setVisible(false)   
    self.uiJoinRoom:setScale(self.scaleMin_)

    --历史记录
    self.uiRecord = require("hall/Record/Record").create()
    self.uiRecord:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiRecord,FishCD.ORDER_LAYER_TRUE)
    self.uiRecord:setVisible(false)   
    self.uiRecord:setScale(self.scaleMin_)

    --详细历史记录
    self.uiRecordBody = require("hall/Record/RecordBody").create()
    self.uiRecordBody:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiRecordBody,FishCD.ORDER_LAYER_TRUE)
    self.uiRecordBody:setVisible(false)   
    self.uiRecordBody:setScale(self.scaleMin_)

    --创建成功
    self.uiCreateSuceed = require("hall/FriendRoom/CreateSuceed").create()
    self.uiCreateSuceed:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiCreateSuceed,FishCD.ORDER_LAYER_TRUE)
    self.uiCreateSuceed:setVisible(false)   
    self.uiCreateSuceed:setScale(self.scaleMin_)

end

function HallManager:initPlayerDataLayer( )
    --账号设置
    self.uiPlayerInfo = require("PlayerInfo/PlayerInfo").create()
    self.uiPlayerInfo:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiPlayerInfo,FishCD.ORDER_LAYER_TRUE)
    self.uiPlayerInfo:setVisible(false)
    self.uiPlayerInfo:setScale(self.scaleMin_)

    --解绑手机
    self.uiPhoneUnbind = require("PlayerInfo/PhoneUnbind").create()
    self.uiPhoneUnbind:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiPhoneUnbind,FishCD.ORDER_LAYER_TRUE)
    self.uiPhoneUnbind:setVisible(false)
    self.uiPhoneUnbind:setScale(self.scaleMin_)

    --修改密码
    self.uiChangePassword = require("PlayerInfo/ChangePassword").create()
    self.uiChangePassword:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiChangePassword,FishCD.ORDER_LAYER_TRUE)
    self.uiChangePassword:setVisible(false)
    self.uiChangePassword:setScale(self.scaleMin_)

    --普通激活
    self.uiComAct = require("PlayerInfo/ComAct").create()
    self.uiComAct:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiComAct,FishCD.ORDER_LAYER_TRUE)
    self.uiComAct:setVisible(false)
    self.uiComAct:setScale(self.scaleMin_)

    --手机激活
    self.uiPhoneAct = require("PlayerInfo/PhoneAct").create()
    self.uiPhoneAct:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiPhoneAct,FishCD.ORDER_LAYER_TRUE)
    self.uiPhoneAct:setVisible(false)
    self.uiPhoneAct:setScale(self.scaleMin_)

    --手机绑定
    self.uiPhoneBind = require("PlayerInfo/PhoneBind").create()
    self.uiPhoneBind:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiPhoneBind,FishCD.ORDER_LAYER_TRUE)
    self.uiPhoneBind:setVisible(false)
    self.uiPhoneBind:setScale(self.scaleMin_)

    --修改昵称
    self.uiChangeNickName = require("PlayerInfo/ChangeNickName").create()
    self.uiChangeNickName:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
    self:addChild(self.uiChangeNickName,FishCD.ORDER_LAYER_TRUE)
    self.uiChangeNickName:setVisible(false)
    self.uiChangeNickName:setScale(self.scaleMin_)

end

--加载进度条
function HallManager:startLoad( isLoadData )
    FishGF.print("------------------------startLoad-------------------------------------")
    if self.loadingLayer == nil then
        self.loadingLayer = require("Loading/LoadingLayer").new()
        self:addChild(self.loadingLayer,FishCD.ORDER_LOADING)
    end

    FishGI.loading_index = 0
    FishGI.loading_sp = 1
    FishGI.isloadingEnd = false;

    --登录界面进入大厅进行加载
    if FishGI.GAME_STATE == 1 and self.loadingLayer.isloadEnd then
        self.loadingLayer:preloadRes(handler(self, self.getGameNetData))
    else
        if self.loadingLayer.isloadEnd then
            self.loadingLayer:setVisible(false)
            self.loadingLayer:closeAllSchedule()
        end
    end
    

--    FishGF.setLodingEnd()
end

function HallManager:getGameNetData( )
    FishGF.print("------------------------getGameNetData-------------------------------------")
    --FishGI.hallScene:setIsToFriendRoom(false)
    --刷新朋友场状态
    if FishGI.isCurTimehour then
        FishGI.hallScene.uiAllRoomView:fastStartGame()
    else
        self.taskPanel:onEnterHall()
        if FishGI.GAME_STATE == 2 and FishGI.FRIEND_ROOM_STATUS == 0 then
            FishGI.FriendRoomManage:sendGetFriendStatus();
        end
    end
end

function HallManager:onEnter( )
    print("------------HallLayer:onEnter--")
    FishGF.waitNetManager(false,nil,"exitGame")
    FishGI.AudioControl:playLayerBgMusic()
	FishGI.shop = self.uiShopLayer;
    FishGI.GameTableData:clearGameTable(1)
    self:disposeExit()
    
end

function HallManager:onExit( )
    print("HallLayer:onExit( )----------------------------------------------------------------")
end

--处理退出
function HallManager:disposeExit()
    if FishGI.exitType == nil then
        FishGF.print("---------- 第一次进入大厅-----------")
    else
        FishGF.print("---------------disposeExit------------------------FishGI.exitType="..FishGI.exitType)
    end

    FishGI.isNoticeClose = true
    --nil 第一次进入大厅 0 正常退出 1超出房间最高倍数被踢   2朋友场被踢   3朋友场被解散   4朋友场结束   5自己强退   6.等待时间过长 7朋友场主动解散 8房间关闭被踢 9.断线被踢出游戏 100.未知原因 1000.小游戏退出
    if FishGI.exitType == 1 then
        FishGI.isEnterBg = true
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000088),nil)
        self:doAutoLogin(0.1)
    elseif FishGI.exitType == 2 then
        FishGI.isEnterBg = true
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000260),nil)
        self:doAutoLogin(0.1)
    elseif FishGI.exitType == 3 then
        FishGI.isEnterBg = true
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000261),nil)
        self:doAutoLogin(0.1)
    elseif FishGI.exitType == 4 then
        FishGI.isEnterBg = true
        self:doAutoLogin(0.1)
    elseif FishGI.exitType == 5 then
        FishGI.isEnterBg = true
        self:doAutoLogin(0.1)
    elseif FishGI.exitType == 6 then
        FishGI.isEnterBg = true
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000292),nil)
        self:doAutoLogin(0.1)
    elseif FishGI.exitType == 7 then
        FishGI.isEnterBg = true
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000300),nil)
        self:doAutoLogin(0.1)
    elseif FishGI.exitType == 8 then
        FishGI.isEnterBg = true
        FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000036),"OnMsgRemoveRoom")
    elseif FishGI.exitType == 9 then
        FishGI.isEnterBg = true
        FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000036),"hallOnSocketClose")
    elseif FishGI.exitType == 100 then
        FishGI.isEnterBg = true
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000291),nil)
        self:doAutoLogin(0.1)
    elseif FishGI.exitType == 1000 then
        FishGI.isEnterBg = true
        self:doAutoLogin(0.1)
    end
    FishGI.exitType = 0

end

--进入前台
function HallManager:onAppEnterForeground()
    FishGF.print("HallManager---enter--");
    if self.isEnterBg == false then
        return;
    end
    self.isEnterBg = false
    if FishGI.isEnterBg == false then
        return;
    end

    if device.platform == "ios" then
        self:doAutoLogin(2)
    else
        self:doAutoLogin(0.1)
    end

end

--进入后台
function HallManager:onAppEnterBackground()
    print("___HallManager____back");
    FishGI.isEnterBg = true;
    self.isEnterBg = true
end

--自动重连
function HallManager:doAutoLogin(delayTime)
    print("doAutoLogin");
    if delayTime == nil then
        local noDelList = {"doPaySDK"}
        FishGF.clearSwallowLayer(noDelList)
        FishGI.AudioControl:playLayerBgMusic()
        FishGI.hallScene.net:dealloc();
        FishGI.loginScene.net:DoAutoLogin();
        FishGI.hallScene:removeChildByTag(FishCD.TAG.RANK_WEB_TAG)
    else
        FishGI.hallScene.net:dealloc();
        local noDelList = {"doPaySDK"}
        FishGF.clearSwallowLayer(noDelList)
        FishGF.waitNetManager(true,nil,"delayAutoLogin")
        FishGF.print("------------FishGI.loginScene.net:DoAutoLogin-------------")
        local seq = cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function ( ... )
            FishGF.waitNetManager(false,nil,"delayAutoLogin")
            self:doAutoLogin()
        end))
        seq:setTag(100000)
        local cueScene = cc.Director:getInstance():getRunningScene()
        cueScene:stopActionByTag(100000)
        cueScene:runAction(seq)
    end
end

function HallManager:registerEnterBFgroundEvt()
    self.isEnterBg = false

    local eventDispatcher = self:getEventDispatcher()
    local forelistener = cc.EventListenerCustom:create("applicationWillEnterForeground", handler(self,self.onAppEnterForeground))
    eventDispatcher:addEventListenerWithSceneGraphPriority(forelistener, self)
    local backlistener = cc.EventListenerCustom:create("applicationDidEnterBackground", handler(self,self.onAppEnterBackground))
    eventDispatcher:addEventListenerWithSceneGraphPriority(backlistener, self)

end

------------------------------------------------------------------------------------------------------
-------------------------------------------接收网络消息-----------------------------------------------
------------------------------------------------------------------------------------------------------

function HallManager:receiveNetData( netData )

    if netData.msgType == FishCD.ViewMessageType.HALL_HALL_INFO then
        local firstLogin = netData.firstLogin
        --第一次登录账号
        if firstLogin ~= nil and firstLogin == true then
            if self.uiDialCommon ~= nil then
                self.uiDialCommon:setVisible(false)
                --self.uiDialCommon:hideLayer(false)
            end
        end
    elseif netData.msgType == FishCD.ViewMessageType.HALL_SET_PLAYER_INFO then  --玩家数据
        self:upDataPlayerInfo(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_DIAL_END then --公共转盘
        netData.vip_level = FishGI.myData.vip_level
        netData.playerId = FishGI.myData.playerId
        self.uiDialCommon:endRotate(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_VIPDIAL_END then --vip转盘
        FishGI.myData.vipDrawCountUsed = netData.countUsed
        netData.playerId = FishGI.myData.playerId
        self.uiDialVIP:endRotate(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_MONTH then  --月卡
        local isSuccess = netData.isSuccess
        local rewardItems = netData.rewardItems
        if not isSuccess then
            print("------faill getMonth---")
            return
        end
        self.view:setBtnIsLight(FishCD.HALL_BTN_9,false)
        self.uiMonthcard:getMonthCardReward(netData)

    elseif netData.msgType == FishCD.ViewMessageType.HALL_ALM_INFO then   --申请救济金
        local leftCount = netData.leftCount;
        if leftCount <= 0 then
            print("alm leftCount is 0");
            self.view:initAlm()
            return;
        end
        local seconds = netData.cd;
        if seconds > 0 then
            self.view:openAlmCountDown(seconds);
        else
            self.view:canReceiveAlm();
        end
    elseif netData.msgType == FishCD.ViewMessageType.HALL_ALM_RESULT then   --救济金领取结果
        local isSuccess = netData.success;
        if isSuccess then
            local propCount = netData["newFishIcon"]
            --更新新鱼币，并加入缓存
            FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,1,propCount,false)
            FishGMF.setAddFlyProp(FishGI.myData.playerId,1,propCount,false)

            local function callback( ... )
                --更新界面
                FishGMF.setAddFlyProp(FishGI.myData.playerId,1,propCount,true)
            end

            local dataTab = {}
            dataTab.propCount = 2
            dataTab.firstPos = self.view:getBtnPosByIndex(6)
            dataTab.endPos = FishGF.getHallPropAimByID(1)
            FishGI.GameEffect.coinFlyAct(dataTab,nil,callback)

            self.view:initAlm();
        else
            print("receive alm failure");
        end

    elseif netData.msgType == FishCD.ViewMessageType.HALL_SIGNIN then  --大厅签到
        local isSuccess = netData.isSuccess
        if isSuccess then
            self.view:setBtnIsLight(FishCD.HALL_BTN_3,false)
        else
            self.view:setBtnIsLight(FishCD.HALL_BTN_3,true)
        end
        self.uiCheck:receiveCheckData(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_BAG_BUY then --背包购买
        self.uiBagLayer:receiveBuyData(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_ACCOUNT then --大厅公告
        self.uiHallNotice:setAccountData( netData )
    elseif netData.msgType == FishCD.ViewMessageType.HALL_CHANGE_NICK then --修改昵称
        if netData.isSuccess then
            self.uiChangeNickName:hideLayer()
            FishGF.showToast(FishGF.getChByIndex(800000193))
            --更新玩家昵称
            self:setPlayerName(netData.newNickName)
            FishGI.myData.nickNameChangeCount = 1
            self.uiPlayerInfo:setNickNameChangeCount(FishGI.myData.nickNameChangeCount)
        else
            print("-------newNickName----false---")
            FishGF.showToast(FishGF.getChByIndex(800000195))
        end
    elseif netData.msgType == FishCD.ViewMessageType.HALL_UNREADMAILS then --大厅未读邮件
        self.uiMail:setUnreadMailData( netData )
        self.uiMail:loadUnreadMail()
        local redDot = self.view.btn_mail:getChildByName("spr_dot")
        local isNew = false
        if netData ~= nil and netData.unreadMails ~= nil and #netData.unreadMails > 0 then
            isNew = true
        end
        redDot:setVisible(isNew)
        self.view.btn_option["isNew"] = isNew
        self.view:setOptionIsOpen(false)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_MAILS_DATA then --大厅未读邮件正文
        if not netData.success then
            self.uiMail:removeMail(netData.id)
            FishGF.showToast(FishGF.getChByIndex(800000309))
        end
        self.uiMailBody:receiveBodyData(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_MARK_MAILS_READ then --大厅邮件正文标记已读
        if netData.success then
            local leaveCount = self.uiMail:removeMail(netData.id)
            local redDot = self.view.btn_mail:getChildByName("spr_dot")
            local isNew = false
            if leaveCount > 0 then
                isNew = true
            end
            redDot:setVisible(isNew)
            self.view.btn_option["isNew"] = isNew
            self.view:setOptionIsOpen(false)
        end
        self.uiMailBody:getMailProp(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_FORGED then --锻造
        self.uiForgedLayer:onForgedResult(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_DECOMPOSE then --锻造分解
        self.uiBagLayer:onDecomposeResult(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_RECEIVE_PHONE_FARE then --奖券兑换话费
        self.uiExchange:onReceivePhoneFare(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_GET_FRIENDSTATUS then --获取朋友场状态
        self.uiFriendRoom:onGetFriendStatus(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_CREATE_FRIENDSTATUS then --创建朋友场
        self.uiFriendRoom:OnCreateFriendRoom(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_CREATE_FRIEND_READY then --朋友场服务器准备好了
        self.uiFriendRoom:OnFriendServerReady(netData)
    elseif netData.msgType == FishCD.ViewMessageType.HALL_JOIN_FRIEND_ROOM then --加入朋友场
        self.uiFriendRoom:OnJoinFriendRoom(netData)  
    elseif netData.msgType == FishCD.ViewMessageType.HALL_ISOPEN_FRIEND_ROOM then --大厅朋友场是否开放
        self.uiAllRoomView:OnFriendOpen(netData);
    
    elseif netData.msgType == FishCD.ViewMessageType.HALL_WECHAT_SHARE_RESULT then --微信分享
        self.uiWeChatShare:shareResult(netData);
    elseif netData.msgType == FishCD.ViewMessageType.HALL_INVITE_RESULT then --好友邀请
        self.uiInviteFriend:inviteResult(netData);
    end

    --更新按键位置
    self.view:upDataBtnArrPos()

    FishGF.setLodingEnd()
end

------------------------------------------------------------------------------------------------------
-------------------------------------------更新数据和界面---------------------------------------------
------------------------------------------------------------------------------------------------------

--刷新玩家所有数据
function HallManager:upDataPlayerInfo( netData )
        FishGMF.setMyPlayerId(netData.playerId)
        
        --判断是否充值成功
        local result = FishGF.isRechargeSucceed(netData)
        if not result then
            return
        end

        FishGI.IS_GET_VIP_REWARD = netData.vipDailyRewardToken
        if FishGI.FRIEND_ROOM_STATUS ~= 0 then 
            return
        end 
        
        --清除背包数据
        self.uiBagLayer:initPropData()

        FishGI.myData = netData
        --绑定玩家到c++
        self:upDataPlayerToCpp(netData)
        FishGI.myData = netData
        self.uiBagLayer:setRightPropData(self.uiBagLayer:getPropListFirst())

        FishGI.myData.isActivited = FishGI.WebUserData:isActivited()
        FishGI.myData.isBindPhone = FishGI.WebUserData:isBindPhone()

        --更新房间限制
        self.uiAllRoomView:setRoomLimit(FishGI.myData.maxGunRate);

        --更新消费金额和vip等级
        self:upDataVIPData(netData.vipExp)

        --更新玩家资料
        self.uiPlayerInfo:upDataPlayerData()

        --更新玩家昵称
        self:setPlayerName(netData.nickName)

        --是否开通或激发月卡
        self:upDataMonthCard()

        --是否签到
        self:upDataCheck()

        --是否普通抽奖
        self:upDataLoginDraw()

        --微信分享
        self:upDataWeChatShare()

        --更新锻造
        self:upDataForged()

        --更新按键位置
        self.view:upDataBtnArrPos()

        -- --刷新朋友场状态
        -- FishGI.FriendRoomManage:sendGetFriendStatus();

        --播放音乐
        FishGI.AudioControl:playLayerBgMusic()

end

--更新玩家数据到c++
function HallManager:upDataPlayerToCpp(netData)
    local playerId = netData.playerId
    local seniorProps = netData.seniorProps
    if FishGI.GAME_STATE == 2 then
        print("---------upDataPlayerInfo-----------更新界面--------------")
        local list = self.uiBagLayer:getPropList()
        for k,val2 in pairs(list) do
            local isChange = true
            local props = netData.props
            for k,val in pairs(props) do
                if val.propId == val2.propId and val2.if_senior == 0 then
                    isChange = false
                    FishGMF.upDataByPropId(playerId,val.propId,val.propCount)
                end
            end
            if isChange and val2.if_senior == 0  then
                FishGMF.upDataByPropId(playerId,val2.propId,0)
            end
        end
        --更新界面
        FishGMF.upDataByPropId(playerId,1,netData.fishIcon)
        FishGMF.upDataByPropId(playerId,2,netData.crystal)

        FishGMF.clearAllSeniorProp(playerId,1)

        --高级道具
        for k,val in pairs(seniorProps) do
            FishGMF.refreshSeniorPropData(playerId,val,1,0)
        end
        FishGMF.changeGunRate(playerId,netData.currentGunRate,netData.maxGunRate)
    else
        print("---------upDataPlayerInfo-----------增加玩家--------------")
        FishGMF.setGameType(0)
        FishGMF.setGameState(2)

        local playerData = {};
        playerData.playerId = playerId;
        playerData.currentGunRate = netData.currentGunRate
        playerData.maxGunRate = netData.maxGunRate
        playerData.gold = netData.fishIcon
        playerData.gem = netData.crystal
        playerData.props = netData.props

        local list = self.uiBagLayer:getPropList()
        for k,val2 in pairs(list) do
            local props = playerData.props
            for k,val in pairs(props) do
                if val.propId == val2.propId then 
                    val2.propCount = val.propCount
                end
            end
        end
        playerData.props = list
        -- if playerData.props ~= nil and table.maxn(playerData.props) == 0 then
        --     playerData.props = nil
        -- end
        playerData.seniorProps = netData.seniorProps
        if playerData.seniorProps ~= nil and table.maxn(playerData.seniorProps) == 0 then
            playerData.seniorProps = nil
        end
        LuaCppAdapter:getInstance():addPlayer(playerData);
    end

end

--更新月卡
function HallManager:upDataMonthCard()
    local leftMonthCardDay = FishGI.myData.leftMonthCardDay
    local monthCardRewardToken = FishGI.myData.monthCardRewardToken

    if not monthCardRewardToken and leftMonthCardDay > 0 then
        self.view:setBtnIsLight(FishCD.HALL_BTN_9,true)
    else
        self.view:setBtnIsLight(FishCD.HALL_BTN_9,false)
    end
    self.uiMonthcard:setLeftMonthCardDay(leftMonthCardDay,monthCardRewardToken)

end

--更新微信分享
function HallManager:upDataWeChatShare()
    local shareLinkUsed = FishGI.myData.shareLinkUsed
    local inviteCodeUsed = FishGI.myData.inviteCodeUsed
    local playerId = FishGI.myData.playerIdFset
    if inviteCodeUsed ~= nil then
        self.uiInviteFriend:setMyCode(playerId)
        self.uiInviteFriend:setInviteCodeUsed(inviteCodeUsed)
    end
    if shareLinkUsed ~= nil then
        self.uiWeChatShare.shareLinkUsed = shareLinkUsed
    end
end

--更新普通抽奖
function HallManager:upDataLoginDraw()
    local loginDrawUsed = FishGI.myData.loginDrawUsed
    if loginDrawUsed ~= nil and not loginDrawUsed then
        --转盘
        FishGI.ISFIRST_IN = true
        if self.uiDialCommon == nil then
            self.uiDialCommon = require("hall/Dial/DialCommon").create()
            self.uiDialCommon:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
            self:addChild(self.uiDialCommon,FishCD.ORDER_LAYER_TRUE )
            self.uiDialCommon:setScale(self.scaleMin_)
        end
        if FishGI.GAME_STATE == 2 then
            self.uiDialCommon:setVisible(true)
            self.uiDialCommon:showLayer(false)
        end
    end
end

--更新锻造
function HallManager:upDataForged()
    if FishGI.myData.maxGunRate < 1000 then
        self.view.node_btn_7:setVisible(false)
    else
        self.view.node_btn_7:setVisible(true)
        self.uiForgedLayer:setMaxGunRate(FishGI.myData.maxGunRate)

        local isCanForged = self.uiForgedLayer:checkIfForged()
        if isCanForged then
            self.view:setBtnIsLight(FishCD.HALL_BTN_7,true)
        else
            self.view:setBtnIsLight(FishCD.HALL_BTN_7,false)
        end

    end
end

--更新签到
function HallManager:upDataCheck()
    if FishGI.myData.hasSignToday then
        self.view:setBtnIsLight(FishCD.HALL_BTN_3,false)
    else
        self.view:setBtnIsLight(FishCD.HALL_BTN_3,true)
    end
    self.uiCheck:receiveData(FishGI.myData)

end


--加载更新公告
function HallManager:addHallNotice()
--大厅版本更新公告
    local function callback(data)
        local list = data.list
        if list == nil or #list  == 0 then
            return;
        end
        print("---------1111");
        local version = ""
        local updateMsg = ""
        for key, val in pairs(list) do
            version = val["title"]
            updateMsg = val["body"]
        end
        self.updateNotice = require("Update/bigUpdate/BigUpDateNotice").create();
        self.updateNotice:setCurVersions(version)
        self.updateNotice:setVersionsData(updateMsg);
        self.updateNotice:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2));
        self:addChild(self.updateNotice,FishCD.HALL_RECEIVE_UPDATE_NOTICE);
    end
    FishGI.Dapi:NoticeList(callback)
end

--更新vip相关数据
function HallManager:upDataVIPData( costMoney )
    local vipData = FishGI.GameTableData:getVIPByCostMoney(costMoney)
    vipData.vipExp = costMoney
    FishGI.myData.vipExp = costMoney
    FishGI.myData.vip_level = vipData.vip_level
    FishGI.myData.extra_sign = vipData.extra_sign
    FishGI.myData.next_All_money = vipData.next_All_money
    FishGI.myData.daily_items_reward = vipData.daily_items_reward    

    --更新vip相关界面
    self:upDataVIPView(vipData)

end

function HallManager:upDataVIPView(vipData)
    local vipExp = vipData.vipExp    
    local vip_level = vipData.vip_level
    local extra_sign = vipData.extra_sign

    --更新界面
    self.view.fnt_vipnum:setString(vip_level)
    self.uiPlayerInfo:setPlayerDataByName("vip_level",vip_level)
    self.uiBagLayer:setMyVIP(vip_level);

    --更新商店
    self.uiShopLayer:upDataLayer(vipData)
    --更新VIP特权
    self.uiVipRight:upDataLayer(vipData)
    self.uiVipRight:setRewardIsToken(FishGI.IS_GET_VIP_REWARD)

    self.uiForgedLayer:setVIPLevel(vip_level)

    --是否VIP转盘
    if extra_sign ~= nil and extra_sign >= 1  then
        --VIP转盘
        if self.uiDialVIP == nil then
            self.uiDialVIP = require("hall/Dial/DialVIP").create()
            self.uiDialVIP:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2,cc.Director:getInstance():getWinSize().height/2))
            self:addChild(self.uiDialVIP,FishCD.ORDER_LAYER_TRUE )
            self.uiDialVIP:setScale(self.scaleMin_)
            self.uiDialVIP:setVisible(false)
            self.uiDialVIP:setDialEnd(true)
        end
        self.uiDialVIP:upDataVIPData()
    end
end

--设置玩家名字
function HallManager:setPlayerName(name)
    -- if name == nil or name == "" then
    --     name = FishGI.myData.account
    -- end
    FishGI.myData.nickName = name
    self.view.text_name:setString(name)
    self.uiPlayerInfo:setPlayerDataByName("nickName",name)
end

--是否显示VIP转盘
function HallManager:isShowVIPDail()
    if FishGI.myData.extra_sign - FishGI.myData.vipDrawCountUsed > 0 then
        self.uiDialVIP:showLayer()
        return
    end

    self:isShowShareEnd()
end

--判断是否弹出过分享
function HallManager:isShowShareEnd()
    if FishGI.ISFIRST_IN then
        if FishGI.isOpenWechat then
            self.uiWeChatShare:showLayer()
        end
        FishGI.ISFIRST_IN = false
    end
end

--更新道具界面数据
function HallManager:upDataPropViewData(playerId, propId ,showCount,propItemId,seniorData)
    --print("--------------------------upDataAllViewData--propId="..propId.."---showCount="..showCount)
    if propId == 1 then
        if tonumber(self.view.fnt_coin:getString() )< showCount then
            FishGI.GameEffect.nodeJump(self.view.fnt_coin)
        end
        self.view.fnt_coin:setString(showCount)
        if self.uiDialVIP ~= nil then
            self.uiDialVIP:setPlayerCoin(showCount)
        end
        self.uiPlayerInfo:setPlayerDataByName("fishIcon",showCount)
        FishGI.myData.fishIcon = showCount

    elseif propId == 2 then
        if tonumber(self.view.fnt_diamond:getString() )< showCount then
            FishGI.GameEffect.nodeJump(self.view.fnt_diamond)
        end
        self.view.fnt_diamond:setString(showCount)
        self.uiBagLayer:setMyCrystal(showCount);
        self.uiPlayerInfo:setPlayerDataByName("crystal",showCount)
        FishGI.myData.crystal = showCount

        self.uiForgedLayer:setMyCrystal(showCount)

    else
        self.uiBagLayer:setPropData(propId,showCount,seniorData)
        self.uiBagLayer:updatePropList()
        for k,val in pairs(FishGI.myData.props) do
            if val.propId == propId then
                val.propCount = showCount
            end
        end

        -- if showCount == 0 then
        --     for k,val in pairs(FishGI.myData.seniorProps) do
        --         if val.propId == propId  then
        --             FishGI.myData.seniorProps[k] = nil
        --         end
        --     end
        -- end

        if propId == 12 then
            self.uiExchange:setMyPropCount(showCount)
        end
        
        self.uiFriendRoom:updatePropData(propId,showCount)

        self.uiForgedLayer:updatePropData(propId,showCount)
    end

    self:upDataForged()
end

function HallManager:closeAllSchedule()
    if self.loadingLayer ~= nil then
        self.loadingLayer:closeAllSchedule()
    end
    if self.uiMail ~= nil then
        self.uiMail:closeAllSchedule()
    end
    if self.uiDialCommon ~= nil then
        self.uiDialCommon:initDialAge()
    end

    if self.uiDialVIP ~= nil then
        self.uiDialVIP:initDialAge()
    end
end

--按键关闭，--关闭一些功能
function HallManager:setBtnHide(btnmane)
    self.view[btnmane]:setVisible(false)
    
end

--设置是否返回大厅
function HallManager:setIsToFriendRoom( isTo)
    self.view:setIsCurShow(not isTo)
    self.uiAllRoomView:setIsCurShow(not isTo)

    self.uiFriendRoom:setIsCurShow(isTo)

    if not isTo then
        self.uiCreateSuceed:hideLayer()
    end

end

function HallManager:buttonClicked(viewTag, btnTag)
    if viewTag == "HallLayer" then 
        if btnTag == "exit" then 
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    FishGI.hallScene.net:CloseSocket();
                    FishGI.eventDispatcher:removeAllListener();
                    FishGI.mainManagerInstance:createLoginManager();
                end
            end
            --FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000152),callback)
            FishGF.showExitMessage(FishGF.getChByIndex(800000152),callback)
            FishGI.hallScene:removeChildByTag(FishCD.TAG.RANK_WEB_TAG);
        end 
    end 
end

return HallManager;