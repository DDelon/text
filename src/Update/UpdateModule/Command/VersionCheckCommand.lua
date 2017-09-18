
local VersionCheckCommand = class("VersionCheckCommand", require("Update/UpdateModule/Command/CommandBase"))

function VersionCheckCommand.create(data)
    local obj = VersionCheckCommand.new()
    obj:init(data)
    return obj
end

function VersionCheckCommand:init(data)
    VersionCheckCommand.super.init(self)
    self.url = data.url;
    
    self.constant = require("Update/UpdateModule/UpdateConstant");
    self.commandType = self.constant["CommandType"].VERSION_CHECK
    self.statusCodes = self.constant["VersionCheckStatus"]
    self.updateType = self.constant["UpdateType"]
end

function VersionCheckCommand:doCommand()
    print("version check command")
    VersionCheckCommand.super.doCommand(self)
end

function VersionCheckCommand:finish()
    VersionCheckCommand.super.finish(self)
    
end

function VersionCheckCommand:getHotUpdateFileList(ret)
    local url = ret.urllua or ret.url
    print("热更新包地址:"..url)
    local type = self.constant["CommandType"].GET_UPDATE_LIST
    local data = {url = url}
    self.updateManager:createCommand({type = type, data = data})
end

function VersionCheckCommand:bigUpdate(ret, funSwitch)

    local id = 0;
    --弹出一个ui提示框
    local function callfunc()
        
        if device.platform == "ios" then
            local appstoreUrl = ret.urlapkssl or ret.urlapk
            cc.Application:getInstance():openURL(appstoreUrl)
        elseif device.platform == "android" or device.platform == "windows" then
            if CHANNEL_ID == CHANNEL_ID_LIST.tencent then
                print("begin update")
                self.updateManager:beginDownload()
                local type = self.constant["CommandType"].BIG_VERSION_UPDATE
                local url = ret.urllua or ret.urlapk
                local data = {url = url}
                self.updateManager:createCommand({type = type, data = data})
            else
                local url = ret.urllua or ret.urlapk
                cc.Application:getInstance():openURL(appstoreUrl)
            end

            
        end

        self.updateManager:finish(id)
        
        
    end
    print("log:"..ret.log);
    --callfunc();


    if bit.band(funSwitch, 16) ~= 16 then   --是否开启自己的大版本更新
        self.updateManager:showBigUpdateNotice(ret.last, ret.log, callfunc);
        id = self.updateManager:createCommand({type = self.constant["CommandType"].WAIT}).id;
    else
        self.updateManager:finish(self.id);
    end
    --self.manager:showBigUpdateNotice();
end


function VersionCheckCommand:getIpPort(address)
    if FishGI.SYSTEM_STATE ~= 0 then
        return "192.168.67.6", 6532;
    end
    if address and #address ~= 0 then
        local pos = string.find(address, ":");
        if pos ~= nil then
            local url = string.sub(address, 1, pos - 1);
            local port = tonumber(string.sub(address, pos + 1));
            return url, port;
        else
            return "game10.weile.com", 6532;
        end
    end
end

function VersionCheckCommand:onHttpComplete()
    local str = self.http:GetData();  
    str= Helper.CryptStr(str,URLKEY,false,0); 
    if 0 == #str then
        print("版本检测失败，数据解密错误!"..str);
        self.updateManager:updateError();
        return;
    end
    print("version check data:"..str)

    local ret = loadstring(str)();
    if type(ret) ~= "table" then
        print("版本检测失败，数据格式错误");
        self.updateManager:updateError();
        return;
    end

    if ret.review ~= nil then --审核开关
        IS_REVIEW_MODE = ret.review;
    end
    if ret.switch ~= nil then --功能开关
        FUN_SWITCH = ret.switch
    end
    if ret.spay ~= nil then --充值开关
        PAY_SWITCH = ret.spay
    end

    if ret.loginip ~= nil then --登录ip
        local ip, port = self:getIpPort(ret.loginip)
        FishGI.serverConfig[1].url = ip
        FishGI.serverConfig[1].port = port
    end


    local status = ret.status
    if status == self.statusCodes.LATEST then --是最新
        
    elseif status == self.statusCodes.MAINTENANCE then --在维护
    elseif status == self.statusCodes.UPDATE then --需要更新
        if ret.uptype == self.updateType.HOT_UPDATE then --热更新
            self:getHotUpdateFileList(ret);
        else--if ret.uptype == self.updateType.WHOLE_UPDATE then --大版本更新
            self:bigUpdate(ret, FUN_SWITCH);
        end

    else
        print("未知状态码")
    end
    self.updateManager:finish(self.id);
end

function VersionCheckCommand:onHttpClose(http, errorCode)
    print("OnHttpClose")
end

function VersionCheckCommand:onHttpError(http, strError)
    print("error0:"..strError)
    self.updateManager:updateError();
end

return VersionCheckCommand