
local cannon = class("cannon", cc.load("mvc").ViewBase)

cannon.AUTO_RESOLUTION   = false
cannon.RESOURCE_FILENAME = "ui/battle/uicannon"
cannon.RESOURCE_BINDING  = {  
       ["node_gun"]           = { ["varname"] = "node_gun" },
       ["spr_cannon"]         = { ["varname"] = "spr_cannon" }, 
       ["spr_gunfire"]        = { ["varname"] = "spr_gunfire" },
       ["spr_gun_lock"]       = { ["varname"] = "spr_gun_lock" },
       
       ["spr_cannon_base"]    = { ["varname"] = "spr_cannon_base" }, 
       ["spr_multiple_bg"]    = { ["varname"] = "spr_multiple_bg" }, 
       ["fnt_multiple"]       = { ["varname"] = "fnt_multiple" },   
       
       ["btn_minus"]          = { ["varname"] = "btn_minus" ,      ["events"]={["event"]="click",["method"]="onClickMinus"}},  
       ["btn_add"]            = { ["varname"] = "btn_add" ,        ["events"]={["event"]="click",["method"]="onClickAdd"}},  
       
       ["spr_coin_bg"]        = { ["varname"] = "spr_coin_bg" },      
       ["fnt_coins"]          = { ["varname"] = "fnt_coins" },  
       ["fnt_diamonds"]       = { ["varname"] = "fnt_diamonds" },  
       ["spr_bankrupt"]       = { ["varname"] = "spr_bankrupt" },
       ["spr_circle"]         = { ["varname"] = "spr_circle" },
       
       ["fnt_curadd"]         = { ["varname"] = "fnt_curadd" },
       
       ["spr_light"]          = { ["varname"] = "spr_light" },
       
       ["node_touch"]         = { ["varname"] = "node_touch" },
    
}

function cannon:onCreate(...)   

    self.fnt_curadd:setOpacity(0)
    self.spr_gun_lock:setVisible(false)
    self.spr_bankrupt:setVisible(false)
    self.spr_gunfire:setVisible(false)
    self.posX = self.node_gun:getPositionX()
    self.posY = self.node_gun:getPositionY()
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

    local loopkb = require("ui/battle/skill/uiskill_kb_2").create()

    self.loopkbEffect = loopkb.root
    self.loopkbEffect.animation = loopkb["animation"]
    self.loopkbEffect:runAction(loopkb["animation"])
    self.loopkbEffect.animation:play("loopkb", true);
    self.loopkbEffect:setTag(12345)
    self.loopkbEffect:setPositionY(self.spr_circle:getPositionY())
    self.loopkbEffect:setVisible(false)
    self:addChild(self.loopkbEffect, -1);
    
end

function cannon:getRotatePos()
    local pos = self:convertToWorldSpace(cc.p(self.posX, self.posY));
    return pos;
end

function cannon:getLauncherPos()
    local launcherNode = self.node_gun:getChildByTag(1800);
    local pos = self.node_gun:convertToWorldSpace(cc.p(launcherNode:getPositionX(), launcherNode:getPositionY()));
    return pos;
end

function cannon:setDir( dir, isSelf ,playerId)
    self.isSelf = isSelf
    self.dir = dir
    self.playerId = playerId
    if dir == 2  then
        self.spr_coin_bg:setPositionX(-self.spr_coin_bg:getPositionX())
        self.fnt_curadd:setPositionX(-self.fnt_curadd:getPositionX())
    elseif dir == 3 then
        self:setRotation(180)
        self.spr_coin_bg:setRotation(180)
        self.spr_bankrupt:setRotation(180)
        self.fnt_curadd:setRotation(180)
    elseif dir == 4 then
        self:setRotation(180)
        self.spr_coin_bg:setRotation(180)
        self.spr_bankrupt:setRotation(180)
        self.fnt_curadd:setRotation(180)
        self.spr_coin_bg:setPositionX(-self.spr_coin_bg:getPositionX())
        self.fnt_curadd:setPositionX(-self.fnt_curadd:getPositionX())
    end
    self.btn_add:setVisible(isSelf)    
    self.btn_minus:setVisible(isSelf)       
    self:setPosition(cc.p(FishCD.posTab[dir].x * self.scaleX_, FishCD.posTab[dir].y * self.scaleY_))
    self:setScale(self.scaleMin_*self:getScale())

    if self.isSelf ~= true then
        self.spr_circle:setVisible(false)
        self.fnt_curadd:setFntFile("fnt/bonus_num_2.fnt")
        return
    end

    self.spr_circle:setVisible(true)

    --换炮，表情，自动
    self.uiCannonChange = require("Game/CannonPanel").create();
    self:addChild(self.uiCannonChange,10)
    self.uiCannonChange:setPosition(cc.p(0,62))
    self.uiCannonChange:setVisible(false)

    self:gameStartAct()
end

function cannon:playEffectAni(effectId)
    if effectId == FishCD.SKILL_TAG_VIOLENT then
        self.loopkbEffect:setVisible(false)
        local beginkb = require("ui/battle/skill/uiskill_kb_1").create()
        local kbBeginEffect = beginkb.root
        kbBeginEffect.animation = beginkb["animation"]
        kbBeginEffect:runAction(beginkb["animation"])
        kbBeginEffect.animation:play("beginkb", false);
        kbBeginEffect:setPositionY(self.node_touch:getChildren()[1]:getContentSize().height/2)
        
        self:addChild(kbBeginEffect, 100);
        local function frameEvent1(frameEventName)
            if frameEventName:getEvent() == "end" then
                kbBeginEffect:removeFromParent();

                self.loopkbEffect:setVisible(true)
            end
        end
        kbBeginEffect["animation"]:clearFrameEventCallFunc()
        kbBeginEffect["animation"]:setFrameEventCallFunc(frameEvent1)


    end
