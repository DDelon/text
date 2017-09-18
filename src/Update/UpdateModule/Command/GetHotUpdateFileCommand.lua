local GetHotUpdateFileCommand = class("GetHotUpdateFileCommand", require("Update/UpdateModule/Command/CommandBase"))

function GetHotUpdateFileCommand.create(data)
    local obj = GetHotUpdateFileCommand.new()
    obj:init(data)
    return obj
end

function GetHotUpdateFileCommand:init(data)
    GetHotUpdateFileCommand.super.init(self)
    self.url = data.url
    self.constant = require("Update/UpdateModule/UpdateConstant")
    self.opCodes = self.constant["Operator"]
    self.localPath = Helper.writepath .. "_tmp_.tmp"
end

function GetHotUpdateFileCommand:doCommand()
    GetHotUpdateFileCommand.super.doCommand(self)
end

function GetHotUpdateFileCommand:getHotUpdateUrl(url, sign, split)
    local ts = string.reverse(url)
    local tPos = string.find(ts, sign)
    local pos = string.len(ts) - tPos + 1

    local str = string.sub(url, 1, pos)
    return (str..split)
end

function GetHotUpdateFileCommand:hotUpdate(fileInfo)
    print("hot update")
    self.updateManager:beginDownload()
    local filePath = Helper.writepath .. fileInfo.path
    local url = self:getHotUpdateUrl(self.url, "/", self.filelist.url .. fileInfo.fname);
    local type = self.constant["CommandType"].SMALL_VERSION_UPDATE
    local data = {fileInfo = fileInfo, url = url, localPath = filePath, allSize = self.allsize}
    print("hot update command:"..url)
    self.updateManager:createCommand({type = type, data = data})
end

function GetHotUpdateFileCommand:deleteFile(fileInfo)

end

function GetHotUpdateFileCommand:renameFile(fileInfo)

end

function GetHotUpdateFileCommand:onHttpComplete()
    print("onHttpComplete:"..self.http.filename)
    self.filelist =assert(loadfile(self.http.filename))();
    local ft = self.filelist
    if self.filelist == nil then
        print("获取热更新文件列表失败")
        --self:finish();
        return;
    end
    self.allsize = 0;
    for _, v in ipairs(self.filelist) do
        if v.version > HALL_UPDATE_VERSION and v.op == OP_ADD then---mak
            self.allsize = self.allsize + v.size;
        end
    end

    self:UpdateFiles()
end

function GetHotUpdateFileCommand:UpdateFiles()
    print("UpdateFiles")
    repeat
        
        local targetVersion = self.filelist.version
        local curVersion = HALL_WEB_VERSION[3]
        local fileInfo = self.filelist[1]
        dump(self.filelist)
        --if targetVersion > curVersion then
            if fileInfo.op == self.opCodes.OP_ADD then  --新增
                self:hotUpdate(fileInfo)
            elseif fileInfo.op == self.opCodes.OP_DEL then --删除
                self:deleteFile(fileInfo)
            elseif fileInfo.op == self.opCode.OP_REN then --重命名
                self:renameFile(fileInfo)
            elseif fileInfo.op == self.opCode.OP_CLOSE then --关闭客户端
                os.exit(0);
            end
        --end
        table.remove(self.filelist, 1);

        if table.maxn(self.filelist) <= 0 then
            print("finish get hot update command")
            self.updateManager:finish(self.id)
            break;
        end

    until (true);
end

function GetHotUpdateFileCommand:onHttpError(http, strError)
    print("error2:"..strError)
    self.updateManager:updateError();
end

return GetHotUpdateFileCommand