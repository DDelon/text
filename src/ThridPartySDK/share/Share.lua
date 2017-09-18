--
-- Author: Your Name
-- Date: 2016-10-17 20:33:00
--

cc.exports.WXScene = {
    Session = 0,        --聊天界面
    Timeline = 1,       --朋友圈
    Favorite = 2,       --收藏
}

local Share = class("Share")

function Share.create()
    local obj = Share.new();
    obj:init();
    return obj;
end

function Share:init()
    if device.platform == "android" then
        self.luaBridge = require("cocos.cocos2d.luaj");
    elseif device.platform == "ios" then
        self.luaBridge = require("cocos.cocos2d.luaoc");
    end
end

function Share:addListener()
    local JavaClassName = "com.weile.api.WXShareHelper"
     self.luaBridge.callStaticMethod(JavaClassName, "addScriptListener", { handler(self, self.onShareCallback_) })
end

function Share:removeListener()
    local JavaClassName = "com.weile.api.WXShareHelper"
     self.luaBridge.callStaticMethod(JavaClassName, "removeScriptListener")
end

function Share:onShareCallback_(luastr)
    local ok,argtable = pcall(function()
        return loadstring(luastr)();
    end)
    if ok then
        if argtable.status == 0 then
            print("share success request server");
            if FishGI.wechatShareType == nil then
                return
            end

            if FishGI.wechatShareType == 0 then
                FishGI.isWechatShare = true
                --FishGI.hallScene.net.roommanager:sendGetShareReward();
            elseif FishGI.wechatShareType == 1 then

            elseif FishGI.wechatShareType == 2 then
                                
            end
        end
    else
        if luastr == 0 then
            --ios平台
            print("share success request server");
            if FishGI.wechatShareType == nil then
                return
            end

            if FishGI.wechatShareType == 0 then
                FishGI.isWechatShare = true
                --FishGI.hallScene.net.roommanager:sendGetShareReward();
            elseif FishGI.wechatShareType == 1 then

            elseif FishGI.wechatShareType == 2 then
                                
            end
        else
            print("share result analysis failure")
        end
    end

    --FishGI.isEnterBg = false
    FishGI.wechatShareType = nil

end

function Share:doWXShareAnroid(args)
    local JavaClassName = "com.weile.api.WXShareHelper"
    local javaMethodName = "doShareToWX"
    local jsonArgs = json.encode(args)
    local javaParams = {jsonArgs}
    local javaMethodSig = "(Ljava/lang/String;)V"
    self.luaBridge.callStaticMethod(JavaClassName, javaMethodName, javaParams, javaMethodSig)
end

function Share:doWXShareIOS(args)
    local IosClassName = "AppController"
    local IosMenthodName = "doShareToWX"
    self.luaBridge.callStaticMethod(IosClassName, IosMenthodName, args)
end

function Share:doWXShareReq(args)
    if device.platform == "android" then
        self:addListener()
        args.appid = args.appid or FishGI.WebUserData:GetWXShareAppId()
        args.wxscene=args.wxscene or WXScene.Timeline
        self:doWXShareAnroid(args);
    elseif device.platform == "ios" then
        args.appid = args.appid or FishGI.WebUserData:GetWXShareAppId()
        args.wxscene=args.wxscene or WXScene.Timeline
        args.listener = handler(self, self.onShareCallback_)
        self:doWXShareIOS(args);
    end
    print("doWXShareReq no implement")
    
end

return Share


