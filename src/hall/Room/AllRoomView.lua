
local AllRoomView = class("AllRoomView", cc.load("mvc").ViewBase)
AllRoomView.error_dis         = 6
AllRoomView.moveTime          = 0.2

AllRoomView.ROOM_ARR   = {
    { ["varname"] = "uiroom01",["tag"] = 1}, 
    { ["varname"] = "uiroom02",["tag"] = 2}, 
    { ["varname"] = "uiroom03",["tag"] = 3},
    { ["varname"] = "uiroom05",["tag"] = 5}, 
    { ["varname"] = "uiroom01",["tag"] = 1}, 
    { ["varname"] = "uiroom02",["tag"] = 2}, 
    { ["varname"] = "uiroom03",["tag"] = 3},   
    { ["varname"] = "uiroom05",["tag"] = 5}, 
}

function AllRoomView:onCreate( ... )
    self.roomDis = FishCD.ROOM_DIS
    self.ROOM_COUNT = #self.ROOM_ARR
    self:removeAllChildren()

    self.room_min = {}
    self.room_max = {}
    for i,val in ipairs(self.ROOM_ARR) do
        local tag = val.tag
        local key = tostring(910000000 + tag)
        self.room_min[tag] = tonumber(FishGI.GameConfig:getConfigData("room", key, "cannon_min"));
        self.room_max[tag] = tonumber(FishGI.GameConfig:getConfigData("room", key, "cannon_max"));

    end
    self.myCanEnterMaxRoom = 0

    self.isFriendOpen = false
    self.friendOpenTime = ""

    --添加触摸监听
    self:openTouchEventListener()
    
    self:initRoomIcon()
end

function AllRoomView:initRoomIcon()
    self.normalColor = cc.c3b(255,255,255)
    self.grayColor = cc.c3b(self.normalColor.r -75,self.normalColor.g -75,self.normalColor.b - 75)
    
    self.arrRoom = {}

    for i,val in ipairs(self.ROOM_ARR) do
        local room = require("hall/Room/Room").create()
        room:initWithRoomName(val.varname)
        room:setIndex(i,self.ROOM_COUNT)
        room:setTag(tonumber(val.tag))
        self:addChild(room)
        self.arrRoom[i] = room
    end

    self.roomSize =  self.arrRoom[1]:getContentSize()
end

function AllRoomView:onTouchBegan(touch, event)
    if not self:isVisible() then
     return
    end
    --FishGI.hallScene.view:onTouchBegan(touch, event)
    local curPos = touch:getLocation()
    for i,val in ipairs(self.ROOM_ARR) do
        local s = self.arrRoom[i].panel:getContentSize()
        local locationInNode = self.arrRoom[i].panel:convertToNodeSpace(curPos)
        local rect = cc.rect(0,0,s.width,s.height)
        if cc.rectContainsPoint(rect,locationInNode) and self.arrRoom[i]:getScale() > 0.3 then
            self.beganPos = curPos
            FishGI.AudioControl:playEffect("sound/com_btn03.mp3")
            FishGI.hallScene.view:onTouchBegan(touch, event)
            return true
        end
     end 
     return false  
end

function AllRoomView:onTouchMoved(touch, event)
    local curPos = touch:getLocation()
    if self.beganPos ~= nil then
        local moveDis = curPos.x - self.beganPos.x
        if moveDis >(self.roomDis)/2 or moveDis < -(self.roomDis)/2 then
            self.beganPos = nil
            self:arrRoomAction(moveDis,self.moveTime)
        end
    end    
end

function AllRoomView:onTouchEnded(touch, event)
    local curPos = touch:getLocation()
    if self.beganPos == nil then
        return false
    end   
    if self.beganPos.x - curPos.x < 6 and self.beganPos.x - curPos.x > -6 then
        for i,val in ipairs(self.ROOM_ARR) do
            local s = self.arrRoom[i].panel:getContentSize()
            local locationInNode = self.arrRoom[i].panel:convertToNodeSpace(curPos)
            local rect = cc.rect(0,0,s.width,s.height)
            if cc.rectContainsPoint(rect,locationInNode) and self.arrRoom[i]:getScale() > 0.3 and i < 4 then
                if i == 1 then
                    self:arrRoomAction((self.roomDis)/2,self.moveTime)
                    break
                elseif i == 3 then
                    self:arrRoomAction(-(self.roomDis)/2,self.moveTime)
                    break
                elseif i == 2 then
                    if self.arrRoom[i]:getScale() < 0.85 then
                        break
                    end
                    local isLock = self.arrRoom[i].isLock
                    if isLock then
                        --提示房间未解锁
                        local str = string.format(FishGF.getChByIndex(800000092),self.room_min[self.arrRoom[i]:getTag()] )
                        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,str,callback)
                        break 
                    end

                    local playerMaxRate = self.maxMultiple
                    local roomMaxRate = self.room_max[self.arrRoom[i]:getTag()] 
                    --大于房间最高炮倍，不能进入
                    print("-----playerMaxRate="..playerMaxRate.."--roomMaxRate="..roomMaxRate)
                    if playerMaxRate >= roomMaxRate and roomMaxRate ~= -1 then
                        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000088),callback)
                        return
                    end

                    if self.arrRoom[i]:getPositionX() > - self.error_dis and self.arrRoom[i]:getPositionX() < self.error_dis then
                        self:startGame(self.arrRoom[i]:getTag())
                        FishGI.hallScene.view.text_word:stopAllActions();
                        break 
                    end  
                end 
            end 
    	end	
    end
    self.beganPos = nil
end

function AllRoomView:onTouchCancelled(touch, event)
    local curPos = touch:getLocation()
    self.beganPos = nil
