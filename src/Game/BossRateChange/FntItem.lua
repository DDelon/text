local FntItem = class("FntItem", cc.load("mvc").ViewBase)

FntItem.FNT_DIS   = 120
FntItem.AUTO_RESOLUTION   = false
FntItem.RESOURCE_FILENAME = "ui/battle/bossratechange/uinum"
FntItem.RESOURCE_BINDING  = {    
    ["panel"] = { ["varname"] = "panel" },

    ["fnt_1"] = { ["varname"] = "fnt_1" },
    ["fnt_2"] = { ["varname"] = "fnt_2" },
    ["fnt_3"] = { ["varname"] = "fnt_3" },
}

function FntItem:onCreate( ... )
    self.fntArr = {}
    for i=1,3 do
        self.fntArr[i] = self["fnt_"..i]
    end
    self:initView()
    self:setIsEnd(true)
end

function FntItem:initData(  )
    self.firstSpeed = 40
    self.timeDis = 0.02
    self.endTime = 0.4
    self.allTimes = 0
end

function FntItem:initView(  )
    self:closeAllSchedule()
    self.fnt_1:setString(1)
    self.fnt_2:setString(0)
    self.fnt_3:setString(9)
    for i=1,3 do
        self["fnt_"..i]:setPositionY((2 - i)*self.FNT_DIS)
    end
end

function FntItem:setPalyTime( time )
    self.palyTimes = time
end

function FntItem:setEndNum( endNum )
    self.endNum = endNum
    print("---------------self.endNum="..self.endNum)
end

function FntItem:setIsEnd( isEnd )
    self.isEnd = isEnd
end

function FntItem:setPlaySound( isPlay )
    self.isPlaySound = isPlay
end

function FntItem:setEndCallBack( callBack )
    self.callBack = callBack
end

function FntItem:playAct(  )
    self:initData()
    --local sprrdDis = ((self.firstSpeed/self.timeDis) - (self.FNT_DIS/(self.endTime/2)))/((self.palyTimes + 1) /self.timeDis)*self.timeDis

    --print("----------------------------sprrdDis = "..sprrdDis)
    self.startTime = os.time()
    self.isEnd = false
    local scheduler = cc.Director:getInstance():getScheduler()  
    self.schedulerID = scheduler:scheduleScriptFunc(function(dt)
        self.allTimes = self.allTimes + dt 
        self:speedStartAct(self.allTimes)

        --self.firstSpeed = self.firstSpeed - sprrdDis

        local endNum = self.fntArr[1]:getString()
        if self.isEnd and tonumber(endNum) == tonumber(self.endNum) then
            self:closeAllSchedule()
            self:EndAct(self.allTimes )
        end
    end,self.timeDis,false)

end

--匀速运动
function FntItem:speedStartAct( allTimes )
    local node = self.fntArr[#self.fntArr]
    local posY1 = node:getPositionY() 
    node:setPositionY( posY1 - self.firstSpeed)

    for i=#self.fntArr - 1,1,-1 do
        local node = self.fntArr[i]
        local posY2 = self.fntArr[i+1]:getPositionY() 
        node:setPositionY( posY2 + self.FNT_DIS)
    end

    if posY1 - self.firstSpeed < -2*self.FNT_DIS then
        self:CahngeToEnd()
    end
end

--结束运动
function FntItem:EndAct( allTimes )
    print("----------FntItem:EndAct----------")
    for i=1,#self.fntArr do
        local node = self.fntArr[i]
        local act1 = cc.MoveTo:create(self.endTime,cc.p(0,(1 - i)*self.FNT_DIS))
        --local speedAct = cc.EaseExponentialIn:create(act1)
        local speedAct = cc.EaseOut:create(act1,3)
        if i == 1 then
            local back = cc.CallFunc:create(function ( ... )
                print("---------- self.callBack---------")
                if self.isPlaySound ~= nil and self.isPlaySound then
                    FishGI.AudioControl:playEffect("sound/rolling_01.mp3")
                end
                self.callBack()
            end)
            --local act = cc.Sequence:create(speedAct,cc.DelayTime:create(0.1),back)
            local act = cc.Sequence:create(speedAct,back)
            speedAct = act
        end

        node:runAction(speedAct)
    end

end

function FntItem:CahngeToEnd( )
    if self.isPlaySound ~= nil and self.isPlaySound then
        FishGI.AudioControl:playEffect("sound/rolling_01.mp3")
    end
    local node = self.fntArr[#self.fntArr]
    for i=#self.fntArr - 1,1,-1 do
        self.fntArr[i+1] = self.fntArr[i]
    end
    self.fntArr[1] = node
    
    local curNum = tonumber(node:getString())
    local newNum = curNum + 3
    if newNum > 9  then
        newNum = newNum%10
    end
    node:setString(newNum)

    self.fntArr[1]:setPositionY(self.fntArr[2]:getPositionY() + self.FNT_DIS)

end

function FntItem:closeAllSchedule()
    if self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID )
        self.schedulerID = nil
    end
end


return FntItem;