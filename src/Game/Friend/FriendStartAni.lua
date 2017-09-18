local FriendStartAni = class("FriendStartAni", cc.load("mvc").ViewBase)

FriendStartAni.AUTO_RESOLUTION   = true
FriendStartAni.RESOURCE_FILENAME = "ui/battle/friend/uifriendstartani"
FriendStartAni.RESOURCE_BINDING  = {
    ["img_bg"]      = { ["varname"] = "img_bg" },
    ["panel"]       = { ["varname"] = "panel" },
}

function FriendStartAni:onCreate( ... )
    self:init()
    self:initView()
end

function FriendStartAni:onEnter( )
end

function FriendStartAni:init()   
    self:openTouchEventListener()
end

function FriendStartAni:initView()
    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()
    self.img_bg:setContentSize(cc.size(display.width, display.height))
    self.panel:setScale(self.scaleMin_)
    self:runAction(self.resourceNode_["animation"])
end

function FriendStartAni:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function FriendStartAni:showLayer()
    self:setVisible(true)
    local frameEventCallFunc = function (frameEventName)
        if frameEventName:getEvent() == "third" then
            FishGI.AudioControl:playEffect("sound/readygo_01.mp3")
        elseif frameEventName:getEvent() == "two" then
            FishGI.AudioControl:playEffect("sound/readygo_01.mp3")
        elseif frameEventName:getEvent() == "one" then
            FishGI.AudioControl:playEffect("sound/readygo_01.mp3")
        elseif frameEventName:getEvent() == "go" then
            FishGI.AudioControl:playEffect("sound/readygo_02.mp3")
        elseif frameEventName:getEvent() == "start_end" then
            self:setVisible(false)
        end
    end
    self.resourceNode_["animation"]:play("start", false)
    self.resourceNode_["animation"]:clearFrameEventCallFunc()
    self.resourceNode_["animation"]:setFrameEventCallFunc(frameEventCallFunc)
end

return FriendStartAni