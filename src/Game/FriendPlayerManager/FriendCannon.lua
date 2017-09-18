
local FriendCannon = class("FriendCannon", cc.load("mvc").ViewBase)

FriendCannon.AUTO_RESOLUTION   = false
FriendCannon.RESOURCE_FILENAME = "ui/battle/friend/uifriendcannon"
FriendCannon.RESOURCE_BINDING  = {  
    ["node_bottom"]         = { ["varname"] = "node_bottom" },
    ["spr_circle"]          = { ["varname"] = "spr_circle" },
    ["spr_cannon_base"]     = { ["varname"] = "spr_cannon_base" }, 
    ["node_gun"]            = { ["varname"] = "node_gun" },
    ["spr_gunfire"]         = { ["varname"] = "spr_gunfire" },
    ["spr_cannon"]          = { ["varname"] = "spr_cannon" }, 
    ["spr_multiple_bg"]     = { ["varname"] = "spr_multiple_bg" }, 
    ["node_touch"]          = { ["varname"] = "node_touch" },
    ["fnt_multiple"]        = { ["varname"] = "fnt_multiple" },  
    ["spr_gun_lock"]        = { ["varname"] = "spr_gun_lock" }, 
    ["spr_light"]           = { ["varname"] = "spr_light" }, 
    ["node_top"]            = { ["varname"] = "node_top" },
}

function FriendCannon:onCreate(...)   

    self.scaleX_,self.scaleY_,self.scaleMin_  = FishGF.getCurScale()
    self.spr_gun_lock:setVisible(false)
    self.spr_gunfire:setVisible(false)
    self.posX = self.resourceNode_:getPositionX()+self.node_gun:getPositionX()
    self.posY = self.resourceNode_:getPositionY()+self.node_gun:getPositionY()
    self.spr_light:setOpacity(0)

    --launcher node 发射子弹的结点
    local launcherNode = cc.Node:create();
    --launcherNode:setContentSize(cc.size(3, 3));
    launcherNode:setPosition(cc.p(0, 100));
    self.node_gun:addChild(launcherNode, 10, 1800);

    self.maxGunRate = 1
    self.cannonID = nil

    self.Rotation = 0
    --self:setMultiple(1)

    self:openTouchEventListener()
    
end

function FriendCannon:getLauncherPos()
    local launcherNode = self.node_gun:getChildByTag(1800);
    local pos = self.node_gun:convertToWorldSpace(cc.p(launcherNode:getPositionX(), launcherNode:getPositionY()));
    return pos;
end

function FriendCannon:setDir( dir, isSelf ,playerId)
    self.isSelf = isSelf
    self.dir = dir
    self.playerId = playerId

    if self.isSelf ~= true then
        self.spr_circle:setVisible(false)
        return
    end

    self.spr_circle:setVisible(true)

    --换炮，表情，自动
    if self.uiCannonChange == nil then
        self.uiCannonChange = require("Game/CannonPanel").create()
        self.node_touch:addChild(self.uiCannonChange)
        self.uiCannonChange:setPosition(cc.p(0,62))
        self.uiCannonChange:setVisible(false)
    end

    self:gameStartAct()
end

function FriendCannon:gameStartAct() 
    local delatTime = 2
    self:runAction(cc.Sequence:create(cc.DelayTime:create(delatTime + 2),cc.CallFunc:create(function ( ... )
         self.uiCannonChange:setIsOpen(true)

    end),cc.DelayTime:create(1),cc.CallFunc:create(function ( ... )
         self.uiCannonChange:setIsOpen(false)
    end) ))
end

function FriendCannon:runCircle() 
    local spr_circle = self:child("spr_circle")
    spr_circle:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
end

--角度设置
function FriendCannon:setCannonRotation( Rotation )
    self.Rotation = Rotation
    self.node_gun:setRotation(Rotation)
end

function FriendCannon:getCannonRotation( )
    return self.node_gun:getRotation()
end

--播放切换炮倍特效
function FriendCannon:playChangeEff( )
    FishGI.AudioControl:playEffect("sound/gunswitch_01.mp3")
    self.spr_light:stopAllActions()
    self.spr_light:setOpacity(0)
    self.spr_light:setScale(1)
    local act1 = cc.FadeTo:create(0.04,255)
    local act3 = cc.ScaleTo:create(0.08,1.5)
    local act4 = cc.FadeTo:create(0.04,0)

    self.spr_light:runAction(cc.Sequence:create(act1,act3,act4))
    self.node_gun:stopAllActions()
    self.node_gun:setOpacity(255)
    self.node_gun:setScale(1)
    local gunact1 = cc.ScaleTo:create(0.04,0.5)
    local gunact2 = cc.ScaleTo:create(0.08,1)
    self.node_gun:runAction(cc.Sequence:create(gunact1,gunact2))

