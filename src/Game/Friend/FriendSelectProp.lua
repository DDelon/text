local FriendSelectProp = class("FriendSelectProp", cc.load("mvc").ViewBase)

FriendSelectProp.AUTO_RESOLUTION   = true
FriendSelectProp.RESOURCE_FILENAME = "ui/battle/friend/uifriendselectprop"
FriendSelectProp.RESOURCE_BINDING  = {
    ["panel"]               = { ["varname"] = "panel" },
    ["text_tip"]            = { ["varname"] = "text_tip" },
    ["node_prop_list"]      = { ["varname"] = "node_prop_list" },
    ["btn_prop_1"]          = { ["varname"] = "btn_prop_1", ["events"]={["event"]="click",
        ["method"]="onClickSelect",["methodTouchBegin"]="onClickSelectTouchBegin",["methodTouchCancel"]="onClickSelectTouchCancel"} },
    ["spr_prop_1"]          = { ["varname"] = "spr_prop_1" },
    ["btn_prop_2"]          = { ["varname"] = "btn_prop_2", ["events"]={["event"]="click",
        ["method"]="onClickSelect",["methodTouchBegin"]="onClickSelectTouchBegin",["methodTouchCancel"]="onClickSelectTouchCancel"} },
    ["spr_prop_2"]          = { ["varname"] = "spr_prop_2" },
    ["btn_prop_3"]          = { ["varname"] = "btn_prop_3", ["events"]={["event"]="click",
        ["method"]="onClickSelect",["methodTouchBegin"]="onClickSelectTouchBegin",["methodTouchCancel"]="onClickSelectTouchCancel"} },
    ["spr_prop_3"]          = { ["varname"] = "spr_prop_3" },
    ["btn_prop_4"]          = { ["varname"] = "btn_prop_4", ["events"]={["event"]="click",
        ["method"]="onClickSelect",["methodTouchBegin"]="onClickSelectTouchBegin",["methodTouchCancel"]="onClickSelectTouchCancel"} },
    ["spr_prop_4"]          = { ["varname"] = "spr_prop_4" },
    ["btn_prop_5"]          = { ["varname"] = "btn_prop_5", ["events"]={["event"]="click",
        ["method"]="onClickSelect",["methodTouchBegin"]="onClickSelectTouchBegin",["methodTouchCancel"]="onClickSelectTouchCancel"} },
    ["spr_prop_5"]          = { ["varname"] = "spr_prop_5" },
    ["btn_prop_6"]          = { ["varname"] = "btn_prop_6", ["events"]={["event"]="click",
        ["method"]="onClickSelect",["methodTouchBegin"]="onClickSelectTouchBegin",["methodTouchCancel"]="onClickSelectTouchCancel"} },
    ["spr_prop_6"]          = { ["varname"] = "spr_prop_6" },
    ["node_btn_select_1"]   = { ["varname"] = "node_btn_select_1" },
    ["node_btn_select_2"]   = { ["varname"] = "node_btn_select_2" },
    ["btn_select"]          = { ["varname"] = "btn_select", ["events"]={["event"]="click",["method"]="onClickOk"}},
    ["img_prop_desc_bg"]    = { ["varname"] = "img_prop_desc_bg" },
    ["text_prop_name"]      = { ["varname"] = "text_prop_name" },
    ["text_prop_desc"]      = { ["varname"] = "text_prop_desc" },
}

function FriendSelectProp:onCreate( ... )
    self:init()
    self:initView()
end

function FriendSelectProp:init()   
    self:openTouchEventListener()
    self.tSelectList = {}
    self.tSelectList[1] = FishCD.FRIEND_PROP_01
    self.tSelectList[2] = FishCD.FRIEND_PROP_02
    self.strTip = FishGF.getChByIndex(800000266)
end

function FriendSelectProp:initView()
    self.text_tip:setString(string.format( self.strTip,1 ))
    local tPropList = {
        FishCD.FRIEND_PROP_01,
        FishCD.FRIEND_PROP_02,
        FishCD.FRIEND_PROP_03,
        FishCD.FRIEND_PROP_04,
        FishCD.FRIEND_PROP_05,
        FishCD.FRIEND_PROP_06,
    }
    self:resetPropList(tPropList)
    self:runAction(self.node_btn_select_1["animation"])
    self:runAction(self.node_btn_select_2["animation"])
    self:setRoomOwner(false)
    self:updatePropDesc(1)
end

function FriendSelectProp:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false  
    end
    return true
