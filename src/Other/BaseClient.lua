
--[[
* @file     base_client.lua
* @brief    游戏客户端基类
* @date     2016年09月06日
* @author   陈先寅
* @email    420373550@qq.com
--]]


local BaseClient = class("BaseClient")

--[[
* @brief 构造函数
--]]
function BaseClient:ctor()
  -- 初始化游戏事件
  self.mEvent = GameClient.event;

  -- 消息延迟队列
  self.mDelayMessage = { };

  -- 引用当前游戏对象
  GameClient.client = self;

  -- 玩家列表
  self.mPlayer = {};

  -- 注册基本消息
  self:RegisterMsgProcess("Initialize", self.OnInitialize);
  self:RegisterMsgProcess("Shutdown", self.OnShutdown);
  self:RegisterMsgProcess("OnPlayerJoin", self.OnPlayerJoinNative);
  self:RegisterMsgProcess("OnPlayerLeave", self.OnPlayerLeaveNative);
  self:RegisterMsgProcess("OnGameReset", self.OnGameReset);
  self:RegisterMsgProcess("printfMessage", self.OnMessage);
  self:RegisterMsgProcess("OnUserProp", self.OnUserProp);
  self:RegisterMsgProcess("OnUsePropFailed", self.OnUsePropFailed);
  self:RegisterMsgProcess("ShutdownGame", self.OnShutdownGame);
  self:RegisterMsgProcess("CreateGameScene", self.OnCreateScene);
  -- ÏûÏ¢´¦Àí´òÓ¡
  self.mEvent["OnProcessMessage"] = function(client, ...) self.OnProcessMessage(...) end;
end

--[[
* @brief 网络消息注册
* @param [in] msg 网络消息包，为CLuaMsgHeader对象
* @param [func] func 处理函数
--]]
function BaseClient:RegisterMsgProcess(msg, func, name)
    print("BaseClient RegisterMsgProcess");
  self.mEvent[msg] = function(client, ...)
--    print("[API] Enter MSG = " .. tostring(msg) .. ", " .. tostring(name));
    
    local ret = func(self, ...);
    
    return ret;
  end;
end

--[[
* @brief 游戏事件触发
* @param evt 事件名
--]]
function BaseClient:DispatchEvent(evt, ...)
  cc.exports.app:dispatchEvent(evt, ...);
end

--[[
* @brief 游戏事件注册
* @param evt 事件名
--]]
function BaseClient:RegisterEvent(evt, listener)
  cc.exports.app:addEventListener(evt, function(evt_, ...) listener(self, ...) end, self);
end

--[[
* @brief 发送数据(消息包,附带参数)
--]]
function BaseClient:SendData(msg, flag)
  GameClient:SendData(msg, flag or 0);
end

--[[
* @brief 发送数据(消息包,附带参数)
* @return 成功启动返回CLuaPlayer对象，否则返回空值
--]]
function BaseClient:FindPlayerByID(playerid)
  local player = GameClient:FindPlayerByID(playerid);
  return self.mPlayer[player.chairid + 1];
end

--[[
* @brief 根据座位号获得用户ID(绝对座位号)
* @return 成功启动返回CLuaPlayer对象，否则返回空值
--]]
function BaseClient:GetPlayerByChair(chairid)
  if chairid == 65535 then
    return nil;
  end

  return self.mPlayer[chairid + 1];
end

--[[
* @brief 通过UI座位号获取逻辑座位号
* @return 成功启动返回BasePlayer对象(或继承)，否则返回空值
--]]
function BaseClient:GetPlayerByUIChair(uichairid)
  return self.mPlayer[self:UIToChair(uichairid - 1) + 1];
end

--[[
* @brief 获得玩家自己
* @return 成功启动返回CLuaPlayer对象，否则返回空值
--]]
function BaseClient:GetPlayerSelf()
  if GameClient:GetPlayerSelf().chairid == 65535 then
    return self:CreatePlayer(GameClient:GetPlayerSelf(), true);
  else
    if nil ~= self.mPlayer[GameClient:GetPlayerSelf().chairid + 1] then
      return self.mPlayer[GameClient:GetPlayerSelf().chairid + 1];
    end

    return self:CreatePlayer(GameClient:GetPlayerSelf(), true, self:ChairToUI(GameClient:GetPlayerSelf().chairid) + 1);
  end
