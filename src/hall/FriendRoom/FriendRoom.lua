
local FriendRoom = class("FriendRoom", cc.load("mvc").ViewBase)

FriendRoom.AUTO_RESOLUTION   = true
FriendRoom.RESOURCE_FILENAME = "ui/hall/friend/uifriendroom"
FriendRoom.RESOURCE_BINDING  = {
    ["node_fr_btn"]     = { ["varname"] = "node_fr_btn"  },
    ["node_friendroom"] = { ["varname"] = "node_friendroom"  },
    
    ["panel_create"]    = { ["varname"] = "panel_create"} , 
    ["panel_enter"]     = { ["varname"] = "panel_enter"  },    
    
    ["btn_back"]        = { ["varname"] = "btn_back" ,         ["events"]={["event"]="click",["method"]="onClickback"}}, 
    
    ["btn_rule"]        = { ["varname"] = "btn_rule" ,         ["events"]={["event"]="click_color",["method"]="onClickrule"}}, 
    ["btn_record"]      = { ["varname"] = "btn_record" ,       ["events"]={["event"]="click_color",["method"]="onClickrecord"}}, 
    ["btn_prop_1001"]   = { ["varname"] = "btn_prop_1001" ,      ["events"]={["event"]="click_color",["method"]="onClickprop_1001"}}, 
    ["btn_prop_13"]     = { ["varname"] = "btn_prop_13" ,      ["events"]={["event"]="click_color",["method"]="onClickprop_13"}}, 

}

--左边的按键
FriendRoom.LEFT_BTN  = {
    [1]  = { ["varname"] = "btn_rule"}, 
    [2]  = { ["varname"] = "btn_record"}, 
    [3]  = { ["varname"] = "btn_prop_1001"},   
    [4]  = { ["varname"] = "btn_prop_13"},   
}

function FriendRoom:onCreate( ... )
    self.node_friendroom:setScale(self.scaleMin_)
    self.propData = {}
    self.isShow = nil
    self.curType = 0 --0没有状态   1.创建    2.加入
    FishGI.FRIEND_ROOMNO = nil
    self:setIsCurShow(false)
    self:openTouchEventListener(false)

    local node_fish_create = self.panel_create:getChildByName("node_fish")
    node_fish_create.animation:play("roomact", true);

    local node_fish_enter = self.panel_enter:getChildByName("node_fish")
    node_fish_enter.animation:play("roomact", true);

    self:updatePropData(13,0)
    self:updatePropData(1001,0)
end

function FriendRoom:onTouchBegan(touch, event)
    if self.isShow then
        return true
    end
    return false  
end

function FriendRoom:onTouchEnded(touch, event)
    print("-----panel_onTouchEnd-------")
    local curPos = touch:getLocation()
    local s1 = self.panel_create:getContentSize()
    local locationInNode1 = self.panel_create:convertToNodeSpace(curPos)
    local rect1 = cc.rect(0,0,s1.width,s1.height)
    local curType = 0
    if cc.rectContainsPoint(rect1,locationInNode1) then
        print("-----panel_create-------")
        --self:createFriendRoom()
        local resuleData = self:isAllowCreate()
        if  resuleData ~= nil then
            self.costData = resuleData
            curType = 1
        else
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then --ok
                    FishGI.hallScene.uiBagLayer:showLayer() 
                    FishGI.hallScene.uiBagLayer:setRightPropData(FishCD.PROP_TAG_13)
                end
                FishGF.backToHall( )
            end
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000285),callback, nil)
        end
    end

    local s2 = self.panel_enter:getContentSize()
    local locationInNode2 = self.panel_enter:convertToNodeSpace(curPos)
    local rect2 = cc.rect(0,0,s2.width,s2.height)
    if cc.rectContainsPoint(rect2,locationInNode2) then
        print("-----panel_enter-------")
        curType = 2
        --FishGI.hallScene.uiJoinRoom:showLayer()
    end

    if curType == 1 then
        local playerKey = "FriendCost"..FishGI.myData.playerId
        local isFriendNoticeCost = cc.UserDefault:getInstance():getBoolForKey(playerKey)
        if not isFriendNoticeCost then
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    self.curType = curType
                    self.friendRoomNo = nil
                    self.friendGameId = nil
                    FishGI.FriendRoomManage:sendGetFriendStatus();
                    cc.UserDefault:getInstance():setBoolForKey(playerKey,isFriendNoticeCost)
                    cc.UserDefault:getInstance():flush()
                elseif tag == 4 then
                    isFriendNoticeCost = not isFriendNoticeCost
                    sender:getChildByName("spr_hook"):setVisible(isFriendNoticeCost)
                end
            end
            local str = FishGF.getChByIndex(800000306)
            local strHook = FishGF.getChByIndex(800000307)
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE_HOOK,str,callback,nil,strHook)
            return
        end
    end

    if curType ~= 0 then
        self.curType = curType
        self.friendRoomNo = nil
        self.friendGameId = nil
        FishGI.FriendRoomManage:sendGetFriendStatus();
    end

