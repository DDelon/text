local FriendBoxItem = class("FriendBoxItem", cc.load("mvc").ViewBase)

FriendBoxItem.AUTO_RESOLUTION   = true
FriendBoxItem.RESOURCE_FILENAME = "ui/battle/friend/uifriendboxitem"
FriendBoxItem.RESOURCE_BINDING  = {
    ["btn_box"]          = { ["varname"] = "btn_box", ["events"]={["event"]="click",["method"]="onClickBox"} },
}

FriendBoxItem.g_eStatus = {
    eStatic = 1,
    eOpen = 2,
    eAfterOpen = 3,
}

function FriendBoxItem:onCreate( ... )
    self:init()
    self:initView()
end

function FriendBoxItem:init( )
end

function FriendBoxItem:initView( )
    self:runAction(self.resourceNode_["animation"])
    self:setStatus(self.g_eStatus.eStatic)
end

function FriendBoxItem:onClickBox( sender )
    --self.parent_:buttonClicked("FriendBoxItem", self:getTag())
end

function FriendBoxItem:setStatus( eStatus, tProps, funCallBack )
    if self.eStatus == eStatus then 
        return 
    end 
    self.eStatus = eStatus
    if tProps == nil then 
        tProps = {}
    end 
    if eStatus == self.g_eStatus.eStatic then 
        self.resourceNode_["animation"]:play("static", false)
    elseif eStatus == self.g_eStatus.eOpen then 
        local function runDropPropsAni()
            if table.getn(tProps) > 0 then 
                --播放特效
                local dropPos = {}
                dropPos.x = self.pos.x
                dropPos.y = self.pos.y 
                for k,val in pairs(tProps) do
                    local propTab = {}
                    propTab.playerId = FishGI.myData.playerId
                    propTab.propId = val.propId
                    propTab.propCount = val.propCount
                    propTab.isRefreshData = true
                    propTab.isJump = true
                    propTab.firstPos = dropPos
                    propTab.dropType = "friend"
                    propTab.isShowCount = false
                    if val.propItemId ~= nil then
                        propTab.dropType = "normal"
                        propTab.seniorPropData = val
                    end
                    FishGI.GameEffect:playDropProp(propTab)
                end
                
            end 
            self:setStatus(self.g_eStatus.eAfterOpen)
        end 
        local frameEventCallFunc = function (frameEventName)
            if frameEventName:getEvent() == "open_end" then
                runDropPropsAni()
                if funCallBack then
                    funCallBack(self)
                end
            end
        end 
        self.resourceNode_["animation"]:play("open", false)
        self.resourceNode_["animation"]:clearFrameEventCallFunc()
        self.resourceNode_["animation"]:setFrameEventCallFunc(frameEventCallFunc)
        FishGI.AudioControl:playEffect("sound/getprop_02.mp3")
    elseif eStatus == self.g_eStatus.eAfterOpen then 
        self.resourceNode_["animation"]:play("after_open", false)
    end 
end

function FriendBoxItem:setPos( pos )
    self.pos = cc.p(pos.x, pos.y)
end

return FriendBoxItem