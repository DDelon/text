local FriendPlayerInfoLayer = class("FriendPlayerInfoLayer", cc.load("mvc").ViewBase)

FriendPlayerInfoLayer.AUTO_RESOLUTION   = true
FriendPlayerInfoLayer.RESOURCE_FILENAME = "ui/battle/friend/uifriendplayerinfolayer"
FriendPlayerInfoLayer.RESOURCE_BINDING  = {
    ["node_1"]              = { ["varname"] = "node_1" },
    ["node_2"]              = { ["varname"] = "node_2" },
    ["node_3"]              = { ["varname"] = "node_3" },
    ["node_4"]              = { ["varname"] = "node_4" },
    ["btn_player_info_1"]   = { ["varname"] = "btn_player_info_1", ["events"]={["event"]="click",["method"]="onClickPlayerInfo"}},
    ["btn_player_info_2"]   = { ["varname"] = "btn_player_info_2", ["events"]={["event"]="click",["method"]="onClickPlayerInfo"}},
    ["btn_player_info_3"]   = { ["varname"] = "btn_player_info_3", ["events"]={["event"]="click",["method"]="onClickPlayerInfo"}},
    ["btn_player_info_4"]   = { ["varname"] = "btn_player_info_4", ["events"]={["event"]="click",["method"]="onClickPlayerInfo"}},
    ["node_player_info_1"]  = { ["varname"] = "node_player_info_1" },
    ["node_player_info_2"]  = { ["varname"] = "node_player_info_2" },
    ["node_player_info_3"]  = { ["varname"] = "node_player_info_3" },
    ["node_player_info_4"]  = { ["varname"] = "node_player_info_4" },
}

function FriendPlayerInfoLayer:onCreate( ... )
    self:init()
    self:initView()
end

function FriendPlayerInfoLayer:init()
    self:openTouchEventListener()
    self.bOpenShowBtns = true
    self.bShowBtns = false
    self.iOwnerIndex = 0
    self.playerInfo = {}
end

function FriendPlayerInfoLayer:initView()
    for i = 1, 4 do 
        self["btn_player_info_"..i]:setTag(i)
        self["btn_player_info_"..i]:setVisible(self.bShowBtns)
        self["btn_player_info_"..i]:setPositionX(self["btn_player_info_"..i]:getPositionX()*self.scaleMin_)
        self["btn_player_info_"..i]:setScale(self.scaleMin_)
        if i == 1 then 
            self["node_"..i]:setPosition(cc.p(0, 0))
        elseif i == 2 then 
            self["node_"..i]:setPosition(cc.p(display.width, 0))
        elseif i == 3 then 
            self["node_"..i]:setPosition(cc.p(display.width, display.height))
        elseif i == 4 then 
            self["node_"..i]:setPosition(cc.p(0, display.height))
        end 
        self.playerInfo[i] = require("PlayerInfo/GamePlayerInfo").new(self, self["node_player_info_"..i])
        self.playerInfo[i]:setChairId(i)
        self.playerInfo[i]:setVisible(false)
        self.playerInfo[i]:setPositionX(self.playerInfo[i]:getPositionX()*self.scaleMin_)
        self.playerInfo[i]:setScale(self.scaleMin_)
    end 
end

function FriendPlayerInfoLayer:onTouchBegan(touch, event)
    return false
end

function FriendPlayerInfoLayer:buttonClicked(viewTag, btnTag)
    if viewTag == "GamePlayerInfo" then 
        --踢人玩家位置
        local iChairId = btnTag
        local playerId = FishGI.gameScene.playerManager:getPlayerByChairId(iChairId).playerInfo.playerId
        FishGI.gameScene.net:sendFriendKickOut(playerId)
    end 
end

function FriendPlayerInfoLayer:setOwnerIndex(iOwnerIndex)
    self.iOwnerIndex = iOwnerIndex
    if self.iOwnerIndex >= 1 and self.iOwnerIndex <= 4 then 
        self["btn_player_info_"..self.iOwnerIndex]:setVisible(false)
    end 
end

function FriendPlayerInfoLayer:isOpenShowBtns( bOpenShowBtns )
    if not bOpenShowBtns then
        if self.bShowBtns then 
            self:showBtns(false)
        end
    end
    self.bOpenShowBtns = bOpenShowBtns
end

function FriendPlayerInfoLayer:showBtns( bShowBtns )
    if not self.bOpenShowBtns then
        return
    end
    self.bShowBtns = bShowBtns
    if self.bShowBtns then
        for i=1,4 do
            if i ~= self.iOwnerIndex then 
                if FishGI.gameScene.playerManager:getPlayerByChairId(i) then 
                    self["btn_player_info_"..i]:setVisible(self.bShowBtns)
                end 
            end 
        end
    else
        for i=1,4 do
            self["btn_player_info_"..i]:setVisible(self.bShowBtns)
        end
    end
end

function FriendPlayerInfoLayer:addPlayer( iChairId )
    if iChairId == nil or not self.bOpenShowBtns then 
        return 
    end 
    if iChairId >= 1 and iChairId <= 4 then 
        local player = FishGI.gameScene.playerManager:getPlayerByChairId(iChairId)
        if self.iOwnerIndex ~= iChairId and player then 
            self["btn_player_info_"..iChairId]:setVisible(self.bShowBtns)
        end 
    end 
end

function FriendPlayerInfoLayer:removePlayer( iChairId )
    if iChairId == nil then 
        return 
    end 
    if iChairId >= 1 and iChairId <= 4 then 
        self["btn_player_info_"..iChairId]:setVisible(false)
    end 
end

function FriendPlayerInfoLayer:showPlayerInfo( iChairId )
    if iChairId == nil then 
        return 
    end 
    if iChairId >= 1 and iChairId <= 4 then 
        -- if self.playerInfo[iChairId]:getIsShow() then
        --     return
        -- end
        local player = FishGI.gameScene.playerManager:getPlayerByChairId(iChairId)
        if player ~= nil then
            player:showPlayerInfo()
        end
    end 
end

function FriendPlayerInfoLayer:hidePlayerInfo( iChairId )
    if iChairId == nil then 
        for i = 1, 4 do 
            self.playerInfo[i]:setVisible(false)
        end 
    elseif iChairId >= 1 and iChairId <= 4 then 
        self.playerInfo[iChairId]:setVisible(false)
    end 
end

function FriendPlayerInfoLayer:onClickPlayerInfo( sender )
    self:showPlayerInfo(sender:getTag())
end

function FriendPlayerInfoLayer:getPlayerInfoByChairId( iChairId )
    return self.playerInfo[iChairId]
end

return FriendPlayerInfoLayer