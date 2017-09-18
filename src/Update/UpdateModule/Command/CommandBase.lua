local evt = {}
local count = 0;
local CommandBase = class("CommandBase")

function CommandBase:init()
    count = count+1
    self.id = count
    self.http = CHttpClient.New()
    self.http:SetSoTimeout(0)
    self.http.manager = self
    self.http.event = evt
end

function CommandBase:setUpdateManager(updateManager)
    self.updateManager = updateManager
end

function CommandBase:doCommand()
    self.http.requestType = self.commandType;
    print("url:"..self.url)
    if self.localPath == nil then
        if not self.http:Start(self.url) then
            print("http start error command type:"..self.commandType)
            return
        end
    else
        if not self.http:Start(self.url, self.localPath) then
            print("http start error command type:"..self.commandType)
            return
        end
    end
    
end

function CommandBase:finish()
    
end

function CommandBase:onHttpComplete()
end

function CommandBase:onHttpDataArrival(fileSize, downloadSize, speed)
end

function CommandBase:onHttpClose(errorCode)

end

function CommandBase:onHttpError(http, strError)
end


-------------------------------------------------event
function evt.OnHttpComplete(http)

    local ret, msg = pcall(http.manager.onHttpComplete, http.manager)
    if not ret then
        print("pcall onHttpComplete error msg:"..msg)
    end
end

function evt.OnHttpClose(http, errorCode)
    print("http close error code:"..errorCode)
    http.manager:onHttpClose(errorCode)
end

function evt.OnHttpDataArrival(http, filesize, downloadsize, speed)
    http.manager:onHttpDataArrival(filesize, downloadsize, speed)
end

function evt.OnHttpError(http, strError)
    http.manager:onHttpError(http, strError)
end

return CommandBase;