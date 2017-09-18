
local evt = {}
--创建大厅管理器类
local HallNet = FishGF.ClassEx("HallNet", function() 
    local  obj = CHallManager.New();
    obj.event= evt;
    return obj ;
end );

function HallNet.create()
    local net = HallNet.new();
    if net:Initialize() then
        return net;
    else
        return nil;
    end
end

function HallNet:setView(view)
    self.view = view;
end

function HallNet:initRoomConfig()
    self.roomId = FishGI.serverConfig["RoomId"];
end

function HallNet:dealloc()
    FishGF.print("hall net dealloc");
    if self.roommanager ~= nil then
        self.roommanager:Shutdown()
        self.roommanager = nil
    end
    self:Shutdown();
    self:CloseSocket();
end

--创建LUA游戏客户端
function HallNet:CreateLuaGameClient(shortname)
    --local temp4 = Helper;
    --local GameClientCreator = require("Other/FileTable").New():Open(Helper.writepath.."src/Game/GameScene");
    --local creator = GameClientCreator[shortname];
    --if creator == nil then return end;
	--测试文件是否存在
    local fullPath = "src/Game/GameNet.lua";
    local hotUpdatePath = cc.FileUtils:getInstance():getWritablePath().."src/Game/GameNet.lua"
    if cc.FileUtils:getInstance():isFileExist(hotUpdatePath) then
        fullPath = hotUpdatePath;
    end
    
    if FishGI.FRIEND_ROOM_STATUS ~= 0 then
        print("---------------------创建朋友场LUA游戏客户端--------------")
        hotUpdatePath = cc.FileUtils:getInstance():getWritablePath().."src/Game/Friend/GameFriendNet.lua"
        if cc.FileUtils:getInstance():isFileExist(hotUpdatePath) then
            print("writable path exist "..hotUpdatePath)
            fullPath = hotUpdatePath;
        else
            fullPath = "src/Game/Friend/GameFriendNet.lua";
        end
        
    end
    
	if not cc.FileUtils:getInstance():isFileExist(fullPath) then
		printf("\""..fullPath.."\"文件不存在！");
		return ;
	end
	local gameclient= CLuaGameClient.New();
	if gameclient then

		gameclient:SetClientInfo(self.roommanager, fullPath);
    else
        print("create lua gameclient fail")
	end
    
	return gameclient;

end

function HallNet:joinRoom(roomid,bReconnect)
    print(roomid);
    local roomManager = require("hall/AllocSitRoomManager").create(self, roomid);
    self.roommanager =  roomManager;
    self:SendJoinRoom(roomid); --发送进入房间消息 
end

function HallNet:enterGame(roomID)
    if FishGI.enterCount == nil then
        FishGI.enterCount = 0
    end
    FishGI.enterCount = FishGI.enterCount + 1
    FishGF.print("-----------------------------------------------------------------------------------")
    FishGF.print("-----------------------------------------------------------------------------------")
    FishGF.print("-----------------HallNet------------enterGame ="..FishGI.enterCount.." ----------------------------------")
    FishGF.print("-----------------------------------------------------------------------------------")
    FishGF.print("-----------------------------------------------------------------------------------")

    self.roomLv = roomID;
    if self.roommanager ~= nil then
        self.roommanager:sendDataGetDesk(roomID);
    else
        FishGF.print("roommanager is nil");
    end
end

--加入指定ID的游戏 显示房间列表
function HallNet:joinGame( gameid , ui )
	local  game = self.games[gameid];
    return true;
end

function HallNet:getSession()
    return self.session;
end

function HallNet:selectRoom(rooms)
    local room = nil;
    local roomIdTab = {};
    for key, val in pairs(rooms) do
        if val.gameid == GAME_ID and (val.cmd.friend == nil or val.cmd.friend ~="1") then
            table.insert(roomIdTab, key);
        end
    end
    local roomIndex = math.random(1,table.maxn(roomIdTab));
    room = rooms[roomIdTab[roomIndex]];

    if room == nil then
        for key, val in pairs(rooms) do
            if val.gameid == GAME_ID then
                room = val;
            end
        end
    end

    return room;
end

