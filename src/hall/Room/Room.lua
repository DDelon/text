
local Room = class("Room", cc.load("mvc").ViewBase)

Room.error_dis         = 6
Room.moveTime          = 0.2
Room.scale1            = 1
Room.scale2            = 0.85
Room.AUTO_RESOLUTION   = false
Room.RESOURCE_FILENAME = "ui/hall/room/uiroom"
Room.RESOURCE_BINDING  = {
    ["panel"]       = { ["varname"] = "panel" ,},
    ["node_fish"]   = { ["varname"] = "node_fish" ,}, 
    ["spr_tips"]    = { ["varname"] = "spr_tips" ,}, 
}

function Room:onCreate( ... )
    self.normalColor = cc.c3b(255,255,255)
    self.grayColor = cc.c3b(self.normalColor.r -75,self.normalColor.g -75,self.normalColor.b - 75)
    self.roomDis = FishCD.ROOM_DIS
end

function Room:initWithRoomName(roomName)
    local fileName = string.format( "ui.hall.room.%s",roomName)
    local uiroom = require(fileName).create()
    if uiroom == nil then
        print("--uiroom == nil---")
        return 
    end
    local parent = self.node_fish:getParent() 
    self.node_fish:removeFromParent()
    self.node_fish = uiroom.root
    parent:addChild(self.node_fish)
    self.node_fish.animation = uiroom.animation
    self.node_fish:setName("node_fish")
    self.node_fish:setCascadeColorEnabled(true)
    self.node_fish:setCascadeOpacityEnabled(true)
    local size = self.panel:getContentSize()
    self.node_fish:setPosition(cc.p(size.width/2,size.height/2))
    self.node_fish:runAction(self.node_fish.animation)

    self.node_fish:setLocalZOrder(2)
    self.spr_tips:setLocalZOrder(3)
    self.spr_tips:setVisible(false)
    self.node_unlocked = self.node_fish:getChildByName("node_unlocked")
    if self.node_unlocked ~= nil then
        self.node_unlocked:setVisible(false)
    end

    self.lock = self.node_fish:getChildByName("bg"):getChildByName("hall_pic_room_locked_1")

end

--设置本身索引
function Room:setIndex(index,allCount)
    self.index = index
    self.allCount = allCount

    self:initPos(index,allCount)
end

--设置初始位置
function Room:initPos(index,allCount)
    self:setVisible(true)
    if index == 1 then
        self:setLocalZOrder(9) 
        self:setPositionX(-self.roomDis) 
        self:setScale(self.scale2)
    elseif index == 2 then
        self:setLocalZOrder(10) 
        self:setPositionX(0) 
        self:setScale(self.scale1)
    elseif index == 3 then
        self:setLocalZOrder(9) 
        self:setPositionX(self.roomDis) 
        self:setScale(self.scale2)
    elseif index == 4 then
        self:setLocalZOrder(8) 
        self:setPositionX(self.roomDis) 
        self:setScale(0)
        self:setVisible(false)
    elseif index == allCount then
        self:setLocalZOrder(8) 
        self:setPositionX(-self.roomDis) 
        self:setScale(0)
        self:setVisible(false)
    else
        self:setLocalZOrder(6) 
        self:setScale(0)  
        self:setVisible(false)
    end
end

--是否播放动画
function Room:isPalyAct(isPlay)
    if isPlay then
        self.node_fish.animation:play("roomact", true);
    else
        self.node_fish.animation:play("stopact", false);
    end
end

--是否解锁，是否播放解锁动画
function Room:setLockState(isLock,isPlay)
    self.isLock = isLock
    if self.lock == nil then
        return 
    end
    if isLock then
        self.lock:setVisible(true)
        return 
    end
    self.lock:setVisible(false)


    if self.node_unlocked == nil then
        return 
    end
    if isPlay then
        self.node_unlocked:setVisible(true)
        self.node_unlocked.animation:play("unlocked",false)
    end

    self:updateRoomTitle()
end

function Room:updateRoomTitle()
    if self.isLock == nil or self.isLock == true then
        return 
    end

    local tag = self:getTag()
    self:setRoomTitle(tag,self.isLock)

end

--设置房间标题  
function Room:setRoomTitle(tag,isLocak)
    local spr_word_room = self.node_fish:getChildByName("bg"):getChildByName("spr_word_room")
    if tag ~= nil then
        local state = 1
        if not isLocak then
            state = 2
        end
        local fileName = string.format("hall/room/title/room_title_%d_%d.png",tag,state)
        spr_word_room:initWithFile(fileName)
    end

end

--设置朋友场状态
function Room:setRoomNodeFriendState(openType,friendOpenTime)
    if self.node_fish == nil then
        return 
    end
    local node_opentime = self.node_fish:getChildByName("node_opentime")
    if node_opentime == nil then
        return
    end

    local spr_open_1 = node_opentime:getChildByName("spr_open_1")
    local spr_open_0 = node_opentime:getChildByName("spr_open_0")
    
    if friendOpenTime == nil or friendOpenTime == "" then
        friendOpenTime = "00:00:00-00:00:00"
    end
    local text_opentime = spr_open_1:getChildByName("text_opentime")
    text_opentime:setString(self:changenetTimeToShowTime(friendOpenTime))

    local spr_word_room = self.node_fish:getChildByName("bg"):getChildByName("spr_word_room")
    if openType == 0 then
        spr_word_room:initWithFile("hall/room/title/room_title_4_1.png")
        spr_open_1:setVisible(false)
        spr_open_0:setVisible(true)
    elseif openType == 1 then
        spr_word_room:initWithFile("hall/room/title/room_title_4_2.png")
        spr_open_1:setVisible(false)
        spr_open_0:setVisible(false)
    elseif openType == 2 then
        spr_open_1:setVisible(true)
        spr_open_0:setVisible(false)
        spr_word_room:initWithFile("hall/room/title/room_title_4_1.png")
        node_opentime:setVisible(true)        
    end
