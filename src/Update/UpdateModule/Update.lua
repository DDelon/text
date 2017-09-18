--[[

    *派发startUpdate事件启动热更新模块 参数:{url = *** }
    *派发cleanUpdate事件清除热更新任务 参数:无
    *在外部注册updateComplete监听器 接收更新模块结束事件
    *在外部注册updating监听器 接收更新ui的进度条事件
    *在外部注册updateNotice监听器 接收弹出大版本更新的ui事件
    *在外部注册updateError监听器 接收版本检测失败的事件
    *在外部注册beginDownload监听器 接收开始下载的事件
]]

local Update = class("Update")

function Update.create()
    local obj = Update.new();
    obj:init();
    return obj;
end

function Update:init()
    self.constant = require("Update/UpdateModule/UpdateConstant")
    self.commandQueue = {}
    
    print("update init")

    local startUpdateListener=cc.EventListenerCustom:create("startUpdate",handler(self, self.start))  
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(startUpdateListener, 1)

    local cleanUpdateListener=cc.EventListenerCustom:create("cleanUpdate",handler(self, self.cleanup))  
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(cleanUpdateListener, 1)
end

function Update:createCommand(commandData)
    local commandType = commandData["type"];
    local data = commandData["data"];
    local command = nil;
    if commandType == self.constant["CommandType"].VERSION_CHECK then
        command = require("Update/UpdateModule/Command/VersionCheckCommand").create(data);
    elseif commandType == self.constant["CommandType"].GET_UPDATE_LIST then
        command = require("Update/UpdateModule/Command/GetHotUpdateFileCommand").create(data);
    elseif commandType == self.constant["CommandType"].SMALL_VERSION_UPDATE then
        command = require("Update/UpdateModule/Command/SVUpdateCommand").create(data);
    elseif commandType == self.constant["CommandType"].BIG_VERSION_UPDATE then
        command = require("Update/UpdateModule/Command/BVUpdateCommand").create(data);
    elseif commandType == self.constant["CommandType"].WAIT then
        command = require("Update/UpdateModule/Command/WaitCommand").create(data);
    end

    if command ~= nil then
        command:setUpdateManager(self);
        table.insert(self.commandQueue, command);
    end

    return command;
end

function Update:updateProgress(curSize, totalSize, speed, progress)
    local event = cc.EventCustom:new("updating")
    event._userdata = {
        cur = curSize,
        total = totalSize,
        speed = speed,
        progress = progress,
    }
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function Update:showBigUpdateNotice(version, notice, callback)
    local event = cc.EventCustom:new("updateNotice")
    event._userdata = {version = version, notice = notice, callback = callback}
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function Update:beginDownload()
    local event = cc.EventCustom:new("beginDownload")
    event._userdata = {}
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function Update:updateError()
    local event = cc.EventCustom:new("updateError")
    event._userdata = {}
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function Update:start(evt)
    local data = evt._userdata
    local url = data.url;
    print("check version url:"..url)
    self:createCommand({type = self.constant["CommandType"].VERSION_CHECK, data = {url = url}})

    self:continue();
end

function Update:continue()
    if table.maxn(self.commandQueue) > 0 then
        local command = self.commandQueue[1];
        if command ~= nil then
            command:doCommand();
        end
    else
        self:updateComplete();
    end
end

function Update:finish(id)

    for key, val in pairs(self.commandQueue) do
        if val.id == id then
            val:finish();
            table.remove(self.commandQueue, key);
        end
    end
    
    self:continue();
end

function Update:cleanup()
    for key = table.maxn(self.commandQueue), 1, -1 do
        local command = self.commandQueue[key];
        if command ~= nil then
            command:finish();
        end
        table.remove(self.commandQueue, key);
    end
end

function Update:updateComplete()
    print("update command all complete")
    local event = cc.EventCustom:new("updateComplete")
    event._userdata = {}
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

    cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("startUpdate");
	cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("cleanUpdate");

end


return Update;