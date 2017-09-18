local GunUpGrade = class("GunUpGrade", cc.load("mvc").ViewBase)

GunUpGrade.isOpen            = false
GunUpGrade.AUTO_RESOLUTION   = false
GunUpGrade.RESOURCE_FILENAME = "ui/battle/uigunupgrade"
GunUpGrade.RESOURCE_BINDING  = {    
    ["node_spr"]         = { ["varname"] = "node_spr" },  
    ["btn_upgrade"]      = { ["varname"] = "btn_upgrade" ,      ["events"]={["event"]="click",["method"]="onClickUpgrade"}},
    ["image_upgrade_bg"] = { ["varname"] = "image_upgrade_bg" },
    ["bar_LoadingBar"]   = { ["varname"] = "bar_LoadingBar" },
    ["fnt_curNum"]       = { ["varname"] = "fnt_curNum" },
    ["fnt_aimNun"]       = { ["varname"] = "fnt_aimNun" },     
    ["node_animation"]   = { ["varname"] = "node_animation" },  
    
    
    ["node_bar"]         = { ["varname"] = "node_bar" },  
    
    ["node_sendcoin"]    = { ["varname"] = "node_sendcoin" },  
    ["fnt_coin"]         = { ["varname"] = "fnt_coin" },  

}

function GunUpGrade:onCreate( ... )
    self:runAction(self.resourceNode_["animation"])
    self.resourceNode_["animation"]:play("upGunPanel", true);
    
    self:openTouchEventListener()
    self.node_spr:setVisible(false)
    self.image_upgrade_bg:setPositionX(self.image_upgrade_bg:getPositionX()-self.image_upgrade_bg:getContentSize().width*0.68)

    FishGI.eventDispatcher:registerCustomListener("GunUpgrade", self, function(valTab) self:GunUpgrade(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("myGunUpData", self, function(valTab) self:myGunUpData(valTab) end);

    self.curCrystal  = 0
    self.aimCrystal = 4
    self.nextRate = 0
    -- self.resourceNode_["animation"]:pause()
    -- self.node_animation:setVisible(false)

    self:setIsOpen(false)


end

function GunUpGrade:setCurMultiple(multiple)
    local nextRate,gunData = FishGMF.getNextRateBtType(4)
    if nextRate == nil or nextRate == 0 then
        return
    end

    self.nextRate = nextRate
    self:child("fnt_multiple_1"):setString(self.nextRate)
    self:child("fnt_multiple_2"):setString(self.nextRate)
    self:child("fnt_multiple_3"):setString(self.nextRate)

    local unlock_gem = tonumber(gunData["unlock_gem"])
    local unlock_award = tonumber(gunData["unlock_award"])
    
    self:setAimCrystal(unlock_gem)
    self.fnt_coin:setString(unlock_award)

end

function GunUpGrade:setCurCrystal(curCrystal)
    self.curCrystal = tonumber(curCrystal)
    self.fnt_curNum:setString(curCrystal)
    self:upDataBar()
end

function GunUpGrade:setAimCrystal(aimCrystal)
    self.aimCrystal = tonumber(aimCrystal)
    self.fnt_aimNun:setString(aimCrystal)
    self:upDataBar()
end

function GunUpGrade:getAimCrystal()
    return self.aimCrystal
end

function GunUpGrade:upDataBar()
    if self.curCrystal == nil or self.aimCrystal == nil then
        return
    end

    if self.curCrystal/self.aimCrystal < 1 then
        self:setIsRunAct(false)
        self.bar_LoadingBar:setPercent(self.curCrystal/self.aimCrystal*100)
        self.node_bar:setVisible(true)
        self.node_sendcoin:setVisible(false)
    else
        self.bar_LoadingBar:setPercent(100)
        self:setIsOpen(true)
        self.node_bar:setVisible(false)
        self.node_sendcoin:setVisible(true)
    end
end

function GunUpGrade:setIsRunAct(isRun)
    if isRun then
        self.resourceNode_["animation"]:resume()
        self.node_animation:setVisible(true)
        self:child("fnt_multiple_2"):setVisible(true)
        self:child("fnt_multiple_3"):setVisible(true)
    else
        self.resourceNode_["animation"]:pause()
        self.node_animation:setVisible(false)
        self:child("fnt_multiple_2"):setVisible(false)
        self:child("fnt_multiple_3"):setVisible(false)
    end
end

function GunUpGrade:onTouchBegan(touch, event)
    if not self:isVisible() then
        return false
    end
    local curPos = touch:getLocation()  
    local size = self.image_upgrade_bg:getContentSize()
    local locationInNode = self.image_upgrade_bg:convertToNodeSpace(curPos)
    local rect = cc.rect(0,0,size.width,size.height)
    if cc.rectContainsPoint(rect,locationInNode) then
        if self.isOpen == false then
            self:setIsOpen(true)
        else
            FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
            if self.curCrystal >= self.aimCrystal then
                --要发送解锁炮倍消息
                --FishGMF.isSurePropData(FishGI.gameScene.playerManager.selfIndex,FishCD.PROP_TAG_02,self.aimCrystal,false)
                FishGI.gameScene.net:sendUpgradeCannon()
            else
                local function callback(sender)
                    local tag = sender:getTag()
                    if tag == 2 then
                        FishGI.gameScene.uiShopLayer:showLayer()
                        FishGI.gameScene.uiShopLayer:setShopType(2)
                    end
                end
                FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000093),callback)
            end 
        end 
        return true
    else 
        if self.curCrystal >= self.aimCrystal then
            self:setIsOpen(true)
        else
            if self.isOpen == true then
                self:setIsOpen(false)
            end 
        end 
    end

    return false