end

--[[
* @brief 起立，关闭客户端
--]]
function BaseClient:StandUP()
  GameClient:StandUP();
end

--[[
* @brief 离开房间，关闭客户端
--]]
function BaseClient:ExitRoom()
  --GameApp:removeEventListenersByTag(self)
  if GameClient ~= nil and GameClient.ExitRoom ~= nil then
    GameClient:ExitRoom();
  else
    FishGF.print("------ExitRoom------GameClient==nil----")
  end
end

--[[
* @brief 换桌或者比赛重新报名
--]]
function BaseClient:ChangeDesk()
  GameClient:ChangeDesk();
end

--[[
* @brief 绝对座位号转为相对座位号，相对座位号为界面座位号
* @remark 修正C++ [0, N]
* @return 返回界面座位号
--]]
function BaseClient:ChairToUI(chairid)
  return GameClient:ChairToUI(chairid);
end

--[[
* @brief 相对座位号转为绝对座位号,绝对座位号为服务器座位号
* @remark 修正C++ [0, N]
* @return 返回界面座位号
--]]
function BaseClient:UIToChair(uichairid)
  return GameClient:UIToChair(uichairid - 1);
end

--[[
* @brief 使用道具(目标用户,道具ID)
* @return 返回界面座位号
--]]
function BaseClient:UseProp(player, propid)
  GameClient:UseProp(uichairid);
end

--[[
* @brief 判断当前房间是否是指定的房间类型
* @return 相同类型则返回true
--]]
function BaseClient:IsRoomType(roomtype)
  return GameClient:IsRoomType(roomtype);
end

--[[
* @brief 获得当前房间的调度模式,返回可能为防作弊\博弈防作弊\队伍\自由落座\常规比赛\定时赛
* @return 返回房间调度模式
--]]
function BaseClient:GetRoomMode()
  return GameClient:GetRoomMode();
end

--[[
* @brief 领取救济金
* @return 返回房间调度模式
--]]
function BaseClient:GiftMoney()
  GameClient:GiftMoney();
end

--[[
* @brief 获得开始模式
* @return 返回游戏开始模式
--]]
function BaseClient:GetGameStartType()
  return GameClient:GetGameStartType();
end

--[[
* @brief 获得当前登陆的会话ID
* @return 返回会话ID
--]]
function BaseClient:GetGUID()
  return GameClient:GetGUID();
end

--[[
* @brief 设置当前的默认文件查找目录, 每个游戏只能添加一个默认路径
* @return 成功返回true
--]]
function BaseClient:SetDefPath(path)
  return GameClient:SetDefPath(path);
end

--[[
* @brief 根据VIP经验值获得VIP等级
* @return 返回VIP等级
--]]
function BaseClient:GetVIPLevel(prestigeexp)
  return GameClient:GetVIPLevel(prestigeexp);
end

--[[
* @brief 根据声望经验值获得声望等级
* @return 返回声望等级
--]]
function BaseClient:GetPrestigeLevel()
  return GameClient:GetVIPLevel(vipexp);
end

--[[
* @brief 获得当前房间信息
* @return 返回房间信息
--]]
function BaseClient:GetRoomInfo()
  return GameClient.roominfo;
end

--[[
* @brief 获取游戏信息
* @return 返回游戏信息
--]]
function BaseClient:GetGameInfo()
  return GameClient.gameinfo;
end

--[[
* @brief 获取当前游戏的主文件路径
* @return 返回当前游戏的主文件路径
--]]
function BaseClient:GetMainFile()
  return GameClient.mainfile;
end