function HallNet:enterRoom(roomLv)
    print("-HallNet-enterRoom----")
    FishGF.waitNetManager(false,nil,"startConnect")
    FishGI.isLogin = false
    --进入房间
    local room = nil
    local roomId = self.roomId
    if FishGI.FRIEND_ROOM_STATUS ~= 0 and FishGI.FRIEND_ROOM_STATUS ~= 4 then
        roomId = FishGI.FRIEND_ROOMID
    end

    if FishGI.FRIEND_ROOM_STATUS == 4 or FishGI.FRIEND_ROOMID == nil then
        self:initRoomConfig()
        roomId = self.roomId
    end

    FishGF.print("------------------------------FishGI.FRIEND_ROOM_STATUS ~= 0---------------------------------roomId="..roomId)

    if tonumber(FishGI.SYSTEM_STATE) == 0 then
        roomId = require("Other/AllocRoomStrategy").create():getRoomsIndexTab(self.rooms, HALL_WEB_VERSION, CHANNEL_ID);
        if roomId == nil then
           FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000301),"nohallroom")
           return 
        end
        if FishGI.FRIEND_ROOM_STATUS ~= 0 and FishGI.FRIEND_ROOM_STATUS ~= 4 then
            roomId = FishGI.FRIEND_ROOMID
        end
        print("select room id:"..roomId);
        room = self.rooms[roomId];
    elseif tonumber(FishGI.SYSTEM_STATE) == 3 then
        room = self.rooms[527];
    else
        local rooms = self.rooms
        room = self.rooms[roomId];
    end

    self.roomId = roomId
    if room and self:joinGame(room.gameid) then
        FishGF.waitNetManager(true,FishGF.getChByIndex(800000163),"joinGame")
		self:joinRoom(room.id);
    else
        FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000301),"nohallroom")
	end	
end

--------------------------------------------------网络协议事件回调
--管理器初始化，返回true成功，否则失败
function evt.Initialize(hallobj)
    print("hall Initialize");
    hallobj.netMsgTab = FishCD.ViewMessageType;
    hallobj:initRoomConfig();
    print("hall Initialize:true");
    return true;
end

function evt.Shutdown(hall)
    print("hall Shutdown");
end

function evt.OnConnect( obj,bConnected )
    print("hall OnConnect");
    if bConnected then 
        print("success") 
    else
        if FishGI.hallScene ~= nil then
            if FishGI.hallScene.doAutoLogin ~= nil then
                FishGI.hallScene:doAutoLogin()
            end
        end
        
    end
end

function evt.OnExitRoom(obj)
    local scene = FishGI.hallScene
    print("hall OnExitRoom");
end

function evt.OnMsgLogout(obj)
    print("hall OnMsgLogout");
end

function evt.OnSystemMessage(obj,msg,msgtype)
    FishGF.print("hall OnSystemMessage");
end

--与大厅服务器连接断开
function evt.OnSocketClose( obj,nErr ) 
    if FishGI.isEnterBg then
        return;
    end

    if not FishGI.isNoticeClose then
        return;
    end
    --FishGF.waitNetCallback(false);
    print("hall OnSocketClose error code:"..nErr);
    local curScene = cc.Director:getInstance():getRunningScene();
    local sceneName = curScene.sceneName
    if sceneName == "hall" then
        FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000036),"hallOnSocketClose")
    elseif sceneName == "game" then
        FishGF.doMyLeaveGame(9)
    end
    
    print("与大厅服务器连接断开，请重新登录0")
    --FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000036),"hallOnSocketClose")
end