end

function FriendSelectProp:onClickSelectTouchBegin( sender )
    local iPropID = sender:getTag()
    self:updateSelectData(iPropID)
    self:refreshSelectProps()
    self:updatePropDesc(iPropID)
    local index = self:getSelectIndex(iPropID)
    if index > 0 then
        self["node_btn_select_"..index]["animation"]:play("choice", true)
    end
    FishGI.AudioControl:playEffect("sound/com_btn02.mp3")
end

function FriendSelectProp:onClickSelectTouchCancel( sender )
    local iPropID = sender:getTag()
    local index = self:getSelectIndex(iPropID)
    if index > 0 then
        self["node_btn_select_"..index]["animation"]:play("init", false)
    end
end

function FriendSelectProp:onClickSelect( sender )
    local iPropID = sender:getTag()
    local index = self:getSelectIndex(iPropID)
    if index > 0 then
        self["node_btn_select_"..index]["animation"]:play("init", false)
    end
end

function FriendSelectProp:onClickOk( sender )
    self.parent_:buttonClicked("FriendSelectProp", "Select")
end

function FriendSelectProp:buttonClicked(viewTag, btnTag)
    if viewTag == "FriendPropList" then 
        local iPropID = btnTag
        self:updateSelectData(iPropID)
        self:refreshSelectProps()
        self:updatePropDesc(iPropID)
    end 
end

function FriendSelectProp:resetPropList( tPropList )
    if tPropList then
        self.tPropList = tPropList
    end
    for i, v in ipairs(tPropList) do
        local btnProp = self["btn_prop_"..i]
        btnProp:setTag(v)
        local sprProp = self["spr_prop_"..i]
        local scale = sprProp:getScale()
        local AnchorPoint = sprProp:getAnchorPoint()
        sprProp:initWithFile("battle/friend/"..FishGI.GameConfig:getConfigData("friendprop", tostring(420000000+v), "friendprop_res"))
        sprProp:setAnchorPoint(AnchorPoint)
        sprProp:setScale(scale)
    end
end

function FriendSelectProp:updateSelectData( iPropID )
    local iFindProp = nil
    for i, v in ipairs(self.tSelectList) do
        if v == iPropID then
            iFindProp = i
            break
        end
    end
    if self.bRoomOwner then
        if iFindProp then
            local iTmp = self.tSelectList[1]
            self.tSelectList[1] = self.tSelectList[2]
            self.tSelectList[2] = iTmp
        else
            self.tSelectList[1] = self.tSelectList[2]
            self.tSelectList[2] = iPropID
        end
    else
        self.tSelectList[1] = iPropID
    end
end

function FriendSelectProp:getSelectIndex( iPropID )
    local iSelectIndex = 0
    for i, v in ipairs(self.tSelectList) do
        if v == iPropID then
            iSelectIndex = i
            break
        end
    end
    return iSelectIndex
end

function FriendSelectProp:getPropBtnPos( iPropID )
    local btnProp = nil
    for i, v in pairs(self.tPropList) do
        if v == iPropID then
            btnProp = self["btn_prop_"..i]
            break
        end
    end
    if btnProp then
        return cc.p(btnProp:getPosition())
    else
        return cc.p(0,0)
    end
end

function FriendSelectProp:refreshSelectProps()
    self.node_btn_select_1:setPosition(self:getPropBtnPos(self.tSelectList[1]))
    if self.bRoomOwner then
        self.node_btn_select_2:setPosition(self:getPropBtnPos(self.tSelectList[2]))
    end
end

function FriendSelectProp:updatePropDesc(iPropID)
    self.text_prop_name:setString(FishGI.GameConfig:getConfigData("friendprop", tostring(420000000+iPropID), "friendprop_name"))
    self.text_prop_desc:setString(FishGI.GameConfig:getConfigData("friendprop", tostring(420000000+iPropID), "friendprop_text"))
end

function FriendSelectProp:setRoomOwner( bRoomOwner )
    self.bRoomOwner = bRoomOwner
    local iPropCount = 1
    self.tSelectList[1] = FishCD.FRIEND_PROP_01
    if self.bRoomOwner then
        iPropCount = 2
        self.tSelectList[2] = FishCD.FRIEND_PROP_02
    end
    self.text_tip:setString(string.format( self.strTip,iPropCount ))
    self.node_btn_select_2:setVisible(self.bRoomOwner)
    self:refreshSelectProps()
end

return FriendSelectProp