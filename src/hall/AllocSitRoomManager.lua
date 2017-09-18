local evt = {}
local proto = FishGI.gameNetMesProto


--创建房间管理类 防作弊模式
local AllocSitRoomManager = FishGF.ClassEx("AllocSitRoomManager", function() 
    local obj =  CAllocSitRoomManager.New()
	obj.event = evt;
	return obj;
end );

function AllocSitRoomManager.create(hallManager, roomid)
    local obj = AllocSitRoomManager.new();
    obj:SetRoomInfo(hallManager, roomid);
    if obj:Initialize() then
        obj:RegisterMsgProcess(FishNM.HEAD.MSG_S2C_HALL_JMSG, obj.OnJMsg, "OnJMsg");
        return obj;
    else
        return nil;
    end
end

function AllocSitRoomManager:RegisterMsgProcess(msg, func, name)
    print("BaseClient RegisterMsgProcess");
    evt[msg] = function(client, ...)
--        print("[API] Enter MSG = " .. tostring(msg) .. ", " .. tostring(name));
        return func(self, ...);
    end;
end

function AllocSitRoomManager:sendJMsg( name, data )
    local encoded, len = jmsg.encodeBinary(proto, name, data)
    local msg = CLuaMsgHeader.New()
    msg.id = FishNM.HEAD.MSG_C2S_HALL_JMSG;
    --    print("encoded len="..len)
    msg:WriteData(encoded, len)
    self:SendData(msg)
    jmsg.freeBinary(encoded)
end

function AllocSitRoomManager:sendDataGetDesk(roomID)
    if self.isEnterRoom == true then
        return;
    end
    self.isEnterRoom = true;
    FishGF.print("sendDataGetDesk")
    FishGF.waitNetManager(true,nil,"sendDataGetDesk")
    local msg = require("Other/WebTool").codingData({
            {"BYTE", tonumber(roomID)}
        },FishNM.HEAD.MSG_C2S_GET_DESK);
    self:SendData(msg);
end

--发送刷新大厅数据
function AllocSitRoomManager:sendDataGetInfo()
    FishGF.waitNetManager(true,nil,"MSGC2SGetHallInfo")
    local data = {
        channelId = CHANNEL_ID,
        version = table.concat(HALL_WEB_VERSION, "."),
    }
    self:sendJMsg("MSGC2SGetHallInfo", data);
end

--发送普通抽奖
function AllocSitRoomManager:sendLoginDraw()
    self:sendJMsg("MSGC2SLoginDraw", {});
end
--发送VIP抽奖
function AllocSitRoomManager:sendVipLoginDraw()
    self:sendJMsg("MSGC2SVipLoginDraw", {});
end

--发送领取月卡道具
function AllocSitRoomManager:sendGetMonthCard()
    print("--sendGetMonthCard-")
    self:sendJMsg("MSGC2SGetMonthCardReward", {});
end

--准备申请救济金
function AllocSitRoomManager:sendAlmInfo()
    self:sendJMsg("MSGC2SAlmInfo", {})
end

--开始申请救济金
function AllocSitRoomManager:sendApplyAlm()
    self:sendJMsg("MSGC2SApplyAlm", {})
end

--申请签到
function AllocSitRoomManager:sendSignIn()
    self:sendJMsg("MSGC2SSignIn", {})
end

--背包购买道具
function AllocSitRoomManager:sendBuy(propId,count)
    FishGF.waitNetManager(true,nil,"MSGC2SBuy")
    local data = {
        propId = propId,
        count = count
    }
    self:sendJMsg("MSGC2SBuy", data)
end

--发送微信分享成功
function AllocSitRoomManager:sendGetShareReward()
    self:sendJMsg("MSGC2SShareLink", {});
end

--发送邀请成功
function AllocSitRoomManager:sendInviteCode()
    self:sendJMsg("MSGC2SInviteCode", {});
end

--发送修改昵称
function AllocSitRoomManager:sendChangeNickName(newNickName)
    FishGF.waitNetManager(true,nil,"MSGC2SChangeNickName")
    local data = {
        newNickName = newNickName,
    }
    self:sendJMsg("MSGC2SChangeNickName", data)
end

--发送获取邮件正文
function AllocSitRoomManager:sendGetMailDetail(id)
    FishGF.waitNetManager(true,nil,"MSGC2SGetMailDetail")
    local data = {
        id = id,
    }
    self:sendJMsg("MSGC2SGetMailDetail", data)
