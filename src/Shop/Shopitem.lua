
local Shopitem = class("Shopitem", cc.load("mvc").ViewBase)

Shopitem.AUTO_RESOLUTION   = false
Shopitem.RESOURCE_FILENAME = "ui/shop/uishopitem"
Shopitem.RESOURCE_BINDING  = {  
    ["panel"]         = { ["varname"] = "panel" },   
    ["spr_shop_item"] = { ["varname"] = "spr_shop_item" },   
    
    ["text_name"]     = { ["varname"] = "text_name" }, 
    ["text_word"]     = { ["varname"] = "text_word" }, 
    ["btn_buy"]       = { ["varname"] = "btn_buy" ,         ["events"]={["event"]="click",["method"]="onClickBuy"}},   
    ["fnt_price"]     = { ["varname"] = "fnt_price" }, 

}

function Shopitem:onCreate(...)   
    local d = 1
end

function Shopitem:setItemData(valTab)   
    self.id = valTab.id
    self.recharge_name = valTab.recharge_name
    local recharge_type = valTab.recharge_type
    local recharge = valTab.recharge
    local recharge_num = valTab.recharge_num
    local gift_num = valTab.gift_num
    local recharge_method = valTab.recharge_method
    local frist_change_enable = valTab.frist_change_enable
    local recharge_res = valTab.recharge_res

    self:setType(recharge_type)
    self:setPrice(recharge)
    self:setGoodsNum(recharge_num)
    self:setItemPic( recharge_res )
    self:setIsRecharge(frist_change_enable)
    self:setExtraCharges(gift_num)
    self:setGoodsName(self.recharge_name)
end

function Shopitem:updateItem(frist_change_enable)
    self:setIsRecharge(frist_change_enable);
    self:setExtraCharges(self.gift_num);
end

--类型  鱼币 水晶
function Shopitem:setType( recharge_type )
    self.recharge_type = recharge_type
    if recharge_type == 1 then
        self.unit = FishGF.getChByIndex(800000098)
    elseif recharge_type == 2 then
        self.unit = FishGF.getChByIndex(800000099)
    elseif recharge_type == 3 then
        self.unit = "月卡"
    end
    
end

--商城IOCN资源
function Shopitem:setItemPic( recharge_res )
    self.spr_shop_item:initWithFile("shop/"..recharge_res)
end

--充值额度
function Shopitem:setPrice( recharge )
    self.recharge = recharge
    self.fnt_price:setString((recharge/100).."$")
end

--得到货币数值
function Shopitem:setGoodsNum( recharge_num )
    self.recharge_num = recharge_num
end

--设置物品名称
function Shopitem:setGoodsName( recharge_name )
    self.recharge_name = recharge_name
    self.text_name:setString(recharge_name)
end

--是否首充，或者充值过了
function Shopitem:setIsRecharge( isRecharge )
    self.isRecharge = isRecharge

end

--额外赠送
function Shopitem:setExtraCharges( gift_num )
    self.gift_num = gift_num
    local str = nil
    if self.isRecharge == 1 then
        str = FishGF.getChByIndex(800000100)
    else
        if self.gift_num == 0 then
            str = ""
        else
            str = FishGF.getChByIndex(800000101)..gift_num..self.unit
        end
    end
    if self.recharge_type == 3 then
        str = FishGF.getChByIndex(800000311)
    end
    self.text_word:setString(str)
end

function Shopitem:onClickBuy( sender )
    if self.recharge_type == 3 then
        local uiShopLayer = FishGF.getLayerByName("uiShopLayer")
        uiShopLayer:hideLayer() 
        local uiMonthcard = FishGF.getLayerByName("uiMonthcard")
        if uiMonthcard ~= nil then
            uiMonthcard:showLayer() 
        end
        return 
    end

    print("id-----"..self.id);
    local data = {}
    data["id"] = self.id;
    data["goods"] = self.id;
    data["name"] = self.recharge_name;
    data["body"] = self.unit.." "..self.id.." x1";
    data["money"] = self.recharge;
    data["price"] = self.recharge/100;
    data["type"] = self.recharge_type;
    data["autobuy"] = 1;
    data["subject"] = self.unit;
    data["ingame"] = 1;
    data["roomid"] = 0;
    data["count"] = 1;
    data["debug"] = 0;
    data["udid"] = Helper.GetDeviceCode()
    data["uiObj"] = self;
    FishGI.payHelper:doPay(data);


    FishGI.eventDispatcher:registerCustomListener("BuySuccessCall", self, function(valTab) 
        self:updateItem(true);
    end);
end

return Shopitem;