--[[
* @brief 登陆到大厅成功
* @param hall 大厅对象
* @param lastroomid 最后断线房间ID，如果为0，则非断线重连状态
--]]
function evt.OnJoinHall( hall,lastroomid )
    FishGF.print("lastroomid :"..lastroomid);
    
    print("hall OnJoinHall");
    local userData = hall.userinfo;
    hall.userName = userData.nick;
    hall.id = userData.id;
    if not IS_LOCAL_TEST then
        FishGI.WebUserData:initWithUserId(userData.id);

        if CHANNEL_ID == CHANNEL_ID_LIST.jrtt then
            local function callback()
            end
            FishGI.Dapi:JrttStatistics(callback);
        end
    end
    --数据发到Layer那边
    --userData.msgType = hall.netMsgTab.HALL_SET_PLAYER_INFO;
    --hall.view:receiveNetData(userData);

    local account,password,isVisitor = FishGF.getAccountAndPassword()
    if account ~= nil and account ~= "" then
        hall.userName = account
        local AccountTab = {}
        AccountTab["account"] = account
        AccountTab["password"] = password
        AccountTab["isVisitor"] = isVisitor
        local count = FishGI.WritePlayerData:getMaxKeys()
        local maxCount = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000046), "data"))
        if count >= maxCount then
            FishGI.WritePlayerData:removeByKey(1)
        end
        FishGI.WritePlayerData:upDataAccount(AccountTab)
    end
    if isVisitor ~= nil and isVisitor ~= "" then 
        hall.userName = isVisitor
    end
    --FishGF.setAccountAndPassword("","")

    if lastroomid ~= 0 then
        FishGF.print("reconnect ");
        hall.roomId = lastroomid;
        hall:enterRoom(1);
    else
        hall:enterRoom(1);
    end
   
end

--[[
* @brief 登陆到大厅失败
]]
function evt.OnJoinHallFailed( hall,result )
    print("hall OnJoinHallFailed");
    FishGF.waitNetManager(false,nil,"startConnect")
    FishGI.isLogin = false
    
    local str = nil
    if result == 1 then
        --玩家已经登陆
        print("玩家已经登陆");
        str = FishGF.getChByIndex(800000035)
       -- FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000035),nil) 
    else
        print("登陆失败，请联系客服 4008-323-777 ,[错误码:"..result.."]!");
        str = FishGF.getChByIndex(800000034)..result
        --FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000034)..result,nil) 
    end
    --跑出对应的弹出框 确定 取消 回调到相应的函数处理

    FishGF.createCloseSocketNotice(str,"OnJoinHallFailed")

end

--[[function evt.OnSocketClose(hall,result)
    FishGF.print("on socket close result"..result);
end]]--