end

--发送邮件已读
function AllocSitRoomManager:sendMarkMailAsRead(id)
    FishGF.waitNetManager(true,nil,"MSGC2SMarkMailAsRead")
    local data = {
        id = id,
    }
    self:sendJMsg("MSGC2SMarkMailAsRead", data)
end

--发送锻造请求
function AllocSitRoomManager:sendForgedReq(useCrystalPower)
    FishGF.waitNetManager(true,nil,"MSGC2SForge")
    local data = {
        useCrystalPower = useCrystalPower,
    }
    self:sendJMsg("MSGC2SForge", data)
end

--发送锻造材料分解请求
function AllocSitRoomManager:sendDecomposeReq(propId)
    FishGF.waitNetManager(true,nil,"MSGC2SDecompose")
    local data = {
        propId = propId,
    }
    self:sendJMsg("MSGC2SDecompose", data)
end

--发送奖券兑换请求
function AllocSitRoomManager:sendReceivePhoneFare(data)
    FishGF.waitNetManager(true,nil,"MSGC2SReceivePhoneFare")
    self:sendJMsg("MSGC2SReceivePhoneFare", data)
end

--发送vip每日领取
function AllocSitRoomManager:sendGetVipDailyReward()
    self:sendJMsg("MSGC2SGetVipDailyReward", {})
end

--请求任务数据
function AllocSitRoomManager:sendRequestForTaskInfo()
    FishGF.waitNetManager(true,nil,"MSGC2SGetAllTaskInfo")
    self:sendJMsg("MSGC2SGetAllTaskInfo", {})
end

--请求领取奖励
function AllocSitRoomManager:sendRequestForTaskReward(valTab)
    log("--sendRequestForTaskReward--")
    self:sendJMsg("MSGC2SGetTaskReward", valTab)
end

--请求活跃奖励
function AllocSitRoomManager:sendRequestForActiveReward(valTab)
    log("--sendRequestForActiveReward--")
    self:sendJMsg("MSGC2SGetActiveReward", valTab)
end

--获取当前时光沙漏状态
function AllocSitRoomManager:sendToGetTimeHourglass(tabVal)
    log("--sendToGetTimeHourglass--")
    self:sendJMsg("MSGC2SGetTimeHourglass", tabVal)
end

--使用限时炮台
function AllocSitRoomManager:sendUsePropCannon(useType,propID)
    print("--sendUsePropCannon--")
    FishGF.waitNetManager(true,nil,"UsePropCannon")
    local data = {
        useType = useType,
        propID = propID,        
    }
    self:sendJMsg("MSGC2SUsePropCannon", data)
end

--出售
function AllocSitRoomManager:sendSellItem(propId,propItemId,count)
    print("--sendUsePropCannon--")
    FishGF.waitNetManager(true,nil,"SellItem")
    local data = {
        propId = propId,
        propItemId = propItemId,  
        count = count,      
    }
    self:sendJMsg("MSGC2SSellItem", data)
end

---------------------------------------recv----------