end

function Room:changenetTimeToShowTime(friendOpenTime)
    local time = friendOpenTime
    local timeTab = string.split(time,"-")    
    for i=1,#timeTab do
        if timeTab[i] == "" then
            timeTab[i] = "00:00:00"
        end 
    end
    self.firstTime = string.split(timeTab[1],":")
    self.endTime = string.split(timeTab[2],":")

    local newShowTime = self.firstTime[1]..":"..self.firstTime[2].."-"..self.endTime[1]..":"..self.endTime[2]

    return  newShowTime

end

--移动
function Room:moveAct(moveType,isAct)
    if isAct == false then
        self:moveRightNoAct()
        self:upDateRoom()
        return 
    end

    if moveType == "right" then
        self:moveRightAct(self.moveTime)
    else
        self:moveLefttAct(self.moveTime)
    end

    self:upDateRoom()
end

--更新状态
function Room:upDateRoom()
    if self.index == 2 then
        self.node_fish.animation:play("roomact", true);
    else
        self.node_fish.animation:play("stopact", false);
    end
end

--向右移动
function Room:moveRightAct(moveTime)
    self:stopAllActions()
    self:setVisible(true)

    if self.index == 1 then
        self:setLocalZOrder(9) 
        self:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(moveTime,cc.p(0,0)),cc.ScaleTo:create(moveTime,self.scale1))
            ,cc.ScaleTo:create(0.1,self.scale1 + 0.1),cc.ScaleTo:create(0.05,self.scale1)))    
    elseif self.index == 2 then
        self:setLocalZOrder(10) 
        self:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(moveTime,cc.p(self.roomDis,0)),cc.ScaleTo:create(moveTime,self.scale2))
                                                      ,cc.ScaleTo:create(0.1,self.scale2),cc.ScaleTo:create(0.1,self.scale2)))  
    elseif self.index == 3 then
        self:setLocalZOrder(9) 
        self:runAction(cc.Spawn:create(cc.MoveTo:create(moveTime,cc.p(self.roomDis,0)),cc.ScaleTo:create(moveTime,0))) 

    elseif self.index == self.allCount then
        self:setLocalZOrder(8) 
        self:setPositionX(-self.roomDis)
        self:runAction(cc.Spawn:create(cc.MoveTo:create(moveTime,cc.p(-self.roomDis,0)),cc.ScaleTo:create(moveTime,self.scale2))) 
    else
        self:setLocalZOrder(6) 
        self:setScale(0)  
        self:setVisible(false)
    end

    self.index = self.index + 1
    if self.index > self.allCount then
        self.index = 1
    end
end

--向右移动
function Room:moveRightNoAct()
    self:stopAllActions()
    self:setVisible(true)

    if self.index == 1 then
        self:setLocalZOrder(9) 
        self:setPosition(cc.p(0,0))
        self:setScale(self.scale1)  
    elseif self.index == 2 then
        self:setLocalZOrder(10) 
        self:setPosition(cc.p(self.roomDis,0))
        self:setScale(self.scale2)
    elseif self.index == 3 then
        self:setLocalZOrder(9)
        self:setPosition(cc.p(self.roomDis,0))
        self:setScale(0) 
    elseif self.index == self.allCount then
        self:setLocalZOrder(8) 
        self:setPositionX(-self.roomDis) 
        self:setScale(self.scale2)
    else
        self:setLocalZOrder(6) 
        self:setScale(0)  
        self:setVisible(false)
    end

    self.index = self.index + 1
    if self.index > self.allCount then
        self.index = 1
    end
end

--向左移动
function Room:moveLefttAct(moveTime)
    self:stopAllActions()
    self:setVisible(true)

    if self.index == 1 then
        self:setLocalZOrder(9) 
        self:runAction(cc.Spawn:create(cc.MoveTo:create(moveTime,cc.p(-self.roomDis,0)),cc.ScaleTo:create(moveTime,0)))     
    elseif self.index == 2 then
        self:setLocalZOrder(10) 
        self:runAction(cc.Spawn:create(cc.MoveTo:create(moveTime,cc.p(-self.roomDis,0)),cc.ScaleTo:create(moveTime,self.scale2))) 
    elseif self.index == 3 then
        self:setLocalZOrder(9) 
        self:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(moveTime,cc.p(self.pos2,0)),cc.ScaleTo:create(moveTime,self.scale1))
            ,cc.ScaleTo:create(0.1,self.scale1 + 0.1),cc.ScaleTo:create(0.05,self.scale1)))  
    elseif self.index == 4 then
        self:setLocalZOrder(8) 
        self:setPositionX(self.roomDis)
        self:runAction(cc.Spawn:create(cc.MoveTo:create(moveTime,cc.p(self.roomDis,0)),cc.ScaleTo:create(moveTime,self.scale2))) 
    else
        self:setLocalZOrder(6) 
        self:setScale(0)  
        self:setVisible(false)
    end

    self.index = self.index - 1
    if self.index <= 0 then
        self.index = self.allCount
    end
end


return Room;