--[[
* @brief 游戏初始化
* @return 成功启动返回true，否则返回false
--]]
function BaseClient:OnInitialize()
  -- 保存分辨率
  local _EGLView = cc.Director:getInstance():getOpenGLView();
  local _frameSize = _EGLView:getDesignResolutionSize();

  self.mDesign = { };
  self.mDesign.width = _frameSize.width;
  self.mDesign.height = _frameSize.height;

  -- 提示信息
 -- print("[API] 启动游戏 - " .. self.class.__cname);
 -- print("[API] 玩家 - " .. self:GetPlayerSelf():GetNickName());

  return true;
end

--[[
* @brief 游戏关闭
--]]
function BaseClient:OnShutdown()
  -- 清除德州扑克游戏数据
  --GameApp:removeEventListenersByTag(self)


  GameClient.client = nil;

  -- 恢复分辨率

  --local _EGLView = cc.Director:getInstance():getOpenGLView();
  --_EGLView:setDesignResolutionSize(self.mDesign.width, self.mDesign.height, 2);
  self.mPlayer = {};

  print("[API] 客户端关闭");
end

--[[
* @brief 玩家进入桌子，
* @param player 进入的玩家对象
* @param isSelf 是否是自己
--]]
function BaseClient:OnPlayerJoinNative(player, isSelf)
  self:OnPlayerJoin(player, isSelf);
end

--[[
* @brief 玩家进入桌子，
* @param player 进入的玩家对象
* @param isSelf 是否是自己
--]]
function BaseClient:OnPlayerJoin(player)
  print("[API] 进入游戏 ["..tostring(player:GetUIChairID()).."]- " .. player:GetNickName());
end

--[[
* @brief 玩家离开桌子
* @param player 玩家对象
--]]
function BaseClient:OnPlayerLeaveNative(player)
    self:OnPlayerLeave(player);
end

--[[
* @brief 玩家离开桌子
* @param player 玩家对象
--]]
function BaseClient:OnPlayerLeave(player)
  print("[API] 离开游戏 ["..tostring(player:GetUIChairID()).."]- " .. player:GetNickName());
end


--[[
* @brief 重置游戏（做清理工作)
--]]
function BaseClient:OnGameReset()
  print("[API] 重置游戏");
end

--[[
* @brief 输出消息内容
* @param msgType 消息类型
* @param strMsg 消息内容
--]]
function BaseClient:OnMessage(msgType, strMsg)
  print("[API] MSG(" .. tostring(msgType) .. ") " .. strMsg);
end

--[[
* @brief 使用道具广播
* @param playerfrom 使用道具的玩家
* @param playerto 使用道具的目标用户（可能为nil)
* @param propid 道具ID
--]]
function BaseClient:OnUserProp(playerfrom, playerto, propid)
  print("[API] 使用道具广播成功 - (" .. tostring(propid) .. ")");
end

--[[
* @brief 使用道具失败应答
* @param strerror 错误原因
--]]
function BaseClient:OnUsePropFailed(strerror)
  print("[API] 使用道具广播失败 - (" .. tostring(strerror) .. ")");
end

--[[
* @brief 强制关闭游戏
--]]
function BaseClient:OnShutdownGame()
  print("[API] 强制关闭游戏");
end

--[[
* @brief 创建游戏场景
* @return 需要返回游戏场景对象(CCScene)
--]]
function BaseClient:OnCreateScene()
  local scene = CCScene:create();

  local label = CCLabelTTF:create("Game Client", "Arial", 24);
  local visiblesize = CCDirector:sharedDirector():getVisibleSize();
  local origin = CCDirector:sharedDirector():getVisibleOrigin();
  label:setPosition(cc.p(origin.x + visiblesize.width / 2, origin.y + visiblesize.height - label:getContentSize().height));

  scene:addChild(label);
end

--[[
* @brief 通知是否快速加入组队，非组队模式无效
* @param quickjoin 是否快速加入
--]]
function BaseClient:OnTeamRoomQuickJoin(quickjoin)
  print("[API] 快速加入组队 (" .. tostring(quickjoin) .. ")");
end

--[[
* @brief 比赛报名成功（失败客户端将关闭，不走该函数，启动报名请调用ChangeDesk函数)
--]]
function BaseClient:OnPKJoinReply()
  print("[API] 比赛报名成功");
