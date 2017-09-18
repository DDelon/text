local SVUpdateCommand = class("SVUpdateCommand", require("Update/UpdateModule/Command/CommandBase"))

function SVUpdateCommand.create(data)
    local obj = SVUpdateCommand.new()
    obj:init(data)
    return obj
end

function SVUpdateCommand:init(data)
    print("svupdate command init")
    SVUpdateCommand.super.init(self)
    self.url = data.url
    self.localPath = data.localPath
    self.allSize = data.allSize
    self.curSize = 0
    self.fileInfo = data.fileInfo

    if not Helper.CreateDir(self.fileInfo.path) then
        print("没有足够的权限 创建文件夹失败 path:"..self.fileInfo.path)
    end
end

function SVUpdateCommand:doCommand()
    print("--------------svupdate do command")
    SVUpdateCommand.super.doCommand(self)
end

function SVUpdateCommand:finish()
end

function SVUpdateCommand:extraZip(fileName)
    print("extra zip")
    local zfile = CLuaZip.New()
    if not zfile:Open(fileName) then
        print("打开zip失败")
        return false
    else
        zfile:UnzipAllFiles() --解压所有文件
        zfile:Close()
        --删除包文件
        Helper.DeleteFile(fileName)
        return true
    end
end

function SVUpdateCommand:onHttpDataArrival(fileSize, downloadSize, speed)
    
    speed = downloadSize-self.curSize
    print("fileSize:"..fileSize.." downloadSize:"..downloadSize.." speed:"..speed)
    self.curSize = downloadSize
    local progress = checkint(math.floor((downloadSize/fileSize)*100))
    print("下载进度:"..progress)

    --更新ui
    self.updateManager:updateProgress(downloadSize, fileSize, speed, progress)
end

function SVUpdateCommand:onHttpComplete()
    local fileName = self.http.filename
    local hashCode = Helper.FileSha1(fileName)
    local subName = string.sub(self.fileInfo.fname, 1, 40)
    if hashCode ~= string.sub(self.fileInfo.fname, 1, 40) then
        print("文件校验不正确")
        self.updateManager:finish(self.id)
        return
    end

    if self.fileInfo.compr then
        if not self:extraZip(fileName) then
            self.updateManager:finish(self.id)
            return
        end
    end

    self.updateManager:finish(self.id)
end

function SVUpdateCommand:onHttpError(http, strError)
    print("error1:"..strError)
    self.updateManager:updateError();
end

return SVUpdateCommand