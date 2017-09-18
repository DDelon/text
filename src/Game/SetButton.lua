local SetButton = class("SetButton", cc.load("mvc").ViewBase)

SetButton.isOpen            = false
SetButton.AUTO_RESOLUTION   = false
SetButton.RESOURCE_FILENAME = "ui/battle/uisetbutton"
SetButton.RESOURCE_BINDING  = {    
    ["image_bg"]     = { ["varname"] = "image_bg" },   
    ["btn_openlist"] = { ["varname"] = "btn_openlist" ,      ["events"]={["event"]="click",["method"]="onClickOpenlist"}},
    ["spr_triangle"] = { ["varname"] = "spr_triangle" },
    ["btn_pokedex"]  = { ["varname"] = "btn_pokedex"  ,      ["events"]={["event"]="click",["method"]="onClickPokedex"}},    
    ["btn_sound"]    = { ["varname"] = "btn_sound" ,         ["events"]={["event"]="click",["method"]="onClickSound"}},
    ["btn_exit"]     = { ["varname"] = "btn_exit",           ["events"]={["event"]="click",["method"]="onClickExit"} },

}

function SetButton:onCreate( ... )
    self:openTouchEventListener()
end

function SetButton:onTouchBegan(touch, event) 
    if self.isOpen == true then
        self:setIsOpen()
    end   
    return false
end

function SetButton:onTouchCancelled(touch, event)
    if self.isOpen == true then
        self:setIsOpen()
    end     
end

function SetButton:onClickOpenlist( sender )
    print("onClickOpenlist")

    self:setIsOpen()
end

function SetButton:setIsOpen( fScaleX )
    print("setIsOpen")
    fScaleX = fScaleX ~= nil and fScaleX or self.scaleMin_
    self.fScaleX = fScaleX
    self.isOpen = not self.isOpen
    
    if self.posTab == nil then 
        self.posTab = cc.p(self:getPositionX(),self:getPositionY())
    end 

    self:stopAllActions()
    if self.isOpen == true then
        self.spr_triangle:setRotation(0)
        self:runAction(cc.MoveTo:create(0.2,cc.p(self.posTab.x-self.image_bg:getContentSize().width*fScaleX*0.9,self.posTab.y)))
    else
        self.spr_triangle:setRotation(180)
        self:runAction(cc.MoveTo:create(0.2,cc.p(self.posTab.x,self.posTab.y)))
    end
end

function SetButton:onClickPokedex( sender )
    if self.isOpen == false then
        return
    end
    print("onClickPokedex")
    local uiFishForm = FishGF.getLayerByName("uiFishForm")

    uiFishForm.isFromLottery = nil
    uiFishForm:showLayer() 
end

function SetButton:onClickSound( sender )
    if self.isOpen == false then
        return
    end
    print("onClickSound")
    local uiSoundSet = FishGF.getLayerByName("uiSoundSet")

    uiSoundSet:initData()
    uiSoundSet:showLayer()
end

function SetButton:onClickExit( sender )
    if self.isOpen == false then
        return
    end
    print("onClickExit")
    self.parent_:buttonClicked("SetButton", "exit")

end
return SetButton;