function AllocSitRoomManager:OnJMsg(msg)
    local ptr = msg:ReadData(0)
    local data, typeName = jmsg.decodeBinary(proto, ptr)
    print("-------------------------------onJmsg, typeName="..typeName)
    if FishGI.FriendRoomManage ~= nil then
        FishGI.FriendRoomManage:OnJMsg(typeName,data)
    end

    if typeName == "MSGS2CGetHallInfo" then
        self:OnHallInfo(data)
    elseif typeName == "MSGPlayerInfo" then
        self:OnPlayerInfo(data)
    elseif typeName == "MSGS2CLoginDraw" then
        self:OnLoginDraw(data)
    elseif typeName == "MSGS2CVipLoginDraw" then
        self:OnVipLoginDraw(data)
    elseif typeName == "MSGS2CGetMonthCardReward" then
        self:OnGetMonthCardReward(data)
    elseif typeName == "MSGS2CApplyAlmResult" then
        self:OnAlmResult(data)
    elseif typeName == "MSGS2CAlmInfo" then
        self:OnAlmInfo(data)
    elseif typeName == "MSGS2CSignIn" then
        self:OnSignIn(data)
    elseif typeName == "MSGS2CBuy" then
        self:OnBuyProp(data)
    elseif typeName == "MSGS2CAnnounce" then
        self:OnAnnounce(data)
    elseif typeName == "MSGS2CShareLink" then
        self:OnGetShareRewardResult(data);
    elseif typeName == "MSGS2CInviteCode" then
        self:OnInviteCodeResult(data);
    elseif typeName == "MSGS2CChangeNickName" then
        self:OnChangeNickName(data);
    elseif typeName == "MSGS2CGetMailDetail" then
        self:OnGetMailDetail(data);
    elseif typeName == "MSGS2CMarkMailAsRead" then
        self:OnMarkMailAsRead(data);
    elseif typeName == "MSGS2CForge" then
        self:OnForged(data);
    elseif typeName == "MSGS2CDecompose" then
        self:OnDecompose(data);
    elseif typeName == "MSGS2CReceivePhoneFare" then
        self:OnReceivePhoneFare(data);
    elseif typeName == "MSGS2CGetVipDailyReward" then
        FishGI.eventDispatcher:dispatch("GetVipDailyReward", data);
    elseif typeName == "MSGS2CGetAllTaskInfo" then
        self:onGetTaskInfoResult(data)
    elseif typeName == "MSGS2CGetTaskReward" then
        self:onTaskRewardResult(data)
    elseif typeName == "MSGS2CGetActiveReward" then
        self:onActiveReward(data)
    elseif typeName == "MSGS2CHaveFinishTask" then
        self:onTaskFinished(data)
    elseif typeName == "MSGS2CIsOnTimehourGlass" then
        self:onTimehourConsume(data)
    elseif typeName == "MSGS2CGetTimeHourglass" then
        self:onGetPlayerTimehourInfo(data)
    elseif typeName == "MSGS2CForbidAccount" then
        self:dontEnterRoom(data)
        dump(data)
    elseif typeName == "MSGS2CUsePropCannon" then
        self:onUsePropCannon(data)
    elseif typeName == "MSGS2CSellItem" then
        self:onSellItem(data)
    end
end

--更新大厅玩家数据
function AllocSitRoomManager:OnHallInfo(data)
    FishGI.FRIEND_ROOM_STATUS = 0
    FishGI.FRIEND_ROOMID = nil

    FishGI.isOpenDebug = data.enableDebug
	if FishGI.isOpenDebug and FishGI.isWirteLog ~= true then
        local dataTab = {}
        dataTab.funName = "openLog"
        LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
		FishGI.isWirteLog = true;
    end
    FishGI.isLogin = false
    FishGF.waitNetManager(false,nil,"MSGC2SGetHallInfo")
    
    --玩家数据
    data.playerInfo.shareLinkUsed = data.shareLinkUsed
    data.playerInfo.inviteCodeUsed = data.inviteCodeUsed
    data.playerInfo.vipDailyRewardToken = data.vipDailyRewardToken
    self:OnPlayerInfo(data.playerInfo)

    --大厅公告
    --data.announce.msgType = FishCD.ViewMessageType.HALL_ACCOUNT
    self:OnAnnounce(data.announce)

    --未读邮件
    self:OnUnreadMail(data.unreadMails)

    --首次登录
    local data2 = {}
    data2.msgType = FishCD.ViewMessageType.HALL_HALL_INFO
    data2.firstLogin = data.firstLogin
    FishGI.hallScene:receiveNetData(data2)
    
    self:sendToGetTimeHourglass({})
    if FishGI.hallScene.loadingLayer ~= nil and not FishGI.hallScene.loadingLayer:isVisible() then
        --刷新朋友场状态
        FishGI.hallScene:getGameNetData()
    end

    if FishGI.isWechatShare == true then
        self:sendGetShareReward()
    end

    self:OnFriendOpen(data)

end

--大厅朋友场是否开放
function AllocSitRoomManager:OnFriendOpen(data)
    local mailData = {}
    mailData.msgType = FishCD.ViewMessageType.HALL_ISOPEN_FRIEND_ROOM
    mailData.isFriendOpen =  data.isFriendOpen
    mailData.friendOpenTime =  data.friendOpenTime
    FishGI.hallScene:receiveNetData(mailData)
end

--大厅未读邮件
function AllocSitRoomManager:OnUnreadMail(data)
    local mailData= {}
    mailData.msgType = FishCD.ViewMessageType.HALL_UNREADMAILS
    mailData.unreadMails =  data
    FishGI.hallScene:receiveNetData(mailData)