end

--判断是否能创建房间
function FriendRoom:isAllowCreate( )
    local resuleData = nil
    --判断限时房卡是否有以及能用
    local playerData = FishGMF.getPlayerData(FishGI.myData.playerId)
    local limitCardS = playerData.seniorProps[tostring(FishCD.PROP_TAG_15)]
    if limitCardS ~= nil then
        for k,v in pairs(limitCardS) do
            local time = v.stringProp
            local date = os.date("%Y-%m-%d");
            if date == time then
                return v
            end
        end
    end

    --普通房卡
    local roomCardCount = playerData["props"][tostring(FishCD.PROP_TAG_13)]
    if roomCardCount ~= nil and roomCardCount > 0 then
        local data = {}
        data.propId = FishCD.PROP_TAG_13
        resuleData = data
    end

    return resuleData

end

--设置是否返回大厅
function FriendRoom:setIsCurShow( isShow )
    if isShow == self.isShow then
        return
    end

    for k,v in pairs(self.LEFT_BTN) do
        local node = self[v.varname]
        FishGF.setNodeIsShow(node,"left",isShow)
    end
    FishGF.setNodeIsShow(self.btn_back,"up",isShow)
    FishGF.setNodeIsShow(self.node_friendroom,"up",isShow ,display.height)

    if not isShow then
        self.curType = 0
        self.friendRoomNo = nil
        self.friendGameId = nil
    end

    self.isShow = isShow

end

--返回
function FriendRoom:onClickback( sender )
    print("onClickback")

    FishGI.hallScene:setIsToFriendRoom(false)

    --返回原来的服务器
    FishGF.backToHall( )
    
end

--返回普通场大厅
function FriendRoom:backToHall(  )
    FishGF.print("------FriendRoom:backToHall-返回普通场大厅-----")
    --返回原来的服务器
    if FishGI.FRIEND_ROOM_STATUS ~= 0 then
        FishGI.FRIEND_ROOM_STATUS = 4
        FishGI.FRIEND_ROOMID = nil
        FishGI.isExitRoom = true
        self.curType = 0
        FishGI.hallScene.net:dealloc();
        FishGI.loginScene.net:DoAutoLogin();
    end
end

--规则介绍
function FriendRoom:onClickrule( sender )
    print("onClickrule")
    FishGI.hallScene.uiRuleIntroduction:showLayer()
end

--历史记录
function FriendRoom:onClickrecord( sender )
    print("onClickrecord")
    FishGI.FriendRoomManage:sendGetFriendHistory()
end

--临时房卡
function FriendRoom:onClickprop_1001( sender )
    print("onClickprop_1001")
    if self.propData[FishCD.PROP_TAG_15] ~= nil and self.propData[FishCD.PROP_TAG_15] > 0 then
        FishGF.showSystemTip(nil,800000234,3)
    else
        FishGI.hallScene.uiMonthcard:showLayer()
    end
    
