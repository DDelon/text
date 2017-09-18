local BVUpdateCommand = class("BVUpdateCommand", require("Update/UpdateModule/Command/CommandBase"))

function BVUpdateCommand.create(data)
    local obj = BVUpdateCommand.new()
    obj:init(data)
    return obj
end

function BVUpdateCommand:init(data)
    BVUpdateCommand.super.init(self)
    print("url:"..data.url)
    self.url = data.url
    self.localPath = cc.FileUtils:getInstance():getWritablePath().."/sdcard/_tmp_.apk";
    if device.platform == "android" then 
        self.localPath = "/sdcard/_tmp_.apk"
    end
end

function BVUpdateCommand:doCommand()
    BVUpdateCommand.super.doCommand(self)
end

function BVUpdateCommand:finish()
    BVUpdateCommand.super.finish(self)
end

function BVUpdateCommand:onHttpDataArrival(fileSize, downloadSize, speed)
    print("onHttpDataArrival")
    --speed = downloadSize-self.curSize
    print("fileSize:"..fileSize.." downloadSize:"..downloadSize.." speed:"..speed.." self http size:"..self.http.size)
    self.curSize = downloadSize
    local progress = checkint(math.floor((downloadSize/fileSize)*100))
    print("下载进度:"..progress)
    if speed == 0 then
        return;
    end
    --更新ui
    self.updateManager:updateProgress(downloadSize, self.http.size, speed, progress)
end

function BVUpdateCommand:onHttpComplete()
    --apk下载完成
    print("apk download complete")
    if device.platform == "android" then 
		print("path:::::::::::::::: "..Helper.writepath .. "_tmp_.apk")
		local luaj = require("cocos.cocos2d.luaj")
       local ok,ret=  luaj.callStaticMethod("com.weile.api.NativeHelper", "installApk", {"/sdcard/_tmp_.apk"})
    end
    self.updateManager:finish(self.id)
end

function BVUpdateCommand:onHttpError(http, strError)
    print("error3:"..strError)
    self.updateManager:updateError();
end

return BVUpdateCommand