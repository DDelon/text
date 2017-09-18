
local Announcement = class("Announcement", cc.load("mvc").ViewBase)

Announcement.AUTO_RESOLUTION   = false
Announcement.RESOURCE_FILENAME = "ui/common/uiannouncement"
Announcement.RESOURCE_BINDING  = {  
    ["panel"]     = { ["varname"] = "panel" },   
    ["node_word"] = { ["varname"] = "node_word" },    
}

function Announcement:onCreate(...)
    self.maxCount = 5
    self.size = self.panel:getContentSize()
    self.messageList = {}
    self.isMoveEnd = true

    FishGI.eventDispatcher:registerCustomListener("pushAnnouncementData", self, function(valTab) self:pushAnnouncementData(valTab) end);

end

function Announcement:showSystemAnnouncement(val)
    if val == nil or val == {} then
        return 
    end

    local announcementType = val.announcementType
    local params = val.params

    local  str = FishGF.getChByIndex(announcementType).."["

    local front = 1;
    local back = 1;
    local len = string.len(str);

    local strTab = {};
    local count = 1
    while true do
        back = string.find(str, "%[", front);
        local strFront = string.sub(str,front,back-1);
        front = back+1;
        back = string.find(str, "%]", front);
        if back ~= nil then
            local arg = string.sub(str,front,back-1);
            front = back+1;

            strTab[count] = {}
            strTab[count]["strFront"] = strFront
            strTab[count]["arg"] = arg
            count = count +1
        else
            strTab[count] = {}
            strTab[count]["strFront"] = strFront
            break;
        end

        if back >= len then
            break;
        end
    end
    for i=1,count do
        if strTab[i]["arg"] ~= "%s" and strTab[i]["arg"] ~= nil then
            local  strArg = strTab[i]["arg"].."|"
            local front = 1;
            local back = 1;
            local len = string.len(strArg);
            local strArgTab = {};
            local countArg = 1
            
            while true do
                back = string.find(strArg, "|", front);
                local r = string.sub(strArg,front,back-1);
                front = back+1;
                back = string.find(strArg, "|", front);
                local g = string.sub(strArg,front,back-1);
                front = back+1;
                back = string.find(strArg, "|", front);
                local b = string.sub(strArg,front,back-1);
                front = back+1;
                back = string.find(strArg, "|", front);
                local a = string.sub(strArg,front,back-1);
                front = back+1;
                back = string.find(strArg, "|", front);
                local size = string.sub(strArg,front,back-1);
                front = back+1;
                back = string.find(strArg, "|", front);
                local strArgEnd = string.sub(strArg,front,back-1);
                front = back+1;
                strTab[i]["argArr"] ={}
                strTab[i]["argArr"]["r"] = r
                strTab[i]["argArr"]["g"] = g
                strTab[i]["argArr"]["b"] = b
                strTab[i]["argArr"]["a"] = a
                strTab[i]["argArr"]["size"] = size
                if back >= len then
                    break;
                end
            end
        end
    end

    local richText = ccui.RichText:create()  
    richText:ignoreContentAdaptWithSize(true)  
    local sizeWidth = 0
    local sizeHeight = 0
    for i=1,#strTab do
        local strFront = strTab[i]["strFront"] 
        local Front = ccui.RichElementText:create( i, cc.c3b(255, 255, 255), 255, strFront, "Arial", 24 )         
        richText:pushBackElement(Front)
        local argArr = strTab[i]["argArr"]
        if argArr ~= nil then
            local strArg = ccui.RichElementText:create( i, cc.c3b(argArr["r"], argArr["g"], argArr["b"]), argArr["a"], params[i], "Arial", argArr["size"] )         
            richText:pushBackElement(strArg)
        elseif strTab[i]["arg"] == "%s" then
            local strArg = ccui.RichElementText:create( i, cc.c3b(255,255, 255), 255, params[i], "Arial", 24 )         
            richText:pushBackElement(strArg)
        end
    end
    richText:setLocalZOrder(10)  
    richText:setTag(100)
    richText:setName("richText")
    --self.image_word:setContentSize(cc.size(self.size.width,100))
    richText:setPosition(cc.p(self.size.width/2, 0));
    self.node_word:addChild(richText);

    self.node_word:setPositionX(self.size.width)
    local seq = cc.Sequence:create(cc.MoveTo:create(10,cc.p(-self.size.width,25)),cc.CallFunc:create(function ( ... )
        self.node_word:removeChildByName("richText")
        self.isMoveEnd = true
        self:upDate()
    end))
    self.node_word:runAction(seq)
end

function Announcement:pushAnnouncementData(val)
    table.insert(self.messageList,val)

    self:upDateList()
    self:upDate()
end

function Announcement:upDate()
    if table.maxn(self.messageList) <=0 then
        self:setVisible(false)
        return
    else
        self:setVisible(true)
    end

    local List = self.messageList
    if self.isMoveEnd == true then
        for i=1,table.maxn(self.messageList) do
            local item = self.messageList[i]
            if item ~= nil then
                self.isMoveEnd = false
                self:showSystemAnnouncement(item)
                self.messageList[i] = nil
                break
            end
        end
    end

end

function Announcement:upDateList()
    local myPlayerId= FishGI.gameScene.playerManager.selfIndex
    local curRoomId = FishGI.curGameRoomID
    local curDeskId = FishGI.deskId

    local messageList ={}
    messageList = self.messageList
    local front = 1
    local endIndex = table.maxn(self.messageList)
    local temArr = {}
    local index = 1
    --提取我自己的消息
    for i = front,endIndex  do 
        local data1 = messageList[i]
        if data1 ~= nil then
            if data1.playerId == myPlayerId then
                temArr[index] = data1
                index = index + 1
                messageList[i] = nil
            end
        end
    end
    --提取本房间的消息
    for i = front,endIndex  do 
        local data1 = messageList[i]
        if data1 ~= nil then
            if curRoomId == data1.roomId and curDeskId == data1.deskId then
                temArr[index] = data1
                index = index + 1
                messageList[i] = nil
            end
        end
    end
    --提取其他房间的消息
    for i = front,endIndex  do 
        local data1 = messageList[i]
        if data1 ~= nil then
            temArr[index] = data1
            index = index + 1
            messageList[i] = nil
        end
    end

    for i = front,endIndex  do 
        local data1 = temArr[i]
        if data1 ~= nil then
            self.messageList[i] = data1
        end
    end

    for i=endIndex,front,-1 do
        if i - front >= 5 then
            self.messageList[i] = nil
        end
    end   

end

return Announcement;