end

--房卡
function FriendRoom:onClickprop_13( sender )
    print("onClickprop_13")
    FishGI.hallScene.uiBagLayer:showLayer() 
    FishGI.hallScene.uiBagLayer:setRightPropData(FishCD.PROP_TAG_13)

end

--创建朋友场
function FriendRoom:createFriendRoom(  )
    print("createFriendRoom")
    self.curType = 1
    self.friendRoomNo = nil
    self.friendGameId = nil
    FishGI.FriendRoomManage:sendGetFriendStatus();
end

--进入朋友场
function FriendRoom:enterFriendRoom( friendRoomNo ,friendGameId)
    print("enterFriendRoom")
    self.friendRoomNo = friendRoomNo
    self.friendGameId = friendGameId
    self.curType = 2
    --FishGI.FriendRoomManage:sendGetFriendStatus();
    self:OnChangeFriendServery(self.serverList)
    
end

--获取朋友场状态
function FriendRoom:onGetFriendStatus( netData )
    print("onGetFriendStatus")
    local data = netData
    local errorCode = netData.errorCode
    local friendStatus = netData.friendStatus
    local unreadFriendGameId = netData.unreadFriendGameId
    self.serverList = netData.serverList

    if friendStatus == 1 then           --上一场未开始
        self:unStartFriend(netData)

    elseif friendStatus == 2 then       --正在游戏中
        self:playingFriend(netData)

    elseif friendStatus == 3 then       --上一场未结算
        self:leaveFriend(netData)

    elseif friendStatus == 4 and unreadFriendGameId ~= "" then       --不在游戏中,有未读
        self:unreadFriend(netData)
    elseif friendStatus == 4 and unreadFriendGameId == "" then       --不在游戏中
        self:freeFriend(netData)

    end

end

--选择服务器
function FriendRoom:choseServer(serverList)
    local serverList = serverList
    if #serverList <=0 then
        return nil
    end
    
    local roomId = nil
    if self.curType == 1 then
        --创建房间随机进入
        local index = math.random(1,#serverList)
        roomId = serverList[index].roomId
    elseif self.curType == 2 then
        --加入房间，筛选房间
        local friendRoomNo =  self.friendRoomNo
        local prefix = string.sub(friendRoomNo,0,2);
        for k,val in pairs(serverList) do
            if val.prefix == prefix then
                roomId = val.roomId
                break
            end
        end
    end

    return roomId

end

--切换服务器创建房间
function FriendRoom:OnChangeFriendServery(serverList)

    local roomId = self:choseServer(serverList)
    if roomId == nil then
        if self.curType == 1 then
            FishGF.showToast(FishGF.getChByIndex(800000298))
        elseif self.curType == 2 then
            local str = FishGF.getChByIndex(800000286)
            if #serverList <=0 then
                str = FishGF.getChByIndex(800000298)
            end
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 0 then
                    self.curType = 2
                    self.friendRoomNo = nil
                    self.friendGameId = nil
                    FishGI.FriendRoomManage:sendGetFriendStatus();                
                end
            end   
            FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,str,callback);
        end
        return
    end
    FishGF.print("-------------------------FishGI.FRIEND_ROOMID--roomId="..roomId)
    FishGI.FRIEND_ROOM_STATUS = self.curType
    if FishGI.FRIEND_ROOMID == nil or FishGI.FRIEND_ROOMID ~= roomId then
        FishGF.waitNetManager(true,nil,"ChangeServery")
    end
    self.curType = 0
    FishGI.FRIEND_ROOMID = roomId
    FishGI.isExitRoom = true
    FishGI.hallScene.net:dealloc();
    FishGI.loginScene.net:DoAutoLogin();

end