end

--[[
* @brief 更新比赛房间内玩家数量
* @param inroom 参与该比赛的总玩家数
* @param maxplayers 当前比赛分组需要多少人才能开始
* @param ingroup 当前分组内人数
--]]
function BaseClient:OnPKUpdatePlayers(inroom, maxplayers, ingroup)
  print("[API] 比赛玩家更新 - 总人数(" .. tostring(inroom) .. ") 分组要求人数(" .. tostring(maxplayers) .. ") 分组人数(" .. tostring(ingroup) .. ")");
end

--[[
* @brief 比赛轮次更新通知
* @param state 轮次ID
--]]
function BaseClient:OnPKRoundOver(state)
  print("[API]  比赛轮次更新 - 轮次(" .. tostring(state) .. ")");
end

--[[
* @brief 比赛结束（获奖或者被淘汰)
* @param rank 当前名次（从1开始）
* @param award 奖励物品table，为nil则没有任何奖励,表结构类似{15=100,16=200}
--]]
function BaseClient:OnPKAward(rank, award)
  print("[API] 比赛结束 - 名次(" .. tostring(rank) .. ") 奖励物品(" .. tostring(maxplayers) .. ")");
end

--[[
* @brief 等待其他桌结束
* @param [in] deskcount 剩余桌子数
--]]
function BaseClient:OnPKWaitDeskGameOver(deskcount)
  print("[API] 等待其他桌结束 - 剩余桌数(" .. tostring(deskcount) .. ")");
end

--[[
* @brief 比赛信息
* @param [in] msg 比赛消息内容
--]]
function BaseClient:OnPKMessage(msg)
  print("[API] 比赛信息 - 内容(" .. tostring(msg) .. ")");
end

--[[
* @brief 比赛排名
* @param [in] playerid 用户ID
* @param [in] rank 用户名次（从1开始)
--]]
function BaseClient:OnPKRankIndex(playerid, rank)
  print("[API] 比赛排名 - 用户(" .. tostring(playerid) .. ") 名次(" .. tostring(rank) .. ")");
end

--[[
* @brief 赠送钱应答
* @param [in] newmoney 赠送后玩家的钱数
* @param [in] giftvalue 赠送的值
* @param [in] giftcount 赠送的次数（已经赠送的次数，包括当前这次）
* @param [in] leftcount 剩余次数
--]]
function BaseClient:OnGiftMoneyReplay(newmoney, giftvalue, giftcount, leftcount)
  print("[API] 赠送钱应答 - 赠送钱数(" .. tostring(newmoney) .. ") 赠送值(" .. tostring(giftvalue) .. ")" .. ") 赠送次数(" .. tostring(giftcount) .. ")" .. ") 剩余次数(" .. tostring(leftcount) .. ")");
end

--[[
* @brief 网络消息默认处理
* @param [in] msg 网络消息包，为CLuaMsgHeader对象
* @return 已经处理返回true,否则应该返回false
* @note 返回false则尝试查找注册的C++函数，返回true则不调用已经注册的C++函数
--]]
function BaseClient:OnProcessMessage(msg)
  -- print("[API] 网络消息包未处理 - 消息("..tostring(msg.id) .. ")");
  return false;
end

--[[
* @brief [废弃] 延迟数据发送(消息包)
--]]
function BaseClient:DelaySendData(msg)
  table.insert(self.mDelayMessage, msg);
end

--[[
* @brief [废弃] 处理延迟数据包(消息包)
--]]
function BaseClient:DispatchDelayMessage()
  local OnceDelay = self.mDelayMessage;
  self.mDelayMessage = { };

  for i = 1, #OnceDelay do
    self.mEvent[OnceDelay[i].wMessageID](self, OnceDelay[i]);
  end
end

--[[
* @brief 创建玩家信息
--]]
function BaseClient:CreatePlayer(player, isSelf, uichairid)
  --return BasePlayer.new(player, isSelf, uichairid);
end

return BaseClient;