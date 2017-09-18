
local GamePlayerInfo = class("GamePlayerInfo", cc.load("mvc").ViewBase)

GamePlayerInfo.AUTO_RESOLUTION   = false
GamePlayerInfo.RESOURCE_FILENAME = "ui/playerinfo/uigameplayerinfo"
GamePlayerInfo.RESOURCE_BINDING  = {    
    ["panel"]         = { ["varname"] = "panel" },
    ["img_bg"]        = { ["varname"] = "img_bg" },    
    ["spr_vip"]       = { ["varname"] = "spr_vip" },
    ["text_name"]     = { ["varname"] = "text_name" }, 
    ["text_playerid"] = { ["varname"] = "text_playerid" },
    ["text_rate"]     = { ["varname"] = "text_rate" },
    ["text_grade"]    = { ["varname"] = "text_grade" },
    ["spr_gunname"]   = { ["varname"] = "spr_gunname" },  
    ["btn_kickout"]   = { ["varname"] = "btn_kickout", ["events"]={["event"]="click",["method"]="onClickKickOut"}},
    
}

function GamePlayerInfo:onCreate( ... )
    self:initBg()

    self.isCanSend = true
    self.delayTime = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000058), "data"))

    self:openTouchEventListener()

    self.magicprop = require("Game/MagicProp/MagicProp").new()
    self.magicprop.nodeType = "viewlist"
    self.magicprop:init()
    self.magicprop:setPosition(0, -190)
    self.panel:addChild(self.magicprop);
end

--初始化背景
function GamePlayerInfo:initBg( )
    self:child("text_word_dqyb"):setString(FishGF.getChByIndex(800000183))
    self:child("text_word_zgpb"):setString(FishGF.getChByIndex(800000184))
    self:child("text_word_dqdj"):setString(FishGF.getChByIndex(800000185))
    self:child("text_word_gunname"):setString(FishGF.getChByIndex(800000299))
    self:child("text_toplayer"):setString(FishGF.getChByIndex(800000310))
    
    self:openKickOut(false)
end

--设置是否已经可以发送申请刷新数据
function GamePlayerInfo:setIsCanSend( isCanSend)
    self.isCanSend = isCanSend
end

--得到是否已经显示
function GamePlayerInfo:getIsCanSend( )
    return self.isCanSend
end

--显示
function GamePlayerInfo:showAct( )
    self:setIsCanSend(false)
    
    self.panel:stopAllActions()
    self.panel:setVisible(true)
    self.panel:setOpacity(255)
    self:setVisible(true)

    self:showLayer(false,0)
    local delayTime = self.delayTime
    local act = cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function ( ... )
        self:hideLayer(true,false,false,0.5)
    end))

    self.panel:runAction(act)

    self:stopActionByTag(11101)
    local act2 = cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function ( ... )
        self:setIsCanSend(true)
    end))
    act2:setTag(11101)
    self:runAction(act2)
end

--隐藏
function GamePlayerInfo:hideAct( )
    self.panel:stopAllActions()
    self:setVisible(false)
end

--通过Chairid设置位置
function GamePlayerInfo:setPosByChairid( chairId )
    local posX = FishCD.posTab[chairId].x 
    local posY = FishCD.posTab[chairId].y

    if chairId > 2 then
        posY = posY - 201
    else
        posY = posY + 201 +120
    end

    self:setPosition(cc.p(posX* self.scaleX_,posY * self.scaleY_))
    self:setScale(self.scaleMin_)

end

--通过变量名称设置变量值
function GamePlayerInfo:setPlayerData( val )
    self:setPlayerName(val.nickName)
    self:setVIP(val.vip_level)
    self:setPlayerId(val.playerId)
    self:setMaxRate(val.maxGunRate)
    self:setGrade(val.grade)
    self:setChairId(val.chairId)
    self:setCannonName(val.gunType)

end

--设置当前炮台名称
function GamePlayerInfo:setCannonName( gunType )
    local AnchorPoint = self.spr_gunname:getAnchorPoint()
    local gunName = string.format("battle/selectcannon/selectcannon_pic_title_%d.png",(gunType-1))
    self.spr_gunname:initWithFile(gunName)
    self.spr_gunname:setAnchorPoint(AnchorPoint)
end

--设置名称
function GamePlayerInfo:setPlayerName( nickName )
    self.text_name:setString(nickName)
end

--设置VIP等级
function GamePlayerInfo:setVIP( vip_level )
    local vipName = string.format("common/vip/vip_badge_%d.png",(vip_level))
    self.spr_vip:initWithFile(vipName)
end

--设置玩家ID
function GamePlayerInfo:setPlayerId( playerId )
    self.text_playerid:setString(playerId)
    self.magicprop:setPlayerId(playerId)
end

--设置最高炮倍
function GamePlayerInfo:setMaxRate( maxGunRate )
    self.text_rate:setString(maxGunRate)
end

--设置等级
function GamePlayerInfo:setGrade( grade )
    self.text_grade:setString(grade)
end

--设置位置
function GamePlayerInfo:setChairId( chairId )
    self.chairId = chairId
end 

--是否开启踢人
function GamePlayerInfo:openKickOut(bKickOut)
    self.bKickOut = bKickOut and bKickOut or false
    self.btn_kickout:setVisible(self.bKickOut)
end

--踢出房间
function GamePlayerInfo:onClickKickOut( sender )
    self.parent_:buttonClicked("GamePlayerInfo", self.chairId)
end

function GamePlayerInfo:onTouchBegan(touch, event) 
    if not self:isVisible() then
        return false
    end

    local curPos = touch:getLocation()  
    local s = self.img_bg:getContentSize()
    local locationInNode = self.img_bg:convertToNodeSpace(curPos)
    local rect = cc.rect(0,0,s.width,s.height)
    if cc.rectContainsPoint(rect,locationInNode) then
        return true
    end

    self:hideAct()
    return false
end

return GamePlayerInfo