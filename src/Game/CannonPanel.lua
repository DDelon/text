local CannonPanel = class("CannonPanel", cc.load("mvc").ViewBase)

CannonPanel.isOpen            = false
CannonPanel.AUTO_RESOLUTION   = false
CannonPanel.RESOURCE_FILENAME = "ui/battle/uigunchange"
CannonPanel.RESOURCE_BINDING  = {    
    ["btn_face"]         = { ["varname"] = "btn_face" ,         ["events"]={["event"]="click",["method"]="onClickFace"}},
    ["btn_autofire"]     = { ["varname"] = "btn_autofire" ,     ["events"]={["event"]="click",["method"]="onClickAutoFire"}},
    ["btn_changecannon"] = { ["varname"] = "btn_changecannon" , ["events"]={["event"]="click",["method"]="onClickChange"}},
}

function CannonPanel:onCreate( ... )
    self.posArr = {}
    for nodeName, node in pairs(self.RESOURCE_BINDING) do  
        self.posArr[nodeName] = {}
        self.posArr[nodeName].x = self[nodeName]:getPositionX()
        self.posArr[nodeName].y = self[nodeName]:getPositionY()
    end

    local spr_autofire = self.btn_autofire:getChildByName("spr_autofire")
    local spr_cancelauto = self.btn_autofire:getChildByName("spr_cancelauto")
    if FishGI.isAutoFire then

        spr_autofire:setVisible(false)
        spr_cancelauto:setVisible(true)
    else
        spr_autofire:setVisible(true)
        spr_cancelauto:setVisible(false)
    end
    
    self.emoji = require("Game/Emoji/EmojiLayer").new()
    FishGI.gameScene:addChild(self.emoji, FishCD.ORDER_GAME_emotion);
    self.emoji:setVisible(false)

    --self.magicprop = require("Game/MagicProp/MagicProp").new()
    --FishGI.gameScene:addChild(self.magicprop, FishCD.ORDER_GAME_magicprop);
    --self.magicprop:setVisible(false)

    
end

function CannonPanel:setIsOpen( isOpen )
    -- if self.isOpen == isOpen then
    --     return
    -- end
    self.isOpen = isOpen
     self:setVisible(true)
    if self.isOpen == true then
        self:setVisible(true)
        for nodeName, node in pairs(self.RESOURCE_BINDING) do 
            self[nodeName]:setVisible(true)  
            self[nodeName]:stopAllActions()
            self[nodeName]:setPosition(cc.p(0,0))
            self[nodeName]:setScale(0)
            self[nodeName]:runAction(cc.ScaleTo:create(0.1,1))
            self[nodeName]:runAction(cc.MoveTo:create(0.2,cc.p(self.posArr[nodeName].x,self.posArr[nodeName].y)))
        end
    else
        for nodeName, node in pairs(self.RESOURCE_BINDING) do   
            self[nodeName]:stopAllActions()
            self[nodeName]:runAction(cc.ScaleTo:create(0.1,0))
            self[nodeName]:runAction(cc.MoveTo:create(0.1,cc.p(0,0)))
            self[nodeName]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( 
                function() 
                    self[nodeName]:setPosition(cc.p(self.posArr[nodeName].x,self.posArr[nodeName].y))
                    self[nodeName]:setScale(1)
                    self[nodeName]:setVisible(false)
                end)));
        end

    end
end

function CannonPanel:onClickFace( sender )
    self:setIsOpen(false)
    if self.emoji:isVisible() then
        self.emoji:showFaceDlg(false)
    else
        self.emoji:showFaceDlg(true)
        --self:setVisible(false)
    end

end

function CannonPanel:onClickAutoFire( sender )

    if not FishGI.isGetMonthCard then
        local uiMonthcard = FishGF.getLayerByName("uiMonthcard")
        uiMonthcard:showLayer()
        return
    end
    print("onClickAutoFire")
    if FishGI.isLock then
        return
    end

    FishGI.isAutoFire = not FishGI.isAutoFire
    local spr_autofire = self.btn_autofire:getChildByName("spr_autofire")
    local spr_cancelauto = self.btn_autofire:getChildByName("spr_cancelauto")
    local playerSelf =  FishGI.gameScene.playerManager:getMyData()
    if FishGI.isAutoFire then
        spr_autofire:setVisible(false)
        spr_cancelauto:setVisible(true)
        local degree = playerSelf.cannon.node_gun:getRotation()
        playerSelf:shootByDegree(degree +90);
    else
        spr_autofire:setVisible(true)
        spr_cancelauto:setVisible(false)
        playerSelf:endShoot();
    end
end

function CannonPanel:setAutoFire( isAuto )
    print("setAutoFire")
    FishGI.isAutoFire = isAuto
    local spr_autofire = self.btn_autofire:getChildByName("spr_autofire")
    local spr_cancelauto = self.btn_autofire:getChildByName("spr_cancelauto")
    local playerSelf =  FishGI.gameScene.playerManager:getMyData()
    if FishGI.isAutoFire then
        spr_autofire:setVisible(false)
        spr_cancelauto:setVisible(true)
        local degree = playerSelf.cannon.node_gun:getRotation()
        playerSelf:shootByDegree(degree +90);
    else
        spr_autofire:setVisible(true)
        spr_cancelauto:setVisible(false)
        playerSelf:endShoot();
    end
end

function CannonPanel:onClickChange( sender )
    print("onClickChange")
    local uiSelectCannon = FishGF.getLayerByName("uiSelectCannon")
    uiSelectCannon:showLayer()
end

return CannonPanel;