--服务器准备好了
function FriendRoom:OnFriendServerReady(data)
    print("-----FriendRoom-OnFriendServerReady-----")
   if FishGI.FRIEND_ROOM_STATUS == 1 and not FishGI.hallScene.uiCreateSuceed:isVisible() then
        --申请创建房间
        FishGI.FriendRoomManage:sendCreateFriendRoom()

   elseif FishGI.FRIEND_ROOM_STATUS == 2 then
        --直接加入房间
        self:sendJoinFriendRoom()
   end
end

--创建朋友场
function FriendRoom:OnCreateFriendRoom(netData)
    print("-----FriendRoom-OnCreateFriendRoom-----")
    local success = netData.success
    local friendRoomNo = netData.friendRoomNo
    local deskId = netData.deskId

    if success then
        self.friendRoomNo = friendRoomNo
        --弹出提示面板
        FishGI.hallScene.uiCreateSuceed:setRoomNo(friendRoomNo)
        FishGI.hallScene.uiCreateSuceed:showLayer()

        --界面减个数
        if self.costData ~= nil then
            local propId = self.costData.propId
            if propId == FishCD.PROP_TAG_13 then 
                FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,propId,-1,true)
            elseif propId == FishCD.PROP_TAG_15 then 
                FishGMF.refreshSeniorPropData(FishGI.myData.playerId,self.costData,3,0)
            end 
        end

        return
    end

    local errorCode = netData.errorCode
    if errorCode == 1 then                 --已经在房间
        FishGF.showToast(FishGF.getChByIndex(800000283))
    elseif errorCode == 2 then             --无可用房间
        FishGF.showToast(FishGF.getChByIndex(800000284))
    elseif errorCode == 4 then             --朋友场服务器已关闭
        FishGF.showToast(FishGF.getChByIndex(800000298))
    elseif errorCode == 3 then             --无房卡
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then --ok
                FishGI.hallScene.uiBagLayer:showLayer() 
                FishGI.hallScene.uiBagLayer:setRightPropData(FishCD.PROP_TAG_13)
            end
            FishGF.backToHall( )
        end
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000285),callback, nil)
    end
end

--申请加入朋友场
function FriendRoom:sendJoinFriendRoom()
    print("-----FriendRoom-sendJoinFriendRoom-----")  
    FishGI.FRIEND_ROOMNO = self.friendRoomNo
    FishGI.FriendRoomManage:sendJoinFriendRoom(self.friendRoomNo,self.friendGameId)

end

--加入朋友场结果
function FriendRoom:OnJoinFriendRoom(data)
    print("-----FriendRoom-OnJoinFriendRoom-----")
    local success = data.success
    if success then
        FishGI.FRIEND_ROOMNO = self.friendRoomNo
        return
    -- else
    --     FishGI.FRIEND_ROOMNO = nil
    --     --返回正常服务器
    --     FishGF.backToHall( )
    end

    local str = ""
    local errorCode = data.errorCode
    if errorCode == 1 then              --桌子不存在
        str = FishGF.getChByIndex(800000286)
    elseif errorCode == 2 then             --游戏已开始
        str = FishGF.getChByIndex(800000287)
    elseif errorCode == 3 then           --游戏已结束
        str = FishGF.getChByIndex(800000288)
    elseif errorCode == 4 then           --玩家已经离开
        str = FishGF.getChByIndex(800000289)
    elseif errorCode == 5 then           --桌子已经满了
        str = FishGF.getChByIndex(800000290)
    elseif errorCode == 6 then           --朋友场服务器已关闭
        str = FishGF.getChByIndex(800000298)
    else                                --未知错误
        FishGF.print("------errorCode="..errorCode)
        str = FishGF.getChByIndex(800000291)..errorCode
    end

    if FishGI.FRIEND_ROOM_STATUS == 1 then
        FishGF.showToast(str)
    elseif FishGI.FRIEND_ROOM_STATUS == 2 then
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 0 then
                self.curType = 2
                self.friendRoomNo = nil
                self.friendGameId = nil
                FishGI.FriendRoomManage:sendGetFriendStatus();                
            end
        end   
        FishGF.showMessageLayer(FishCD.MODE_MIN_OK_ONLY,str,callback);
    end

    FishGI.FRIEND_ROOMNO = nil
    --返回正常服务器
    FishGF.backToHall( )  