end

--大厅未读邮件正文
function AllocSitRoomManager:OnGetMailDetail(data)
    FishGF.waitNetManager(false,nil,"MSGC2SGetMailDetail")
    data.msgType = FishCD.ViewMessageType.HALL_MAILS_DATA
    FishGI.hallScene:receiveNetData(data)
end

--大厅邮件正文标记已读
function AllocSitRoomManager:OnMarkMailAsRead(data)
    FishGF.waitNetManager(false,nil,"MSGC2SMarkMailAsRead")
    data.msgType = FishCD.ViewMessageType.HALL_MARK_MAILS_READ
    FishGI.hallScene:receiveNetData(data)
end

--大厅公告
function AllocSitRoomManager:OnAnnounce(data)
    data.msgType = FishCD.ViewMessageType.HALL_ACCOUNT;
    FishGI.hallScene:receiveNetData(data);
end

--商店买东西
function AllocSitRoomManager:OnBuyProp(data)
    FishGF.waitNetManager(false,nil,"MSGC2SBuy")
    data.msgType = FishCD.ViewMessageType.HALL_BAG_BUY;
    FishGI.hallScene:receiveNetData(data);
end

--大厅签到
function AllocSitRoomManager:OnSignIn(data)
    data.msgType = FishCD.ViewMessageType.HALL_SIGNIN;
    FishGI.hallScene:receiveNetData(data);
end

--月卡领取
function AllocSitRoomManager:OnGetMonthCardReward(data)
    data.msgType = FishCD.ViewMessageType.HALL_MONTH;
    FishGI.hallScene:receiveNetData(data);
end

--玩家数据
function AllocSitRoomManager:OnPlayerInfo(data)
    data.msgType = FishCD.ViewMessageType.HALL_SET_PLAYER_INFO;
    data.account = FishGI.hallScene.net.userName;
    data.id = FishGI.hallScene.net.id;

    FishGI.hallScene:receiveNetData(data);
end

--登录转盘
function AllocSitRoomManager:OnLoginDraw(data)
    data.msgType = FishCD.ViewMessageType.HALL_DIAL_END;
    FishGI.hallScene:receiveNetData(data);
end

--VIP转盘
function AllocSitRoomManager:OnVipLoginDraw(data)
    data.msgType = FishCD.ViewMessageType.HALL_VIPDIAL_END;
    FishGI.hallScene:receiveNetData(data);
end

--申请救济金
function AllocSitRoomManager:OnAlmInfo(data)
    data.msgType = FishCD.ViewMessageType.HALL_ALM_INFO;
    FishGI.hallScene:receiveNetData(data);
end

--领取救济金
function AllocSitRoomManager:OnAlmResult(data)
    data.msgType = FishCD.ViewMessageType.HALL_ALM_RESULT;
    FishGI.hallScene:receiveNetData(data);
end

--微信分享
function AllocSitRoomManager:OnGetShareRewardResult(data)
    data.msgType = FishCD.ViewMessageType.HALL_WECHAT_SHARE_RESULT;
    FishGI.hallScene:receiveNetData(data);
end

--好友邀请
function AllocSitRoomManager:OnInviteCodeResult(data)
    data.msgType = FishCD.ViewMessageType.HALL_INVITE_RESULT;
    FishGI.hallScene:receiveNetData(data);
end

--修改昵称
function AllocSitRoomManager:OnChangeNickName(data)
    print("------OnChangeNickName-----")
    FishGF.waitNetManager(false,nil,"MSGC2SChangeNickName")
    data.msgType = FishCD.ViewMessageType.HALL_CHANGE_NICK;
    FishGI.hallScene:receiveNetData(data);   
end

--锻造
function AllocSitRoomManager:OnForged(data)
    print("------OnForged-----")
    FishGF.waitNetManager(false,nil,"MSGC2SForge")
    data.msgType = FishCD.ViewMessageType.HALL_FORGED;
    FishGI.hallScene:receiveNetData(data);   
end

--锻造分解
function AllocSitRoomManager:OnDecompose(data)
    print("------OnDecompose-----")
    FishGF.waitNetManager(false,nil,"MSGC2SDecompose")
    data.msgType = FishCD.ViewMessageType.HALL_DECOMPOSE;
    FishGI.hallScene:receiveNetData(data);   