end

--倍数设置
function FriendCannon:setMultiple( multiple )
 --   print("--------------------setMultiple------------multiple="..multiple)
    if multiple ~= self:getMultiple() then
        self:playChangeEff()
    end
    self.fnt_multiple:setString(multiple)
    if self.isSelf ~= true then
        return
    end

    local playerSelf =  FishGI.gameScene.playerManager:getMyData()
    if playerSelf == nil then
        return
    end

    local dataTab = {}
    dataTab.funName = "getGunInterval"
    dataTab.curRate = multiple
    local gunInterval = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)["gunInterval"]/1000;
    if gunInterval ~= nil and gunInterval ~= 0 and gunInterval ~= FishCD.PLAYER_SHOOT_INTERVAL then
        FishCD.PLAYER_SHOOT_INTERVAL = gunInterval
        local act1 = self:getParent():getActionByTag(10101);
        if act1 ~= nil then
            local act2seq = act1:getInnerAction();
            act2seq:setDuration(FishCD.PLAYER_SHOOT_INTERVAL)
        end
    end

end

function FriendCannon:getMultiple( )
    return tonumber(self.fnt_multiple:getString())
end

--自动调节炮倍
function FriendCannon:upDateRate( )
    local nextRate = FishGMF.getNextRateBtType(3)
    if nextRate ~= nil and nextRate ~= 0 then
        self:setMultiple(nextRate)
        FishGMF.changeGunRate(nil,nextRate,0)
        FishGI.gameScene.net:sendNewGunRate(nextRate)
    end
end

function FriendCannon:onTouchBegan(touch, event) 
    local curPos = touch:getLocation()  
    for k,area in pairs(self.node_touch:getChildren()) do
        local s = area:getContentSize()
        local locationInNode = area:convertToNodeSpace(curPos)
        local rect = cc.rect(0,0,s.width,s.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            if self.isSelf then
                self.uiCannonChange:setIsOpen(not self.uiCannonChange.isOpen)
            else
                local player = FishGI.gameScene.playerManager:getPlayerByChairId(self.dir)
                if player ~= nil then
                    player:showPlayerInfo()
                end
            end
            return true
        end
    end

    if self.isSelf and self.uiCannonChange ~= nil then
        self.uiCannonChange:setIsOpen(false)
    end

    return false

end

function FriendCannon:onTouchCancelled(touch, event)
end

--换炮
function FriendCannon:gunChangeByData(id)
    local gunData = FishGI.GameTableData:getCannonoutlookTable(id)
    local gunType  =gunData.type
    local base_img  =gunData.base_img
    local cannon_img  =gunData.cannon_img
    local fire_pos  =gunData.fire_pos
    local bullet_img  =gunData.bullet_img
    local fire_effect  =gunData.fire_effect
    local net_res  =gunData.net_res
    local net_radius  =gunData.net_radius

    --炮身图片
    local posx = self.spr_cannon:getPositionX()
    local posy = self.spr_cannon:getPositionY()
    local scale = self.spr_cannon:getScale()
    local AnchorPoint = self.spr_cannon:getAnchorPoint()
    self.spr_cannon:initWithFile("battle/cannon/"..cannon_img)
    self.spr_cannon:setAnchorPoint(AnchorPoint)
    self.spr_cannon:setPosition(cc.p(posx,posy))
    self.spr_cannon:setScale(scale)
    
    --炮座图片资源
    self.spr_cannon_base:initWithFile("battle/cannon/"..base_img)

    FishGI.AudioControl:playEffect("sound/gunswitch_01.mp3")
end

--设置炮台是否变灰
function FriendCannon:setCannonIsGray( isGray )
    if isGray then
        FishGF.spriteToGray(self.spr_cannon)
        FishGF.spriteToGray(self.spr_cannon_base)
    else
        FishGF.grayToNormal(self.spr_cannon)
        FishGF.grayToNormal(self.spr_cannon_base)
    end
end

function FriendCannon:startFirePowerAni()
    self.spr_cannon:setColor(cc.c3b(255, 52, 0))
    self.spr_cannon:setOpacity(255/2)
    local actionCannon = cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 255), cc.FadeTo:create(0.5, 255/2)));
    self.spr_cannon:runAction(actionCannon)
end 

function FriendCannon:stopFirePowerAni()
    self.spr_cannon:stopAllActions()
    self.spr_cannon:setColor(cc.c3b(255, 255, 255))
    self.spr_cannon:setOpacity(255)
end

function FriendCannon:getAniNodeLayer()
    return self.node_top, self.node_bottom
end

return FriendCannon;