end

function cannon:endEffectAni(effectId)
    if effectId == FishCD.SKILL_TAG_VIOLENT then
        self.loopkbEffect:setVisible(false)
    end
end

function cannon:gameStartAct() 
    local delatTime = 2
    self:runAction(cc.Sequence:create(cc.DelayTime:create(delatTime + 2),cc.CallFunc:create(function ( ... )
         self.uiCannonChange:setIsOpen(true)

    end),cc.DelayTime:create(1),cc.CallFunc:create(function ( ... )
         self.uiCannonChange:setIsOpen(false)
    end) ))
end

function cannon:runCircle() 
    local spr_circle = self:child("spr_circle")
    spr_circle:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
end

--角度设置
function cannon:setCannonRotation( Rotation )
    if self:getCoins() < self:getMultiple() then
        return
    end
    self.Rotation = Rotation
    self.node_gun:setRotation(Rotation)
end

function cannon:getCannonRotation( )
    return self.node_gun:getRotation()
end

--炮台锚点设置
function cannon:setCannonAnchorPoint( point )
    self.spr_cannon:setAnchorPoint(point)
end

--金币设置
function cannon:setCoins( coins )
    if coins < 0 then
        coins = 0
    end

    self.fnt_coins:setString(coins)

end

function cannon:getCoins( )
    return tonumber(self.fnt_coins:getString())
end

--钻石设置
function cannon:setDiamonds( diamonds )
    if diamonds < 0 then
        diamonds = 0
    end
    self.fnt_diamonds:setString(diamonds)
end

function cannon:getDiamonds( )
    return tonumber(self.fnt_diamonds:getString())
end

--播放切换炮倍特效
function cannon:playChangeEff( )
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
function cannon:setMultiple( multiple )
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

    if multiple > playerSelf.playerInfo.maxGunRate then
        self.spr_gun_lock:setVisible(true)
        FishGI.gameScene.uiSkillView.isGunLock = true
    else
        self.spr_gun_lock:setVisible(false)
        FishGI.gameScene.uiSkillView.isGunLock = false
    end
    self.btn_minus:setTouchEnabled(true)
    self.btn_add:setTouchEnabled(true)

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

function cannon:getMultiple( )
    return tonumber(self.fnt_multiple:getString())
end

--设置是否破产
function cannon:playBankrupt(isBankrupt)
    if isBankrupt then
        self.spr_bankrupt:setVisible(true)
        self.spr_bankrupt:setOpacity(50)
        self.spr_bankrupt:setScale(15.0)
        local spawn = cc.Spawn:create(cc.FadeTo:create(0.25,255),cc.ScaleTo:create(0.25,1))
        self.spr_bankrupt:runAction(spawn)
    else
        self.spr_bankrupt:setVisible(false)
    end

end

--自动调节炮倍
function cannon:upDateRate( )
    local nextRate = FishGMF.getNextRateBtType(3)
    if nextRate ~= nil and nextRate ~= 0 then
        self.btn_minus:setTouchEnabled(false)
        self.btn_add:setTouchEnabled(false)

        self:setMultiple(nextRate)
        FishGMF.changeGunRate(nil,nextRate,0)
        FishGI.gameScene.net:sendNewGunRate(nextRate)
    end
end

--加回调
function cannon:onClickAdd( sender )
    if self.spr_bankrupt:isVisible() then
        return
    end

    local nextRate = FishGMF.getNextRateBtType(1)
    if nextRate ~= nil and nextRate ~= 0 then
        print("onClickAdd")
        self.btn_minus:setTouchEnabled(false)
        self.btn_add:setTouchEnabled(false)

        self:setMultiple(nextRate)
        FishGMF.changeGunRate(nil,nextRate,0)
        FishGI.gameScene.net:sendNewGunRate(nextRate)
    end
end

--减回调
function cannon:onClickMinus( sender )
    if self.spr_bankrupt:isVisible() then
        return
    end

    local nextRate = FishGMF.getNextRateBtType(2)
    if nextRate ~= nil and nextRate >= 0 then
        print("onClickMinus")
        self.btn_minus:setTouchEnabled(false)
        self.btn_add:setTouchEnabled(false)

        self:setMultiple(nextRate)
        FishGMF.changeGunRate(nil,nextRate,0)
        FishGI.gameScene.net:sendNewGunRate(nextRate)
    end
end

function cannon:onTouchBegan(touch, event) 
    local curPos = touch:getLocation()  
    for k,area in pairs(self.node_touch:getChildren()) do
        local s = area:getContentSize()
        local locationInNode = area:convertToNodeSpace(curPos)
        local rect = cc.rect(0,0,s.width,s.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            if self.isSelf then
                self.uiCannonChange:setIsOpen(not self.uiCannonChange.isOpen)
            else
                -- --发送获取玩家消息
                -- FishGI.gameScene.net:sendUpDataPlayerData(self.playerId)

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

function cannon:onTouchCancelled(touch, event)
end

--换炮
function cannon:gunChangeByData(id)
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

return cannon;