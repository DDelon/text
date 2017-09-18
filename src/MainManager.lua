local evt = {};
local MainManager = FishGF.ClassEx("MainManager", function()
    local  obj = CGameHallApp.New();
	obj.event= evt;
	return obj ;
end)

function MainManager.create()
	local manager = MainManager.new();
    manager:Initialize();
    manager:init();
	return manager;
end

function MainManager:isReconnecting()
    return self.isReconnecting;
end

--退到后台 断开连接
function MainManager:disconnectHall()
    
end

--进到前台恢复连接
function MainManager:recoveryConnect()
    
end

-- --进入前台
-- function MainManager:onAppEnterForeground()
--     FishGF.print("_______enter");
--     if self.isEnterBg == false then
--         return;
--     end
--     self:disconnectHall();

--     FishGI.loginScene.net:DoAutoLogin();
--     FishGI.hallScene:removeChildByTag(FishCD.TAG.RANK_WEB_TAG);
-- end

-- --进入后台
-- function MainManager:onAppEnterBackground()
--     FishGF.print("_______back");
--     self.isEnterBg = true;
-- end

-- function MainManager:registerEnterBFgroundEvt(scene)
--     print("------------------0000000000---registerEnterBFgroundEvt---------")
--     local eventDispatcher = scene:getEventDispatcher()
--     local forelistener = cc.EventListenerCustom:create("applicationWillEnterForeground", handler(self, self.onAppEnterForeground))
--     eventDispatcher:addEventListenerWithSceneGraphPriority(forelistener, scene)
--     local backlistener = cc.EventListenerCustom:create("applicationDidEnterBackground", handler(self,self.onAppEnterBackground))
--     eventDispatcher:addEventListenerWithSceneGraphPriority(backlistener, scene)
-- end


function MainManager:init()
    self.isReconnecting = false;
    
    FishGI.eventDispatcher:registerCustomListener("CreateLoginManager", self, function() self:createLoginManager() end);
    FishGI.eventDispatcher:registerCustomListener("CreateHallManager", self, function(valTab) self:createHallManager(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("CreateGameScene", self, function(valTab) self:createGameScene(valTab) end);
end

function MainManager:createLoginManager()
	--登录界面可以在进入场景后玩家使用网络功能后出现网络问题再提示玩家 
    --FishGF.getCurScale()
    if FishGI.hallScene ~= nil then
        if FishGI.hallScene.closeAllSchedule ~= nil then
            FishGI.hallScene:closeAllSchedule()
        end
    end
    
    local tempTab = HOT_VERSION_FILE;
    local ok,ver=pcall(HOT_VERSION_FILE)
	local scene = require("Login/LoginManager").create();
    FishGI.loginScene = scene;
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end

    --热更新
    --local upDateLayer = require("Updata/hotUpdate/UpDate").create()
    --scene:addChild(upDateLayer,2000)
end

function MainManager:createHallManager(valTab)
    local session = valTab.session;
    local userid = valTab.userid;
    local serverip = valTab.serverip;
    local serverport = valTab.serverport;
	--大厅场景最好等待网络正常连接成功后再转入大厅场景
	local hallNet = require("hall/HallNet").create();
    print("连接到大厅1111");
    if hallNet ~= nil then
        if hallNet:ConnectToHall(session,userid,serverip,serverport) then
            if FishGI.isEnterBg then
                FishGF.print("createHallManager ---------HallManager-----00000---set-");
                --FishGI.hallScene:release();
                FishGI.hallScene:setNet(hallNet);
                FishGI.isEnterBg = false;
            else
                FishGF.print("createHallManager ---------HallManager-------11111--");
                if FishGI.FRIEND_ROOM_STATUS ~= 0 then
                    FishGF.print("createHallManager ---------HallManager-----friend--11111-setNet-");
                    FishGI.hallScene:setNet(hallNet);
                else
                    local scene = require("hall/HallManager").create(hallNet);
                    scene:retain();
                    FishGI.hallScene = scene;
                    FishGF.print("createHallManager ----0000-----HallManager----11111-crat-");
                end
            end
            

            --[[if FishGI.hallScene ~= nil then
                cc.Director:getInstance():popScene();
                FishGI.hallScene:release();
                FishGI.hallScene = nil;
            end]]--
            
             print("连接到大厅2222");
        else
            print("连接到大厅失败 ConnectToHall");
        end
    else

    end

end

-----------------------------------------------------evt事件表-------------------------------------------
function evt.Initialize(obj)
    return true;
end

return MainManager;