
local GunCard = class("GunCard", cc.load("mvc").ViewBase)

GunCard.AUTO_RESOLUTION   = 0
GunCard.RESOURCE_FILENAME = "ui/battle/selectcannon/uiguncard"
GunCard.RESOURCE_BINDING  = {  
    ["panel"]    = { ["varname"] = "panel" },   
    
    ["spr_nane"] = { ["varname"] = "spr_nane" },    
    ["spr_vip"]  = { ["varname"] = "spr_vip" }, 
    
    ["spr_base"] = { ["varname"] = "spr_base" }, 
    ["spr_gun"]  = { ["varname"] = "spr_gun" }, 
    
    ["btn_use"]  = { ["varname"] = "btn_use" ,      ["events"]={["event"]="click",["method"]="onClickUse"}},
    ["spr_yzb"]  = { ["varname"] = "spr_yzb" },
    ["spr_zb"]   = { ["varname"] = "spr_zb" },
    
    ["btn_get"]  = { ["varname"] = "btn_get" ,      ["events"]={["event"]="click",["method"]="onClickGet"}},
    
    ["spr_lock"] = { ["varname"] = "spr_lock" }, 

    ["btn_taste"]  = { ["varname"] = "btn_taste" ,      ["events"]={["event"]="click",["method"]="onClicktaste"}},
    ["img_taste"] = { ["varname"] = "img_taste" }, 
}

function GunCard:onCreate(...)  
    self.playerVIP = 0
    self.isTaste = false
    self.isCurUsed = false
    self.img_taste:setVisible(false)
    self.seniorDataList = {}
end

function GunCard:setItemData(vip)   
    self.vip = vip
    local vipName = string.format("common/vip/vip_badge_%d.png",(self.vip))
    self.spr_vip:initWithFile(vipName)
    local gunName = string.format("battle/selectcannon/selectcannon_pic_title_%d.png",(self.vip))
    self.spr_nane:initWithFile(gunName)

    local gunFile = "battle/cannon/"..FishGI.GameTableData:getGunOutlookTableByVip(self.vip).cannon_img
    self.spr_gun:initWithFile(gunFile)

    local baseFile = "battle/cannon/"..FishGI.GameTableData:getGunOutlookTableByVip(self.vip).base_img
    self.spr_base:initWithFile(baseFile)

end

function GunCard:onClickUse( sender )
    local uiSelectCannon = FishGF.getLayerByName("uiSelectCannon")
    uiSelectCannon:hideLayer()

    --发送换炮消息
    FishGI.gameScene.net:sendNewGunType(self.vip+1)

end

function GunCard:onClickGet( sender )
    local uiSelectCannon = FishGF.getLayerByName("uiSelectCannon")
    uiSelectCannon:hideLayer()

    local uiVipRight = FishGF.getLayerByName("uiVipRight")
    uiVipRight:showLayer()
    uiVipRight:upDataLayerByVIPLV(self.vip)
    
end

function GunCard:setType(playerVIP)  
    self.playerVIP = playerVIP
end

function GunCard:setCurUse(isCurUsed)  
    if isCurUsed == nil then
        return 
    end
    self.isCurUsed = isCurUsed
end

function GunCard:setIsCanTaste( isTaste,seniorData)  
    if isTaste == nil  then
        return 
    end
    if seniorData ~= nil and next(seniorData) ~= 0 then
        table.insert( self.seniorDataList,seniorData )
    end

    local isusing = false
    for k,v in pairs(self.seniorDataList) do
        if FishGF.isSeniorUsing( v ) then
            isusing = true
        end
    end

    self.isTaste = isTaste
    self.isusing = isusing

end

function GunCard:updateView()
    self:hideAllBtn()
    self.img_taste:setVisible(self.isusing)

    if self.playerVIP < self.vip then
        self.spr_lock:setVisible(true)
    elseif self.playerVIP >= self.vip then
        self.spr_lock:setVisible(false)
    end 

    --已装备
    if self.isCurUsed then
        self.btn_use:setVisible(true)
        self.spr_zb:setVisible(false)
        self.spr_yzb:setVisible(true)
        self.btn_use:setEnabled(false)
        return 
    end

    --体验
    if self.isTaste and not self.isusing and self.playerVIP < self.vip then
        self.btn_taste:setVisible(true)
        return 
    end

    --获取
    if (not self.isTaste) and  self.playerVIP < self.vip then
        self.btn_get:setVisible(true)
        return
    end

    --装备
    self.btn_use:setVisible(true)
    self.btn_use:setEnabled(true)
    self.spr_zb:setVisible(true)
    self.spr_yzb:setVisible(false)
end

function GunCard:hideAllBtn() 
    self.btn_taste:setVisible(false)
    self.btn_get:setVisible(false)
    self.btn_use:setVisible(false)
    self.btn_use:setEnabled(true)
end

function GunCard:onClicktaste( sender )
    print("----------onClicktaste---------")

    local propId = nil
    for k,v in pairs(self.seniorDataList) do
        if v ~= nil and v.propId ~= nil then
            propId = v.propId
            break
        end
    end
    --发送消息
    FishGI.gameScene.net:sendUsePropCannon(0,propId)

end


return GunCard;