--[[
* @brief 进入房间应答
* param [in] result 进入房间结果,为0则成功
* param [in] lockedroomid 仅玩家已经在房间中时，该参数有意义
]]
function evt.OnMsgJoinRoom(hall,result,lockedroomid)
    if lockedroomid ~= nil then
        FishGF.print("lockedroomid: "..lockedroomid);
    end
    FishGF.waitNetManager(false,nil,"joinGame")
    
    print("hall OnMsgJoinRoom");
    local strMsg = nil
    print("OnMsgJoinRoom result"..result);
    if result == 0 then
        FishGI.connectCount = 0
        --进入房间成功 马上获取房间数据
        if FishGI.FRIEND_ROOM_STATUS == 0 then
            FishGI.hallScene:firstInit()
            cc.Director:getInstance():pushScene(FishGI.hallScene);
            FishGI.hallScene:release();
            hall.roommanager:sendDataGetInfo();
            
        elseif FishGI.FRIEND_ROOM_STATUS == 4 then
            hall.roommanager:sendDataGetInfo();
        end
        FishGI.hallScene:startLoad()
        print("-----------------------------token:"..hall:getSession());
    elseif result == 1 then
        --玩家在房间
        local room = hall.rooms[lockedroomid];
        if room == nil then
            print("进入房间失败，同一时刻只能进入一个房间!");
            strMsg = FishGF.getChByIndex(800000037)
        else
            print("您已经在房间["..hall.games[room.gameid].name .."-"..room.name.."]内，暂时无法进入其他房间!");
            strMsg = FishGF.getChByIndex(800000036)--..hall.games[room.gameid].name .."-"..room.name..FishGF.getChByIndex(800000039)
        end

    elseif result == 2 or result == 3 then
        --房间满人 --另外找其他房间 直到所有房间都找遍 还没有就提示服务器已满
        print("房间满人");
        strMsg = FishGF.getChByIndex(800000040)
    elseif result == 4 then
        --房间有权限要求
        print("没有进入房间的权限");
        strMsg = FishGF.getChByIndex(800000041)
    elseif result == 5 then 
        --金钱或者积分不够
        print("金钱或者积分不够");
        strMsg = FishGF.getChByIndex(800000042)
    elseif result == 6 then 
        print("金钱或者积分太高 推荐他去更高的房间");
        strMsg = FishGF.getChByIndex(800000043)
    elseif result == 7 then 
        --房间限制进入（一般是临时维护或者时间没到)
        print("房间限制进入");
        strMsg = FishGF.getChByIndex(800000044)
    elseif result == 8 then
        print("该房间不存在或者已关闭，请尝试进入其他房间");
        strMsg = FishGF.getChByIndex(800000045)
        
    elseif result == 11 then
        print("报名费不够");
        strMsg = FishGF.getChByIndex(800000046)
        local room = hall.rooms[hall.roommanager:GetID()];
        local nDataType = tonumber(room.cmd.bmlx); --期待数据类型
        local strDataValue = room.cmd.bmf; --期待数据值
        if nDataType and strDataValue then --有数据要求
            if nDataType == PROP_ID_PK_TICKET then
                print("您背包中的参赛券不足"..strDataValue.."个，获取更多参赛券？");
                strMsg = FishGF.getChByIndex(800000047)..strDataValue..FishGF.getChByIndex(800000048)
            elseif nDataType == PROP_ID_MONEY then
                print("您携带的豆豆不足"..strDataValue.."个，获取更多豆豆？");
                strMsg = FishGF.getChByIndex(800000049)..strDataValue..FishGF.getChByIndex(800000050)
            elseif nDataType == PROP_ID_LOTTERY then
                print("您的元宝不足"..strDataValue.."个，报名失败!");
                strMsg = FishGF.getChByIndex(800000051)..strDataValue..FishGF.getChByIndex(800000052)
            elseif nDataType == PROP_ID_WEEK_PK_CARD then
                print("报名失败，您的周赛券不够！");
                strMsg = FishGF.getChByIndex(800000053)
            elseif nDataType == PROP_ID_MONTH_PK_CARD then
                print("您的决赛券不足，报名失败");
                strMsg = FishGF.getChByIndex(800000054)
            else
                print("您的报名费不足，报名失败!");
                strMsg = FishGF.getChByIndex(800000055)
            end
        else
            print("您的报名条件不足，报名失败！");
            strMsg = FishGF.getChByIndex(800000056)
        end
    elseif result == 12 then --当天输赢达到上限
        print("您今天的豆豆输赢已达上限,无法进入游戏");
        strMsg = FishGF.getChByIndex(800000057)
    else
        print("进入房间失败，未知错误，请联系客服 "..HOT_LINE);
        strMsg = FishGF.getChByIndex(800000058)..HOT_LINE
    end

    if strMsg == nil or strMsg == "" then
        print("-------strMsg=房间成功")
        return 
    end
    --FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,strMsg,nil) 
    local scene = cc.Director:getInstance():getRunningScene()
    if result == 9 or result == 1 then
        FishGI.connectCount = FishGI.connectCount +1
        if FishGI.connectCount > 5 then
            FishGI.connectCount = 0
            FishGF.createCloseSocketNotice(strMsg,"OnMsgJoinRoomconnectCount5")
            return
        end
        scene =FishGI.hallScene
        FishGI.hallScene:onAppEnterBackground();
        FishGI.hallScene:onAppEnterForeground();
        
    else
        FishGF.createCloseSocketNotice(strMsg,"OnMsgJoinRoom")
    end
    

end

--[[
* @brief 离开房间通知
* @param [in] 房间对象
]]
function evt.OnMsgLeaveRoom(hall,roommanager)
    --FishGF.print("hall OnMsgLeaveRoom gameid"..roommanager.gameid);
end

function evt.OnMsgRemoveRoom(hall,roomid)
    FishGF.print("hall OnMsgRemoveRoom :"..roomid);
    if roomid == hall.roomId then
        local curScene = cc.Director:getInstance():getRunningScene();
        local sceneName = curScene.sceneName
        if sceneName == "game" then
            FishGF.doMyLeaveGame(8)
        end
    end
end

--[[
* @brief 服务器强制帐号退出
* @brief reason 0 无原因;1用户重复登陆被挤；2：被服务器强行踢掉
* @note 在触发该函数时，网络已经被断开
]]
function evt.OnMsgLogout(hall,reason)
    FishGF.print("hall OnMsgLogout");
end

return HallNet;