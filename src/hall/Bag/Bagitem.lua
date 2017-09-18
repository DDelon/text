
local Bagitem = class("Bagitem", cc.load("mvc").ViewBase)

Bagitem.AUTO_RESOLUTION   = 0
Bagitem.RESOURCE_FILENAME = "ui/hall/bag/uibagitem"
Bagitem.RESOURCE_BINDING  = {  
    ["panel"]           = { ["varname"] = "panel" },   
    
    ["spr_item"]        = { ["varname"] = "spr_item" },    
    ["fnt_item_count"]  = { ["varname"] = "fnt_item_count" }, 
    ["spr_chooseframe"] = { ["varname"] = "spr_chooseframe" }, 

}

function Bagitem:onCreate(...)   
    self.itemId = -1 
    self.itemCount = -1
    self.spr_chooseframe:setVisible(false)

    local size = self.panel:getContentSize()
    self.width = size.width
    self.fntScale = self.fnt_item_count:getScale()
end

function Bagitem:setItemData(itemId,itemCount)   
    if self.itemCount == itemCount and self.itemId == itemId then
        return
    end
    self.itemId = itemId
    self.itemCount = itemCount 
    if itemId <= 0 then
        self.spr_item:setVisible(false)
        self.fnt_item_count:setVisible(false)
        return
    else
        self.spr_item:setVisible(true)
        self.fnt_item_count:setVisible(true)
    end
    self:setItemCount(itemCount)

    return self:setItemId(itemId)
end

function Bagitem:setItemId(itemId)
    self.itemId = itemId
    local pos = self.spr_item:getPosition()
    local scale = self.spr_item:getScale()
    local AnchorPoint = self.spr_item:getAnchorPoint()
    local propName = FishGI.GameTableData:getItemTable(itemId).res
    if propName == nil or propName == "" then
        return false
    end
    local res = "common/prop/"..propName
    self.spr_item:initWithFile(res);
    self.spr_item:setAnchorPoint(AnchorPoint)
    self.spr_item:setScale(scale)
    return true
end

function Bagitem:getItemId()   
    return self.itemId
end

function Bagitem:setItemCount(itemCount)
    self.itemCount = itemCount 
    local countStr = FishGF.changePropUnitByID(self.itemId,self.itemCount,false)
    self.fnt_item_count:setString(countStr)
    FishGF.isScaleByCount(self.fnt_item_count,countStr,self.fnt_item_count:getContentSize().width,self.width - 20)
end

function Bagitem:getItemCount()   
    return self.itemCount
end

function Bagitem:setSeniorData(seniorData)
    self.seniorData = seniorData 
end

function Bagitem:getSeniorData()   
    return self.seniorData
end

function Bagitem:setChooseState(isChoose)
    self.isChoose = isChoose 
    self.spr_chooseframe:setVisible(isChoose)
end

function Bagitem:onClickItem( sender )

end

function Bagitem:setDropItemData(dropId,dropCount)   
    self.itemId = dropId
    self.itemCount = dropCount 
    if dropId <= 0 or dropCount <=0 then
        self.spr_item:setVisible(false)
        self.fnt_item_count:setVisible(false)
        return
    else
        self.spr_item:setVisible(true)
        self.fnt_item_count:setVisible(true)
    end
    self:setItemCount(dropCount)

    self.itemId = dropId
    local pos = self.spr_item:getPosition()
    local scale = self.spr_item:getScale()
    local AnchorPoint = self.spr_item:getAnchorPoint()
    self.spr_item:initWithFile("common/prop/"..FishGI.GameTableData:getItemTable(self.itemId).res)
    self.spr_item:setAnchorPoint(AnchorPoint)
    self.spr_item:setScale(scale)


end

return Bagitem;