end

function GunUpGrade:onTouchCancelled(touch, event)
 
end

function GunUpGrade:setIsOpen(isOpen )
    self.isOpen = isOpen
    if self.isOpen == true then
        self.node_spr:setVisible(true)
        self.image_upgrade_bg:stopAllActions()
        self.image_upgrade_bg:runAction(cc.MoveTo:create(0.2,cc.p(0,0)))

    else
        self.image_upgrade_bg:stopAllActions()
        self.image_upgrade_bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(-self.image_upgrade_bg:getContentSize().width*0.68,0)), 
            cc.CallFunc:create( function() self.node_spr:setVisible(false); end)));
    end

    if self.curCrystal >= self.aimCrystal then
        self:setIsRunAct(true)
    else
        self:setIsRunAct(false)
    end

end

function GunUpGrade:onClickUpgrade( sender )
    if self.curCrystal < self.aimCrystal then
        self:setIsOpen( not self.isOpen )
    else
        self:setIsOpen(true)
    end
end

--炮倍解锁
function GunUpGrade:GunUpgrade(valTab)
    local isSuccess = valTab.isSuccess
    local newFishIcon = valTab.newFishIcon
    local newCrystal = valTab.newCrystal
    local costProps = valTab.costProps
    local curRate = valTab.nextRate

    self:setCurMultiple(curRate)
    self:setCurCrystal(newCrystal)
    if self.curCrystal >= self.aimCrystal then
        self:setIsOpen(true)
    else
        self:setIsOpen(false) 
    end
end

--数据变动
function GunUpGrade:myGunUpData(valTab)
--    print("-1111-GunUpGrade-myGunUpData--")
    local playerId = valTab.playerId;
    local newCrystal = valTab.newCrystal;
    if newCrystal == nil or newCrystal < 0 then
        return
    end
    
    self:setCurCrystal(newCrystal)
    if self.curCrystal >= self.aimCrystal then
        self:setIsOpen(true)
        self.node_bar:setVisible(false)
        self.node_sendcoin:setVisible(true)
    else
        self:setIsRunAct(false)

        self.node_animation:setVisible(false)
        self.node_bar:setVisible(true)
        self.node_sendcoin:setVisible(false)       
    end
end

function GunUpGrade:isCanGunUpData()
    if self.curCrystal >= self.aimCrystal then
        return true
    end
    return false
end

return GunUpGrade;