end

--设置玩家可以进入的房间，并且将最高炮倍的移动到中间
function AllRoomView:setRoomLimit( maxMultiple )
    if self.arrRoom == nil then
        return 
    end
    self.maxMultiple = maxMultiple
    local middleTag = 1
    for i,val in ipairs(self.ROOM_ARR) do
        local tag = self.arrRoom[i]:getTag()

        if maxMultiple < self.room_min[tag] then
            self.arrRoom[i]:setLockState(true)
        elseif maxMultiple >= self.room_min[tag] and (maxMultiple < self.room_max[tag] or self.room_max[tag] == -1) then
            self.arrRoom[i]:setLockState(false)
            if self.room_min[tag] > self.room_min[middleTag] then
                middleTag = tag
            end
        else
            self.arrRoom[i]:setLockState(false)
        end
    end
    local isPlayUnlocked = false
    if self.curMaxRoomTag ~= nil and self.curMaxRoomTag < middleTag then
        isPlayUnlocked = true
    end
    self.curMaxRoomTag = middleTag

    local isUpData = true
    for i=1,#self.ROOM_ARR do
        local tag2 = self.arrRoom[2]:getTag()
        if middleTag == tag2 then
            if isPlayUnlocked then
                self.arrRoom[2]:setLockState(false,true)
            end
            self.arrRoom[2]:upDateRoom()
            break
        else
            isUpData = false
            self:arrRoomAction(self.roomDis,false)
        end
    end
    self.myCanEnterMaxRoom = middleTag

end

function AllRoomView:arrRoomAction(moveDis, isAct)
    if moveDis >=(self.roomDis)/2 then
    --向右移动
        for i,val in ipairs(self.ROOM_ARR) do
            self.arrRoom[i]:moveAct("right",isAct)
        end    

        local lastRoom = self.arrRoom[#self.arrRoom]
        for i = #self.arrRoom - 1 ,1 ,-1 do
            local room = self.arrRoom[i]
            self.arrRoom[i+1] = room
        end
        self.arrRoom[1] = lastRoom
        
    elseif moveDis <= -(self.roomDis)/2 then
    --向左移动
        for i,val in ipairs(self.ROOM_ARR) do
            self.arrRoom[i]:moveAct("left",isAct)
        end  

        local firstRoom = self.arrRoom[1]
        for i = 1 ,#self.arrRoom - 1 ,1 do
            local room = self.arrRoom[i+1]
            self.arrRoom[i] = room
        end
        self.arrRoom[#self.arrRoom] = firstRoom
    end

end

function AllRoomView:startGame(gameTag)
    print("gameTag:"..gameTag)
    if gameTag == FishCD.ROOMTYPE_TAG_01 then
        --新手房
        FishGI.hallScene.net:enterGame(tostring(gameTag))
        FishGI.curGameRoomID = gameTag
        print("enterRoom:")      
    elseif gameTag == FishCD.ROOMTYPE_TAG_02 then
    	--中级房
        FishGI.hallScene.net:enterGame(tostring(gameTag))
        FishGI.curGameRoomID = gameTag
    elseif gameTag == FishCD.ROOMTYPE_TAG_03 then
        --高级房
        FishGI.hallScene.net:enterGame(tostring(gameTag))
        FishGI.curGameRoomID = gameTag
     elseif gameTag == FishCD.ROOMTYPE_TAG_04 then
        --朋友场
        if self:isFriendCanOpen() then
            FishGI.hallScene:setIsToFriendRoom(true)
        else
            FishGF.showToast(FishGF.getChByIndex(800000298))
        end
        return
    elseif gameTag == FishCD.ROOMTYPE_TAG_05 then
        --千倍房
        FishGI.hallScene.net:enterGame(tostring(gameTag))
        FishGI.curGameRoomID = gameTag
    end

    local data = {}
    data.funName = "setCurGameRoomID"
    data.curGameRoomID = FishGI.curGameRoomID
    LuaCppAdapter:getInstance():luaUseCppFun(data)

end  

function AllRoomView:fastStartGame()
    self:startGame(self.myCanEnterMaxRoom)
end


function AllRoomView:setIsCurShow( isShow )
    if isShow == self.isShow then
        return
    end
    
    FishGF.setNodeIsShow(self,"up",isShow ,display.height)
    self.isShow = isShow
end

--朋友场是否开放
function AllRoomView:OnFriendOpen(data)
    if self.arrRoom == nil then
        return 
    end
    self.isFriendOpen =  data.isFriendOpen
    self.friendOpenTime =  data.friendOpenTime
    if self.isFriendOpen == nil then
        self.isFriendOpen = false
    end
    if self.friendOpenTime == nil or self.friendOpenTime == "" then
        self.friendOpenTime = "00:00:00-00:00:00"
    end

    local openType = 0   --0未开启   1开启，在时间内   2开启，不在时间内
    if self.isFriendOpen == false then
        openType = 0
    else
        local time = self.friendOpenTime
        local timeTab = string.split(time,"-")
        if FishGF.isInTwoTime( timeTab[1],timeTab[2] ) then
            openType = 1
        else
            openType = 2
        end
    end

    for i,val in ipairs(self.ROOM_ARR) do
        self.arrRoom[i]:setRoomNodeFriendState(openType,self.friendOpenTime)
    end  

end

--判断朋友场是否开放
function AllRoomView:isFriendCanOpen()
    if self.isFriendOpen == false then
        return false
    end

    local time = self.friendOpenTime
    local timeTab = string.split(time,"-")

    return FishGF.isInTwoTime( timeTab[1],timeTab[2] )

end

return AllRoomView;