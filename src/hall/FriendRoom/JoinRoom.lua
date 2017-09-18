local JoinRoom = class("JoinRoom", cc.load("mvc").ViewBase)

JoinRoom.ROOMNO_COUNT   = 6
JoinRoom.AUTO_RESOLUTION   = false
JoinRoom.RESOURCE_FILENAME = "ui/hall/friend/uijoinroom"
JoinRoom.RESOURCE_BINDING  = {    
    ["panel"]          = { ["varname"] = "panel" }, 
    
    ["text_notice"]    = { ["varname"] = "text_notice" },
    ["btn_close"]      = { ["varname"] = "btn_close" ,        ["events"]={["event"]="click",["method"]="onClickclose"}}, 
    
    ["node_curroomid"] = { ["varname"] = "node_curroomid" },
    ["node_num"]       = { ["varname"] = "node_num" },

}

function JoinRoom:onCreate( ... )
    self.text_notice:setString(FishGF.getChByIndex(800000293))
    self:openTouchEventListener()

    self:init()
    
end

function JoinRoom:init()
    --绑定函数
    for i=0,9 do
        local btn = self.node_num:getChildByName("btn_num_"..i)
        btn:setName(tostring(i))
        btn:onClickDarkEffect(handler(self, self.onClicknum))
    end
    local btnClear = self.node_num:getChildByName("btn_num_clear")
    btnClear:setName("clear")
    btnClear:onClickDarkEffect(handler(self, self.onClicknum))
    local btnDel = self.node_num:getChildByName("btn_num_del")
    btnDel:setName("del")
    btnDel:onClickDarkEffect(handler(self, self.onClicknum))

    self:initEditBoxStr()

end

function JoinRoom:initEditBoxStr()
    self.curRoomId = ""
    for i=1,self.ROOMNO_COUNT do
        local fnt = self.node_curroomid:getChildByName("fnt_no_"..i)
        fnt:setString("-")
    end
end

function JoinRoom:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function JoinRoom:onClicksure( sender )
    print("onClicksure")
    local roomno = self.tf_roomno:getString()
    if FishGF.checkRoomNo( roomno ) then
        self:hideLayer()
        FishGI.hallScene.uiFriendRoom:enterFriendRoom(roomno)
        self:hideLayer()
        print("-------JoinRoom:onClicksure---------")
    end
    
end

function JoinRoom:onClickclose( sender )
    print("onClickclose")
    self:hideLayer()
    FishGI.hallScene.uiFriendRoom.curType = 0
end

function JoinRoom:onClicknum( sender )
    print("onClicknum")
    
    local num = sender:getName()
    self:updataByNum(num)

end

function JoinRoom:updataByNum( num )
    print("updataByNum")
    if num == nil then
        return
    end
    local str = self.curRoomId
    if num == "clear" then
        str = ""
    elseif num == "del" then
        if #str > 0 then
            str = string.sub( str,1, #str -1)
        end
    else
        if #str < 6 and tonumber(num) >= 0 and tonumber(num) <10 then
            str = str..num
        end
    end

    self.curRoomId = str

    self:updataView()
end

function JoinRoom:updataView( )
    local curRoomId = self.curRoomId
    if #curRoomId >= 6 then
        if FishGF.checkRoomNo( curRoomId ) then
            FishGI.hallScene.uiFriendRoom:enterFriendRoom(curRoomId)
            self:hideLayer()
        end
        return 
    end

    local addCount = self.ROOMNO_COUNT - #curRoomId
    local viewStr = tostring(curRoomId)
    if addCount > 0 then
        for i=1,addCount do
            viewStr = viewStr.."-"
        end
    end
    --self.fnt_curroomid:setString(viewStr)

    for i=1,self.ROOMNO_COUNT do
        local fnt = self.node_curroomid:getChildByName("fnt_no_"..i)
        local str = string.sub( viewStr, i,i-self.ROOMNO_COUNT -1)
        fnt:setString(str)
    end

end

return JoinRoom;