end



--==============================--
--desc:朋友场的状态处理
--time:2017-05-10 11:30:06
--==============================--


--有未开始的游戏中的朋友场处理   1
function FriendRoom:unStartFriend(netData)
    print("-----FriendRoom-unStartFriend-----")
    --重新加入或者解散
    local friendRoomNo = netData.friendRoomNo
    local friendGameId = netData.friendGameId
    local function callback(sender)
        local tag = sender:getTag()
        if tag == 2 then --ok
            --加入房间
            self.friendRoomNo = friendRoomNo
            self.friendGameId = friendGameId
            self.curType = 2
            self:OnChangeFriendServery(netData.serverList)

        elseif tag == 3 then --cancel
            --发送解散消息
            FishGI.FriendRoomManage:sendFriendLeaveGame(friendGameId)
        end
    end
    FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000248),callback, nil)

end

--有正在游戏中的朋友场处理    2
function FriendRoom:playingFriend(netData)
    print("-----FriendRoom-playingFriend-----")
    --重新加入或者主动退出
    local friendRoomNo = netData.friendRoomNo
    local friendGameId = netData.friendGameId
    local function callback(sender)
        local tag = sender:getTag()
        if tag == 2 then --ok
            --加入房间
            self.friendRoomNo = friendRoomNo
            self.friendGameId = friendGameId
            self.curType = 2
            self:OnChangeFriendServery(netData.serverList)

        elseif tag == 3 then --cancel
            --发送强退
            FishGI.FriendRoomManage:sendFriendLeaveGame(friendGameId)
        end
    end
    FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000249),callback, nil)


end

--有上一场未结算的朋友场处理    3
function FriendRoom:leaveFriend(netData)
    print("-----FriendRoom-leaveFriend-----")
    --稍等，不能加入或创建
    if self.isShow and self.curType ~= 0 then
        --弹出提示
        print("------稍等，不能加入或创建-----")
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000251),nil, nil)
        return
    end

end

--有结算未读的朋友场处理  4
function FriendRoom:unreadFriend(netData)
    print("-----FriendRoom-unreadFriend-----")
    --一定查看，是否弹面板自己处理
    local friendRoomNo = netData.friendRoomNo
    local friendGameId = netData.unreadFriendGameId
    local function callback(sender)
        local tag = sender:getTag()
        if tag == 2 then --ok
            --设置已读，查询详细信息
            FishGI.FriendRoomManage:sendGetFriendDetail(friendGameId)
            FishGI.FriendRoomManage:sendFriendMarkAsRead(friendGameId)
            FishGI.FriendRoomManage:sendGetFriendHistory()
        elseif tag == 3 then --cancel
            --设置已读
            FishGI.FriendRoomManage:sendFriendMarkAsRead(friendGameId)
        end
    end
    FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000250),callback, nil)

end

--正常，不在游戏中  4
function FriendRoom:freeFriend(netData)
    print("-----FriendRoom-freeFriend-----")

    --在朋友场场景内加入游戏或者创建游戏
    if self.isShow then
        if self.curType == 1 then
            --切换服务器创建房间
            self:OnChangeFriendServery(netData.serverList)
        elseif self.curType == 2 then
            -- 弹出输入面板
            FishGI.hallScene.uiJoinRoom:showLayer()
        end
    end
end

--更新道具数量
function FriendRoom:updatePropData(propId,showCount)
    self.propData[propId] = showCount
    local node = self["btn_prop_"..propId]
    if node ~= nil then
        local fnt = node:getChildByName("fnt_count")
        fnt:setString(showCount)
    end
end

return FriendRoom;