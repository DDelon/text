
local Shop = class("Shop", cc.load("mvc").ViewBase)

Shop.AUTO_RESOLUTION   = false
Shop.RESOURCE_FILENAME = "ui/shop/uishop"
Shop.RESOURCE_BINDING  = {  
    ["panel"]                = { ["varname"] = "panel" },
    ["btn_close"]            = { ["varname"] = "btn_close" ,                    ["events"]={["event"]="click",["method"]="onClickClose"}},   
    ["scroll_shop_fishcoin"] = { ["varname"] = "scroll_shop_fishcoin",          ["nodeType"]="viewlist"   },
    ["scroll_shop_crystal"]  = { ["varname"] = "scroll_shop_crystal" ,          ["nodeType"]="viewlist"   },
    
    ["image_barbg"]          = { ["varname"] = "image_barbg" },    
    ["bar_vip"]              = { ["varname"] = "bar_vip" },    
    ["fnt_vipexp"]           = { ["varname"] = "fnt_vipexp" },   
    ["text_word"]            = { ["varname"] = "text_word" },  
    ["btn_lock"]             = { ["varname"] = "btn_lock" ,         ["events"]={["event"]="click",["method"]="onClickLock"}},   
    ["fnt_vip_curnum"]       = { ["varname"] = "fnt_vip_curnum" },  
    ["fnt_vip_aimnum"]       = { ["varname"] = "fnt_vip_aimnum" },  
    
    ["btn_crystal"]          = { ["varname"] = "btn_crystal" ,      ["events"]={["event"]="click",["method"]="onClickCrystal"}},   
    ["btn_fishcoin"]         = { ["varname"] = "btn_fishcoin" ,     ["events"]={["event"]="click",["method"]="onClickFishcoin"}},   
    
    ["node_vipdata"]         = { ["varname"] = "node_vipdata" }, 
    ["spr_maxvip"]           = { ["varname"] = "spr_maxvip" }, 
    
    ["image_top"]            = { ["varname"] = "image_top" }, 
    ["image_down"]           = { ["varname"] = "image_down" }, 
    
    
    ["node_first_tip"]       = { ["varname"] = "node_first_tip" }, 
    ["text_1"]               = { ["varname"] = "text_1" }, 
    ["text_2"]               = { ["varname"] = "text_2" }, 

}

function Shop:onCreate( ... )
    --初始化
    self:init()

    -- 更新道具数据
    self:updatePropList()

end

function Shop:init()   
    
    self.panel:setSwallowTouches(false)
    self.scroll_shop_fishcoin:setScrollBarEnabled(false)
    self.scroll_shop_crystal:setScrollBarEnabled(false)

    self.layerType = "Shop";
    self.isPlaySound = true
    self.sendCrystal = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000028), "data"));
    self.rechargeNum = 0
    self:setMyCostMoney(0)
    self:initView()

    self:openTouchEventListener()
    
end

function Shop:initView()
    self.text_1:setString(FishGF.getChByIndex(800000102))
    self.text_2:setString(FishGF.getChByIndex(800000162)..FishGF.getChByIndex(800000161))

    self.crystalListView = {}
    self.fishcoinListView = {}

    self.cell_h_count = 2      -- 格子横向数
    self.cell_v_count = 3      -- 格子纵向数
    local cellCountSize = self.scroll_shop_crystal:getContentSize()
    -- 计算出每个格子的宽高
    self.cellW = cellCountSize.width / self.cell_h_count
    self.cellH = cellCountSize.height / self.cell_v_count

    self:initFishCoinScroll(FishGI.GameTableData:getRechargeTable(1))
    self:initCrystalScroll(FishGI.GameTableData:getRechargeTable(2))

    local function scrollviewEvent(sender,eventType)
        if eventType==ccui.ScrollviewEventType.scrollToBottom then
           --print("滚动到底部噢")
           self.image_top:setVisible(true)
           self.image_down:setVisible(false)
        elseif eventType==ccui.ScrollviewEventType.scrollToTop then
            --print("滚动到顶部噢")
            self.image_top:setVisible(false)
            self.image_down:setVisible(true)
        elseif eventType== ccui.ScrollviewEventType.scrolling then
            --print("滚动中噢")
            self.image_top:setVisible(true)
            self.image_down:setVisible(true)
        end
    end
    self.scroll_shop_fishcoin:addEventListener(scrollviewEvent)
    self.scroll_shop_crystal:addEventListener(scrollviewEvent)


    --self:onClickCrystal(self)

