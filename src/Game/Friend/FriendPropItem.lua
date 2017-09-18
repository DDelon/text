local FriendPropItem = class("FriendPropItem", cc.load("mvc").ViewBase)

FriendPropItem.AUTO_RESOLUTION   = true
FriendPropItem.RESOURCE_FILENAME = "ui/battle/friend/uifriendpropitem"
FriendPropItem.RESOURCE_BINDING  = {
    ["btn_prop"]          = { ["varname"] = "btn_prop", ["events"]={["event"]="click",["method"]="onClickSelect"} },
    ["spr_prop"]          = { ["varname"] = "spr_prop" },
    ["spr_prop_grey"]     = { ["varname"] = "spr_prop_grey" },
    ["txt_prop_count"]    = { ["varname"] = "txt_prop_count" },
}

function FriendPropItem:onCreate( ... )
    self:init()
    self:initView()
end

function FriendPropItem:init( )
    self.iPropId = 0
    self.iCount = 0
    self.iCoolDown = 0
end

function FriendPropItem:initView( )
    self.progressTime = cc.ProgressTimer:create(self.spr_prop_grey)  
    self.progressTime:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.progressTime:setPercentage(0) 
    self.progressTime:setPosition(cc.p(self.spr_prop_grey:getContentSize().width/2,self.spr_prop_grey:getContentSize().height/2))  
    self.spr_prop:addChild(self.progressTime) 
    self.spr_prop_grey:setVisible(false)
    self.progressTime:setVisible(false)
end

function FriendPropItem:resetData( iPropId, iCount )
    self:setPropId(iPropId)
    self:setPropCount(iCount)
end

function FriendPropItem:setPropId(iPropId)
    self.iPropId = iPropId
    if self.iPropId == 0 then 
        return 
    end 
    local scale = self.spr_prop:getScale()
    local AnchorPoint = self.spr_prop:getAnchorPoint()
    local strPropImg = FishGI.GameConfig:getConfigData("friendprop", tostring(420000000+self.iPropId), "friendprop_res")
    self.spr_prop:initWithFile("battle/friend/"..strPropImg)
    self.spr_prop:setAnchorPoint(AnchorPoint)
    self.spr_prop:setScale(scale)
    local color = self.spr_prop_grey:getColor()
    self.spr_prop_grey:initWithFile("battle/friend/"..strPropImg)
    self.spr_prop_grey:setAnchorPoint(AnchorPoint)
    self.spr_prop_grey:setScale(scale)
    self.spr_prop_grey:setColor(color)
    self.iCoolDown = tonumber(FishGI.GameConfig:getConfigData("friendprop",tostring(420000000+self.iPropId),"cool_down"))
end

function FriendPropItem:setPropCount(iCount)
    self.iCount = iCount
    self.txt_prop_count:setString(tostring(self.iCount))
end

function FriendPropItem:onClickSelect( sender )
    if self.iCount > 0 then 
        self.parent_:buttonClicked("FriendPropItem", self.iPropId)
    end 
end

--CD进度条
function FriendPropItem:runTimer(callback)
    print("FriendPropItem:runTimer"..self.iPropId)
    self.btn_prop:setTouchEnabled(false)
    self.progressTime:setVisible(true)
    self.progressTime:stopAllActions()
    self.progressTime:setPercentage(100)

    local progressTo = cc.ProgressTo:create(self.iCoolDown,0)  
    local clear = cc.CallFunc:create(function (  )  
        self:stopTimer()
        if callback ~= nil then
            callback()
        end
    end)
    local seq = cc.Sequence:create(progressTo,clear)
    --Timer:setRotationSkewY(180)
    self.progressTime:runAction(seq)

    self.CDStartTime = os.time()
end

--刷新CD时间
function FriendPropItem:upDateTimer(callback)
    if self.CDStartTime == nil then
        return
    end
    local endTime = os.time()
    local disTime = endTime - self.CDStartTime

    if disTime >= self.iCoolDown then
        self:stopTimer()
        return
    end

    local per= disTime/self.iCoolDown*100

    self.progressTime:setVisible(true)
    self.progressTime:stopAllActions()
    self.progressTime:setPercentage(100) 
    local times = self.iCoolDown - disTime
    local progressTo = cc.ProgressFromTo:create(times,100 - per,0)  
    local clear = cc.CallFunc:create(function (  )  
        self:stopTimer()
        if callback ~= nil then
            callback()
        end
    end)
    local seq = cc.Sequence:create(progressTo,clear)  
    self.progressTime:runAction(seq)
end

--停止CD进度条
function FriendPropItem:stopTimer()
    self.CDStartTime = nil
    self.progressTime:setVisible(false)
    self.progressTime:stopAllActions()
    self.progressTime:setPercentage(0) 
    self.btn_prop:setTouchEnabled(true)
end

return FriendPropItem