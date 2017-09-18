local FriendPropList = class("FriendPropList", cc.load("mvc").ViewBase)

FriendPropList.AUTO_RESOLUTION   = true
FriendPropList.RESOURCE_FILENAME = "ui/battle/friend/uifriendproplist"
FriendPropList.RESOURCE_BINDING  = {
    ["node_prop_btn_1"]     = { ["varname"] = "node_prop_btn_1" },
    ["node_prop_btn_2"]     = { ["varname"] = "node_prop_btn_2" },
    ["node_prop_btn_3"]     = { ["varname"] = "node_prop_btn_3" },
    ["node_prop_btn_4"]     = { ["varname"] = "node_prop_btn_4" },
    ["node_prop_btn_5"]     = { ["varname"] = "node_prop_btn_5" },
    ["node_prop_btn_6"]     = { ["varname"] = "node_prop_btn_6" },
}

function FriendPropList:onCreate( ... )
    self:init()
    self:initView()
end

function FriendPropList:init( )
    self.tPropList = {
        {FishCD.FRIEND_PROP_01, 0},
        {FishCD.FRIEND_PROP_02, 0},
        {FishCD.FRIEND_PROP_03, 0},
        {FishCD.FRIEND_PROP_04, 0},
        {FishCD.FRIEND_PROP_05, 0},
        {FishCD.FRIEND_PROP_06, 0},
    }
    self:resetPropList()
end

function FriendPropList:initView( )
end

function FriendPropList:buttonClicked(viewTag, btnTag)
    self.parent_:buttonClicked(viewTag, btnTag)
end

function FriendPropList:resetPropList( )
    if self.tPropBtns == nil then 
        self.tPropBtns = {}
        for i, v in ipairs(self.tPropList) do
            self.tPropBtns[i] = require("Game/Friend/FriendPropItem").new(self, self["node_prop_btn_"..i])
        end
    end
    for i, v in ipairs(self.tPropList) do
        self.tPropBtns[i]:resetData(v[1], v[2])
    end
end

function FriendPropList:getPropBtnIndex( iPropId )
    local iIndex = 0
    for i, v in ipairs(self.tPropBtns) do
        if v.iPropId == iPropId then
            iIndex = i
            break
        end
    end
    return iIndex
end

--更新道具数量
function FriendPropList:updataPropUI(data)
    local playerId = data.playerId
    local iPropId = data.propId - FishCD.FRIEND_INDEX
    local iCount = data.propCount
    if playerId == FishGI.gameScene.playerManager:getMyData().playerInfo.playerId and iPropId < 100 then
        self:setPropCount(iPropId,iCount)
    end 
end

function FriendPropList:setPropCount(iPropId, iCount)
    local iBtnIndex = self:getPropBtnIndex(iPropId)
    if iBtnIndex > 0 then 
        self.tPropBtns[iBtnIndex]:setPropCount(iCount)
    end 
end 

function FriendPropList:runPropTimer(iPropId, callback)
    local iBtnIndex = self:getPropBtnIndex(iPropId)
    if iBtnIndex > 0 then 
        self.tPropBtns[iBtnIndex]:runTimer(callback)
    end 
end

function FriendPropList:upDatePropTimer(iPropId, callback)
    local iBtnIndex = self:getPropBtnIndex(iPropId)
    if iBtnIndex > 0 then 
        self.tPropBtns[iBtnIndex]:upDatePropTimer(callback)
    end 
end

function FriendPropList:stopPropTimer(iPropId)
    local iBtnIndex = self:getPropBtnIndex(iPropId)
    if iBtnIndex > 0 then 
        self.tPropBtns[iBtnIndex]:stopTimer()
    end 
end

return FriendPropList