end

--奖券兑换话费
function AllocSitRoomManager:OnReceivePhoneFare(data)
    print("------OnReceivePhoneFare-----")
    FishGF.waitNetManager(false,nil,"MSGC2SReceivePhoneFare")
    data.msgType = FishCD.ViewMessageType.HALL_RECEIVE_PHONE_FARE;
    FishGI.hallScene:receiveNetData(data);   
end

function AllocSitRoomManager:onGetTaskInfoResult(data)
    print("---onGetTaskInfoResult")
    FishGF.waitNetManager(false,nil,"MSGC2SGetAllTaskInfo")
    FishGI.eventDispatcher:dispatch("onGetTaskInfoResult", data)
end

function AllocSitRoomManager:onTaskRewardResult(data)
    print("---onTaskRewardResult")
    FishGI.eventDispatcher:dispatch("onTaskRewardResult", data)
end

function AllocSitRoomManager:onActiveReward(data)
    print("---onActiveReward")
    FishGI.eventDispatcher:dispatch("onActiveReward", data)
end

function AllocSitRoomManager:onTaskFinished(data)
    print("---onTaskFinished")
    FishGI.eventDispatcher:dispatch("onTaskFinished", data)
end

function AllocSitRoomManager:onTimehourConsume(data)
    log("--onOnTimehourComsume--")
end

function AllocSitRoomManager:onGetPlayerTimehourInfo(data)
    log("--onGetPlayerTimehourInfo--")
    for k,v in pairs(data) do
        log(k,v)
    end

    FishGI.isCurTimehour = data.isSuccess
    FishGI.timehourRemain = data.nTimeRemain
    FishGI.timehourGlodCount = data.nFishIcon
end

--使用限时炮台
function AllocSitRoomManager:onUsePropCannon(data)
    print("--onUsePropCannon--")
    FishGF.waitNetManager(false,nil,"UsePropCannon")
    FishGI.eventDispatcher:dispatch("onUsePropCannon", data)

end

--出售
function AllocSitRoomManager:onSellItem(data)
    print("--onSellItem--")
    FishGF.waitNetManager(false,nil,"SellItem")
    FishGI.eventDispatcher:dispatch("onSellItem", data)

end

function AllocSitRoomManager:dontEnterRoom(data)
    if FishGI.hallScene.loadingLayer ~= nil then
        FishGI.hallScene.loadingLayer:closeAllSchedule();
    end
    self:ExitRoom();
    FishGI.hallScene.net:CloseSocket();
    FishGI.hallScene = nil;
    FishGI.mainManagerInstance:createLoginManager();
    FishGI.isTestAccount = true;

end

function AllocSitRoomManager.getDeskID()
    print("23132");
end

function evt.OnGamePreInitialize(room)
    if GameClient == nil then
        print("GameClient is nil")
    end
end

function evt.Initialize(room)
    print("000.0")
    
	return true
end

--进入房间成功
function evt.OnMsgJoinRoom(room)
    print("RoomManager OnMsgJoinRoom")
    FishGF.waitNetManager(false,nil,"sendDataGetDesk")
    local player = room.playerself;
	if not room:StartGame() then
		printf("RoomManager 启动游戏失败");
		room:ExitRoom();
    else
	end
    
end

function evt.OnProcessMessage(obj, msg)
    local temp = msg:ReadInt();
    local temp1 = msg:ReadWord();
    print("msg:"..temp1);
end

--玩家离开房间
function evt.OnMsgPlayerLeave( room,player )
    FishGF.print("player leave hall");
end

function evt.Shutdown(obj)
    FishGF.print("hall roommamanger shutdown");
    if not FishGI.isNoticeClose then
        return;
    end

    if FishGI.isExitRoom == false and FishGI.isEnterBg == false then
        FishGF.print("hall roommamanger shutdown-----11");
        FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000036),"hallShutdown")
        FishGF.print("hall roommamanger shutdown-----22");
    else
        FishGF.print("hall roommamanger shutdown-----33");
        FishGI.isExitRoom = false;
    end
end


function evt.OnMsgSitDown(room,player)
end

function evt.OnStopGame(obj, gameclient)
    print("hallmanager ");
end


--以下函数可选择实现
--[[系统消息
function e.OnSystemMessage( room,msgtype,msg )
	
end
]]

return AllocSitRoomManager;

--endregion