end

function Shop:initWithTab(tab)
    if tab == nil then
        FishGF.print("---Shop:initWithTab--tab==nil-")
        return
    end
    --鱼币表
    for key, val in pairs(self.fishcoinListView) do
        for key1, val1 in pairs(tab) do
            if key1 == 287 then
                for key2, val2 in pairs(val1) do
                    local recharge = val.recharge;
                    if key2 == recharge then
                        val:updateItem(true);
                    end
                end
            end
        end
    end

    --水晶表
    for key, val in pairs(self.crystalListView) do
        for key1, val1 in pairs(tab) do
            if key1 == 288 then
                for key2, val2 in pairs(val1) do
                    local recharge = val.recharge;
                    if key2 == recharge then
                        val:updateItem(true);
                    end
                end
            end
        end
    end
end

function Shop:updatePropList()

end

function Shop:initFishCoinScroll(valTab)
    local count = #valTab
    for i=1,count do
        local data = valTab[i]
        local shopItem = require("Shop/Shopitem").create()
        data.platformId = 287;
        shopItem:setItemData(data)
        self.scroll_shop_fishcoin:addChild( shopItem)
        self.fishcoinListView[i] = shopItem
    end
    self:updataScrollView(self.scroll_shop_fishcoin,self.fishcoinListView)
end

function Shop:initCrystalScroll(valTab)
    local count = #valTab
    for i=1,count do
        local data = valTab[i]
        local shopItem = require("Shop/Shopitem").create()
        data.platformId = 288;
        shopItem:setItemData(data)
        self.scroll_shop_crystal:addChild( shopItem)
        self.crystalListView[i] = shopItem
    end
    self:updataScrollView(self.scroll_shop_crystal,self.crystalListView)
end

function Shop:updataScrollView(listView,itemList)
    local count = #itemList
    local all_h_count = math.floor((count-1) /2)+1
    listView:setInnerContainerSize(cc.size(self.cellW*2, all_h_count*self.cellH + 8))
    for i=1,count do
        local shopItem = itemList[i]
        shopItem:setPosition(cc.p(self.cellW/2 + math.mod(i+1,2) * self.cellW, all_h_count*self.cellH - self.cellH/2 - math.floor((i-1)/2) *self.cellH))
    end
end

function Shop:removeItemById(listView,itemList,id)
    local isRemove = false
    for k,v in pairs(itemList) do
        if v.id == id then
            isRemove = true
        end
    end
    if not isRemove then
        return
    end
    local count = #itemList
    local newList = {}
    local newCount = 1
    for i=1,count do
        if itemList[i].id ~= id then
            newList[newCount] = itemList[i]
            newCount = newCount +1
        else
            itemList[i]:removeFromParent()
            itemList[i] = nil
        end
    end
    itemList = newList
    self:updataScrollView(listView,itemList)
end

function Shop:removeMonthCard()
    self:removeItemById(self.scroll_shop_crystal,self.crystalListView,830000015)
    self:removeItemById(self.scroll_shop_fishcoin,self.fishcoinListView,830000015)
end

function Shop:onTouchBegan(touch, event)
    if self:isVisible() then
         return true  
    end

    return false
end

function Shop:onClickClose( sender )
    self:hideLayer() 
end

function Shop:onClickLock( sender )
    print("-Shop-onClickLock---")
    self:getParent().uiVipRight:upDataLayerByMyVIPLV()

    self:hideLayer(false) 
    self:getParent().uiVipRight:showLayer() 

