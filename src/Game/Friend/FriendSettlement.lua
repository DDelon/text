local FriendSettlement = class("FriendSettlement", cc.load("mvc").ViewBase)

FriendSettlement.AUTO_RESOLUTION   = true
FriendSettlement.RESOURCE_FILENAME = "ui/battle/friend/uifriendsettlement"
FriendSettlement.RESOURCE_BINDING  = {
    ["panel"]                       = { ["varname"] = "panel" },
    ["img_bg"]                      = { ["varname"] = "img_bg" },
    ["btn_close"]                   = { ["varname"] = "btn_close", ["events"]={["event"]="click",["method"]="onClickClose"}},
    ["btn_share"]                   = { ["varname"] = "btn_share", ["events"]={["event"]="click",["method"]="onClickShare"}},
    ["text_rank"]                   = { ["varname"] = "text_rank" },
    ["text_nick_name"]              = { ["varname"] = "text_nick_name" },
    ["text_get_Integral"]           = { ["varname"] = "text_get_Integral" },
    ["node_bar_1"]                  = { ["varname"] = "node_bar_1" },
    ["img_bar_1"]                   = { ["varname"] = "img_bar_1" },
    ["img_bar_xz_1"]                = { ["varname"] = "img_bar_xz_1" },
    ["text_nick_name_1"]            = { ["varname"] = "text_nick_name_1" },
    ["fnt_get_integral_1"]          = { ["varname"] = "fnt_get_integral_1" },
    ["node_bar_2"]                  = { ["varname"] = "node_bar_2" },
    ["img_bar_2"]                   = { ["varname"] = "img_bar_2" },
    ["img_bar_xz_2"]                = { ["varname"] = "img_bar_xz_2" },
    ["text_nick_name_2"]            = { ["varname"] = "text_nick_name_2" },
    ["fnt_get_integral_2"]          = { ["varname"] = "fnt_get_integral_2" },
    ["node_bar_3"]                  = { ["varname"] = "node_bar_3" },
    ["img_bar_3"]                   = { ["varname"] = "img_bar_3" },
    ["img_bar_xz_3"]                = { ["varname"] = "img_bar_xz_3" },
    ["text_nick_name_3"]            = { ["varname"] = "text_nick_name_3" },
    ["fnt_get_integral_3"]          = { ["varname"] = "fnt_get_integral_3" },
    ["node_bar_4"]                  = { ["varname"] = "node_bar_4" },
    ["img_bar_4"]                   = { ["varname"] = "img_bar_4" },
    ["img_bar_xz_4"]                = { ["varname"] = "img_bar_xz_4" },
    ["text_nick_name_4"]            = { ["varname"] = "text_nick_name_4" },
    ["fnt_get_integral_4"]          = { ["varname"] = "fnt_get_integral_4" },
    ["txt_timeout"]                 = { ["varname"] = "txt_timeout" },
    ["text_room"]                   = { ["varname"] = "text_room" },
    ["text_number"]                 = { ["varname"] = "text_number" },
    ["text_time_1"]                 = { ["varname"] = "text_time_1" },
    ["text_time_2"]                 = { ["varname"] = "text_time_2" },
}

function FriendSettlement:onCreate( ... )
    self:init()
    self:initView()
end

function FriendSettlement:onExit( )
    self:unscheduleTimeout()
end

function FriendSettlement:init()   
    self:openTouchEventListener()
    self.tListInfo = {}
    self.tSortList = {}
    self.strTimeOut = FishGF.getChByIndex(800000269)
    self.iTimeout = tonumber(FishGI.GameConfig:getConfigData("config", "990000083", "data"))
    self.btn_close.closePosX = self.btn_close:getPositionX()
    self.text_time_1:setString(os.date("%Y-%m-%d"))
    self.text_time_2:setString(os.date("%H:%M"))
end

function FriendSettlement:initView()
    self.text_rank:setString(FishGF.getChByIndex(800000243))
    self.text_nick_name:setString(FishGF.getChByIndex(800000267))
    self.text_get_Integral:setString(FishGF.getChByIndex(800000245))
    self.text_room:setString(string.format("%s:", FishGF.getChByIndex(800000314)))
    self.text_number:setString(tostring(FishGI.FRIEND_ROOMNO))
    self:runAction(self.resourceNode_["animation"])
    FishGI.AudioControl:playEffect("sound/rolling_01.mp3")
end

function FriendSettlement:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function FriendSettlement:onClickClose( sender )
    self.resourceNode_["animation"]:play("close", false)
    self.parent_:buttonClicked("FriendSettlement", "Close")
end

function FriendSettlement:onClickShare( sender )
    self.parent_:buttonClicked("FriendSettlement", "Share")
end

-- 重置列表数据
function FriendSettlement:resetRankList( tListInfo, tSortList )
    self.iCount = table.getn(tSortList)
    if self.iCount == 0 then 
        return
    end 
    self.node_bar_2:setVisible(true)
    self.node_bar_3:setVisible(true)
    self.node_bar_4:setVisible(true)
    if self.iCount == 1 then
        self.node_bar_2:setVisible(false)
        self.node_bar_3:setVisible(false)
        self.node_bar_4:setVisible(false)
    elseif self.iCount == 2 then
        self.node_bar_3:setVisible(false)
        self.node_bar_4:setVisible(false)
    elseif self.iCount == 3 then
        self.node_bar_4:setVisible(false)
    end
    
    self.tListInfo = tListInfo
    self.tSortList = tSortList
    for i, v in pairs(self.tSortList) do
        local data = self.tListInfo.data[v]
        local nodeBar = self["node_bar_"..i]
        local imgBar = self["img_bar_"..i]
        local imgBarXZ = self["img_bar_xz_"..i]
        local textNickName = self["text_nick_name_"..i]
        local textGetintegral = self["fnt_get_integral_"..i]
        textNickName:setString(data[1])
        textGetintegral:setString(data[2])
        if v == self.tListInfo.owner then 
            textNickName:setColor(cc.c3b(255, 248, 199))
            textGetintegral:setColor(cc.c3b(255, 248, 199))
            imgBar:setVisible(false)
            imgBarXZ:setVisible(true)
        else 
            textNickName:setColor(cc.c3b(255, 222, 89))
            textGetintegral:setColor(cc.c3b(255, 222, 89))
            imgBar:setVisible(true)
            imgBarXZ:setVisible(false)
        end
    end
    self.resourceNode_["animation"]:play("start", false)
end

function FriendSettlement:setTimeout()
    self:unscheduleTimeout()
    self.txt_timeout:setString(tostring(self.iTimeout))
    local function updateTimeout()
        if self.iTimeout > 0 then
            self.txt_timeout:setString(tostring(self.iTimeout))
            self.iTimeout = self.iTimeout - 1
        else 
            self:unscheduleTimeout()
            self:onClickClose()
        end
    end 
    self.timeoutScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTimeout, 1, false)
end

function FriendSettlement:unscheduleTimeout()
    if self.timeoutScheduleId ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timeoutScheduleId)
        self.timeoutScheduleId = nil
    end
end

--设置是否开启微信
function FriendSettlement:setWechatIsOpen(isOpen)
    if not isOpen then
         self.btn_share:setVisible(false)
         local middlePosX = self.img_bg:getContentSize().width/2
         self.btn_close:setPositionX(middlePosX)
    else
         self.btn_share:setVisible(true)
         self.btn_close:setPositionX(self.btn_close.closePosX)
    end
end

function FriendSettlement:onEnterForeground()
    self.iTimeout = self.iTimeout - FishGI.enterBackTime
end

return FriendSettlement