local FriendPropBuff = class("FriendPropBuff", cc.load("mvc").ViewBase)

FriendPropBuff.AUTO_RESOLUTION   = true
FriendPropBuff.RESOURCE_FILENAME = "ui/battle/friend/uifriendpropbuff"
FriendPropBuff.RESOURCE_BINDING  = {
    ["spr_prop_buff"]           = { ["varname"] = "spr_prop_buff" },
    ["node_data"]               = { ["varname"] = "node_data" },
    ["txt_prop_buff_data"]      = { ["varname"] = "txt_prop_buff_data" },
}

function FriendPropBuff:onCreate( ... )
    self:init()
    self:initView()
end

function FriendPropBuff:init( )
    self.iPropId = 0
    self.iCount = 0
    self.data = ""
end

function FriendPropBuff:initView( )
end

function FriendPropBuff:setPropId(iPropId)
    if self.iPropId == iPropId then 
        return 
    end 
    self.iPropId = iPropId
    if iPropId == 0 then 
        return 
    end 
    local strPropImg = FishGI.GameConfig:getConfigData("friendprop", tostring(420000000+self.iPropId), "friendprop_buff")
    if string.len( strPropImg ) then 
        local scale = self.spr_prop_buff:getScale()
        local AnchorPoint = self.spr_prop_buff:getAnchorPoint()
        self.spr_prop_buff:initWithFile("battle/friend/"..strPropImg)
        self.spr_prop_buff:setAnchorPoint(AnchorPoint)
        self.spr_prop_buff:setScale(scale)
    end 
end

function FriendPropBuff:setData(data) 
    self.data = data
    self.txt_prop_buff_data:setString(string.format("%s", self.data))
end 

return FriendPropBuff