end

function Shop:onClickCrystal( sender )  
    self:setShopType(2)
end

function Shop:onClickFishcoin( sender )
    self:setShopType(1)
end

function Shop:setShopType( showType )
    if showType == 1 then
        self.btn_crystal:setEnabled(true)
        self.btn_crystal:setLocalZOrder(24)
        self.btn_fishcoin:setEnabled(false)
        self.btn_fishcoin:setLocalZOrder(25)

        self.scroll_shop_fishcoin:setVisible(true)
        self.scroll_shop_crystal:setVisible(false)

        self.image_top:setVisible(false)
        self.image_down:setVisible(true)
        self.scroll_shop_fishcoin:scrollToTop(0,false)

    elseif showType == 2 then
        self.btn_crystal:setEnabled(false)
        self.btn_crystal:setLocalZOrder(25)
        self.btn_fishcoin:setEnabled(true)
        self.btn_fishcoin:setLocalZOrder(24)

        self.scroll_shop_fishcoin:setVisible(false)
        self.scroll_shop_crystal:setVisible(true)

        self.image_top:setVisible(false)
        self.image_down:setVisible(true)
        self.scroll_shop_crystal:scrollToTop(0,false)
    end
    self:upDataTextWord()
end

function Shop:setMyRechargeNum( rechargeNum )
    self.rechargeNum = rechargeNum

    self:upDataTextWord()
end

function Shop:upDataTextWord( )
    local str = nil
    if (self.costMoney == nil or self.costMoney == 0) and self.scroll_shop_fishcoin:isVisible() then
        str = FishGF.getChByIndex(800000102)..self.sendCrystal..FishGF.getChByIndex(800000099)
        self.node_first_tip:setVisible(true)
    else
        self.node_first_tip:setVisible(false)
        str = FishGF.getChByIndex(800000096)..self.rechargeNum..FishGF.getChByIndex(800000097).."VIP"..(self.vip_level+1)
    end
    self.text_word:setString(str)
end

function Shop:upDataLayer( vipLevelData )
    self.costMoney = vipLevelData.vipExp
    self.vip_level = vipLevelData.vip_level
    self.fnt_vip_curnum:setString(vipLevelData.vip_level)
    self.fnt_vip_aimnum:setString(vipLevelData.vip_level+1)

    local str = (self.costMoney/100).."&"..(vipLevelData.next_All_money/100)
    self.fnt_vipexp:setString(str)

    self.bar_vip:setPercent(self.costMoney/vipLevelData.next_All_money*100)
    self:setMyRechargeNum((vipLevelData.next_All_money - self.costMoney)/100)


    --最高级别
    if vipLevelData.next_All_money == 0 then
        self.node_vipdata:setVisible(false)
        self.spr_maxvip:setVisible(true)
    else
        self.node_vipdata:setVisible(true)
        self.spr_maxvip:setVisible(false)
    end
end

function Shop:setMyCostMoney( money )
    self.costMoney = money

    local vipLevelData = FishGI.GameTableData:getVIPByCostMoney(money)

    self.vip_level = vipLevelData.vip_level
    self.fnt_vip_curnum:setString(vipLevelData.vip_level)
    self.fnt_vip_aimnum:setString(vipLevelData.vip_level+1)

    local str = (money/100).."&"..(vipLevelData.next_All_money/100)
    self.fnt_vipexp:setString(str)

    self.bar_vip:setPercent(money/vipLevelData.next_All_money*100)
    self:setMyRechargeNum((vipLevelData.next_All_money - money)/100)


    --最高级别
    if vipLevelData.next_All_money == 0 then
        self.node_vipdata:setVisible(false)
        self.spr_maxvip:setVisible(true)
    else
        self.node_vipdata:setVisible(true)
        self.spr_maxvip:setVisible(false)        
    end

end

function Shop:showLayer()
    Shop.super.showLayer(self)
    if FishGI.isGetMonthCard then
        self:removeMonthCard()
    end
end

return Shop;