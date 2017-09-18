
local Bag = class("Bag", cc.load("mvc").ViewBase)

Bag.AUTO_RESOLUTION   = false
Bag.RESOURCE_FILENAME = "ui/hall/bag/uibag"
Bag.RESOURCE_BINDING  = {  
    ["panel"]                = { ["varname"] = "panel" },
    ["btn_close"]            = { ["varname"] = "btn_close" ,         ["events"]={["event"]="click",["method"]="onClickClose"}},   
    
    ["scroll_bag_list"]      = { ["varname"] = "scroll_bag_list" ,         ["nodeType"]="viewlist"   },
    ["node_cueitem_title"]   = { ["varname"] = "node_cueitem_title" }, 
    ["text_title"]           = { ["varname"] = "text_title" },      
    ["node_curitem"]         = { ["varname"] = "node_curitem" },
    
    
    ["node_type_1"]          = { ["varname"] = "node_type_1" },
    ["text_describe"]        = { ["varname"] = "text_describe" }, 
    ["btn_buy"]              = { ["varname"] = "btn_buy" ,         ["events"]={["event"]="click",["method"]="onClickBuy"}},   
    ["btn_sell"]             = { ["varname"] = "btn_sell" ,         ["events"]={["event"]="click",["method"]="onClickSell"}},     
    ["btn_send"]             = { ["varname"] = "btn_send" ,         ["events"]={["event"]="click",["method"]="onClickSend"}},   
    ["btn_resolve"]          = { ["varname"] = "btn_resolve" ,         ["events"]={["event"]="click",["method"]="onClickresolve"}}, 
    ["btn_exchange"]         = { ["varname"] = "btn_exchange" ,         ["events"]={["event"]="click",["method"]="onClickexchange"}}, 
    ["btn_taste"]            = { ["varname"] = "btn_taste" ,         ["events"]={["event"]="click",["method"]="onClicktaste"}}, 
    ["node_timelimit"]       = { ["varname"] = "node_timelimit" },
    ["text_daytime"]         = { ["varname"] = "text_daytime" },
    ["text_sectime"]         = { ["varname"] = "text_sectime" },
    
    ["node_type_2"]          = { ["varname"] = "node_type_2" },
    ["btn_surebuy"]          = { ["varname"] = "btn_surebuy" ,         ["events"]={["event"]="click",["method"]="onClicksurebuy"}},   
    ["btn_buy_minus"]        = { ["varname"] = "btn_buy_minus" ,         ["events"]={["event"]="click",["method"]="onClickbuy_minus"}},   
    ["btn_buy_add"]          = { ["varname"] = "btn_buy_add" ,         ["events"]={["event"]="click",["method"]="onClickbuy_add"}},   
    ["text_buy_count"]       = { ["varname"] = "text_buy_count" },
    ["text_buy_notice"]      = { ["varname"] = "text_buy_notice" },
    ["text_buy_allprice"]    = { ["varname"] = "text_buy_allprice" },
    ["text_buy_price_count"] = { ["varname"] = "text_buy_price_count" },
    
    
    
    ["node_type_3"]          = { ["varname"] = "node_type_3" },
    ["text_word"]            = { ["varname"] = "text_word" }, 
    ["text_word_canget"]     = { ["varname"] = "text_word_canget" }, 
    ["text_cangetcoin"]      = { ["varname"] = "text_cangetcoin" }, 
    ["text_curnum"]          = { ["varname"] = "text_curnum" }, 
    ["text_allnum"]          = { ["varname"] = "text_allnum" }, 
    ["btn_minus"]            = { ["varname"] = "btn_minus" ,         ["events"]={["event"]="click",["method"]="onClickminus"}}, 
    ["btn_add"]              = { ["varname"] = "btn_add" ,         ["events"]={["event"]="click",["method"]="onClickadd"}}, 
    ["btn_max"]              = { ["varname"] = "btn_max" ,         ["events"]={["event"]="click",["method"]="onClickmax"}}, 
    ["btn_suresell"]         = { ["varname"] = "btn_suresell" ,         ["events"]={["event"]="click",["method"]="onClicksuresell"}}, 

}

-- 需要过滤掉的道具
Bag.FilterProp = {
    -- FishCD.PROP_ID_LOTTERY_CARD ,                  -- 抽奖卡
    -- FishCD.PROP_ID_PK_TICKET ,                     -- 参赛券
}

function Bag:onCreate( ... )
    --初始化
    self:init()

    self:initPropData()
    -- 初始化View
    self:initView() 

    -- 更新道具数据
    self:updatePropList()

    -- FishGI.eventDispatcher:registerCustomListener("onUsePropCannon", self, function(valTab) self:onUsePropCannon(valTab) end);
    -- FishGI.eventDispatcher:registerCustomListener("onSellItem", self, function(valTab) self:onSellItem(valTab) end);

end

function Bag:onEnter( )
    print("----Bag:onEnter----")
    FishGI.eventDispatcher:registerCustomListener("onUsePropCannon", self, function(valTab) self:onUsePropCannon(valTab) end);
    FishGI.eventDispatcher:registerCustomListener("onSellItem", self, function(valTab) self:onSellItem(valTab) end);

end

function Bag:init()   
    self.panel:setSwallowTouches(false)
    self._propListView = {}         -- 道具试图列表
    self.PropCount = 0
    self.proplistData = {}

    self.myVIP = 0
    self.buyCount = 1
    self.allCostCount = 0

    self.cell_h_count = 4      -- 格子横向数
    self.cell_v_count = 4      -- 格子纵向数
    local cellCountSize = self.scroll_bag_list:getContentSize()
    -- 计算出每个格子的宽高
    self.cellW = cellCountSize.width / self.cell_h_count
    self.cellH = cellCountSize.height / self.cell_v_count

    --添加触摸监听
    self:openTouchEventListener()
       
    self.scroll_bag_list:setSwallowTouches(false)
    self.scroll_bag_list:setScrollBarEnabled(false)
    self.proplist1 = {}
end

--初始化数据
function Bag:initPropData()
    local data = FishGI.GameTableData:getItemTable()
    -- local data = {}
    -- for i=1,itemAllData.count do
    --     local val = itemAllData[tostring(i)]
    --     table.insert(data,val)
    -- end
    -- --排序的算法
    -- FishGF.sortByKey(data,"id",1)

    self.proplistData = {}
    local allCount = #data
    local count = 0
    for i=1,allCount do
        local val = data[i]
        if tonumber(val.if_show) == 1 then
            count = count +1
            self.proplistData[count] = clone(val)
        end
    end
    self:sortPropListData()
end

--排序
function Bag:sortPropListData()
    local list = self.proplistData
    FishGF.sortByKey(list,"show_order",0)
end

--得到道具列表
function Bag:getPropList()
    return self.proplistData
end

--得到道具列表第一个道具
function Bag:getPropListFirst()
    local firstData = nil
    for i,v in ipairs(self.proplistData) do
        if v.if_show == 1 then
            if (v.default_show ~= 0) or(v.default_show == 0 and v.propCount > 0) then
                firstData = v
                break
            end
        end
    end

    local propId = firstData.propId
    local propItemId = nil
    local propCount = firstData.propCount
    if firstData.seniorData ~= nil then
        propItemId = firstData.seniorData.propItemId
    end
    return propId,propCount,propItemId
end

--得到道具列表
function Bag:getPropDataByPropId(propId,propItemId)
    for i,v in ipairs(self.proplistData) do
        if v.propId == propId then
            if propItemId == nil or (v.seniorData ~= nil and propItemId == v.seniorData.propItemId) then
                return v
            end
        end
    end
end

--初始化视图
function Bag:initView()
    self.text_title:setString("")
    self.text_describe:setString("")
    self.text_buy_notice:setString(FishGF.getChByIndex(800000279))
    local prop = {}
    prop.propId = 0
    prop.propCount = 0
    self.rightProp = self:createPropItem(0,prop)
    self.rightProp:setPosition(self.node_curitem:getPosition())
    self.panel:addChild(self.rightProp)

    self.text_word:setString(FishGF.getChByIndex(800000107))
    self.text_word_canget:setString(FishGF.getChByIndex(800000108))

    self:setShopType(0)
end

function Bag:setPropData( propId,propCount ,seniorData)
    local isAdd = true
    local newData = nil
    local isDelKey = -1
    local canDelCount = 0
    for k,val in ipairs(self.proplistData) do
        if tonumber(val.propId)  == tonumber(propId) then
            if  seniorData ~= nil and  next(seniorData) ~= nil then
                local isDel = seniorData["isDel"]
                if tonumber(propCount) == 0 or (isDel ~= nil and isDel == true)then
                    canDelCount = canDelCount + 1
                    if val.seniorData == nil then
                        val.propCount = 0
                        break
                    end
                    if val.seniorData.propItemId == seniorData.propItemId then
                        isDelKey = k
                    end
                    isAdd = false
                    --break
                else
                    if val.seniorData == nil then
                        val.seniorData = seniorData
                        val.propCount = 1
                        isAdd = false
                        break
                    end
                    if val.seniorData.propItemId == seniorData.propItemId then
                        val.seniorData = seniorData
                        val.propCount = 1
                        isAdd = false
                        break
                    end
                    newData = val
                end
            else
                val.propCount = tonumber(propCount)
            end
        end
    end

    if isAdd then
        --FishGF.print("---------this prop is noExist-------------propId="..propId)
        if newData then
            local valTab = clone(newData)  
            valTab.seniorData = seniorData
            valTab.propCount = 1
            table.insert( self.proplistData, valTab)
            self:sortPropListData()
        end
    end

    if isDelKey >= 0 then
        if canDelCount == 1 then
            self.proplistData[isDelKey].seniorData = nil
            self.proplistData[isDelKey].propCount = 0
        elseif canDelCount > 1 then
            self:delPropData(isDelKey)
        end
    end
    local a = 1
end

function Bag:delPropData( key)
    local result = {}
    for k,val in ipairs(self.proplistData) do
        if k ~= key then
            table.insert( result,val )
        else
            local a = 1
            print("--------------k="..key)
        end
    end
    self.proplistData = result
end

function Bag:getPropData( propId)
    local result = {}
    for k,v in pairs(self.proplistData) do
        if propId == v.propId then
            result = v
            return result
        end
    end
end

function Bag:setMyVIP( myVIP )
    self.myVIP = myVIP
end

function Bag:setMyCrystal( crystal )
    self.crystal = crystal
end

function Bag:GetPropList()

    local propList = self.proplistData
    local tempProp = {}
    self.PropCount = 0
    -- 过滤
    for k , val in ipairs( propList ) do 
        local itemData = val
        local isFilter = false
        if itemData.res == "" then
            itemData = {}
            isFilter = true
            itemData.if_show = 0
            itemData.default_show = 0
        end
        if itemData.if_show == 0 then
            isFilter = true
        end

        for  m , n in pairs( Bag.FilterProp ) do 
            if tonumber(val.propId) == n then
                isFilter = true
            end
        end

        if tonumber(val.propCount) <= 0 and tonumber(itemData.default_show) == 0 then
            isFilter = true
        end

        if not isFilter then
            self.PropCount = self.PropCount + 1
            tempProp[self.PropCount] = val
        end
    end

    --不满一行凑满一行
    if math.mod(self.PropCount,4) ~= 0 then
        local Hcount = math.ceil(self.PropCount/4)*4 - self.PropCount
        for i=1,Hcount do
            self.PropCount = self.PropCount + 1
            local prop = {}
            prop.propId = 0
            prop.propCount = 0
            tempProp[self.PropCount] = prop
        end
    end

    --不足16个的用id=0的空格子填充
    if self.PropCount < 16 then
        for i = self.PropCount +1,16 do
            local prop = {}
            prop.propId = 0
            prop.propCount = 0
            tempProp[i] = prop
        end
        self.PropCount = 16
    end

    return tempProp
end

function Bag:updatePropList()
  --  self:clearPropItem()
    -- 道具列表信息
    local propList = self:GetPropList()

    -- 找到道具对应视图
    for k ,val in ipairs( propList ) do
        local propItem = self._propListView[k]
        if not propItem then
            -- 创建新的
            propItem = self:createPropItem( k, val)
            if propItem ~= nil then
                self.scroll_bag_list:addChild( propItem)
                -- 加入视图列表
                self._propListView[k] = propItem
            end
        else
            -- 有更新数据
            propItem:setItemData(val.propId,val.propCount)
            propItem:setSeniorData(val.seniorData)
        end
        if self.rightProp:getItemId() == 0 or self.rightProp:getItemId() == tonumber(val.propId) then
            self:setRightPropData( self:getPropListFirst())
        end
    end

    if #self._propListView > #propList then
        for i=#propList +1 ,#self._propListView do
            print(i)
            local item = self._propListView[i]
            item:removeFromParent( true )
            self._propListView[i] = nil
        end
    end

    -- 刷新位置
    self:updateAllPropItemPosition()
end

function Bag:createPropItem( keyid , prop)
    if prop == nil then
        return
    end
    local propNode = require("hall/Bag/Bagitem").create()
    local result = propNode:setItemData(tonumber(prop.propId) ,tonumber(prop.propCount))
    if result == false then
        return nil
    end
    propNode:setSeniorData(prop.seniorData)
    return propNode
end

function Bag:clearPropItem()
    for k , v in pairs(self._propListView) do
        if v ~= nil then
            v:removeFromParent( true )
            self._propListView[k] = nil
        end
    end
end

function Bag:updateAllPropItemPosition()
    self.all_h_count = math.floor((self.PropCount-1) /4)+1
    local index = 0 
    self.scroll_bag_list:setInnerContainerSize(cc.size(self.cellW*4, self.all_h_count*self.cellH))
    for k , v in pairs( self._propListView ) do     
        if k < FishCD.BAG_NULL_BOX then
            local x, y = self:getPropAddPosition( index )
            v:setPosition(x, y+ (self.all_h_count - 4)* self.cellH)
            index = index + 1
        end
    end
    for k , v in pairs( self._propListView ) do       
        if k >= FishCD.BAG_NULL_BOX then
            local x, y = self:getPropAddPosition( index )
            v:setPosition(x, y+ (self.all_h_count - 4)* self.cellH)
            index = index + 1
        end
    end
end

function Bag:getPropAddPosition( index )

    local propItemCount = index
    -- 总格子数
    local allCellCount = self.cell_h_count * self.cell_v_count

    -- 反向格子起始索引
    local startIndex = allCellCount - propItemCount

    -- 计算道具应放的行列
    local tempX =  math.floor(propItemCount % self.cell_h_count) 
    local tempY =  math.floor( (startIndex - 1 )/ self.cell_h_count )
    local topY =  math.floor(self.PropCount/4) 
    -- 计算x
    local x = 0
    x = self.cellW / 2 + tempX * self.cellW

    -- 计算y
    local y = 0
    y = (tempY + 1 ) * self.cellH - self.cellH / 2

    return x , y
end

function Bag:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false  
    end

    local curPos = touch:getLocation()  
    for k,child in pairs(self._propListView) do
        local s = child.panel:getContentSize()
        local locationInNode = child.panel:convertToNodeSpace(curPos)
        local rect = cc.rect(0,0,s.width,s.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            local id = child:getItemId()
            local count = child:getItemCount()
            local seniorData = child:getSeniorData()
            local propItemId = nil
            if seniorData ~= nil then
                propItemId = seniorData.propItemId
            end
            self:setRightPropData( id,count ,propItemId)
            if id >0 and id < FishCD.BAG_NULL_BOX then
                FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
            end
            return true
        end
    end

    return true
end

function Bag:onTouchMoved(touch, event)
end

function Bag:onTouchEnded(touch, event) 
end

--得到显示的道具数量
function Bag:getShowCount(curid) 
    local count  = 0
    for k,child in pairs(self._propListView) do
        local id = child:getItemId()
        if curid == id then
            count = child:getItemCount()
            break
        end
    end
    return count
end

function Bag:setRightPropData( id,count,propItemId)
    if id >= FishCD.BAG_NULL_BOX or id <= 0 then
        return
    end

    if count == nil then
        count = self:getShowCount(id)
    end
    self.buyCount = 1

    --修改右边物品
    local itemData = self:getPropDataByPropId(id,propItemId)
    if itemData == nil then
        return 
    end
    self.itemData = itemData
    self:setLeftCellChoose(id,propItemId)

    self.text_title:setString(self.itemData.name)
    local result = self.rightProp:setItemData(id,count)
    self.rightProp:setSeniorData(self.itemData.seniorData)

    self.text_describe:setString(self.itemData.pack_text)
    
    self.curCount = 1
    self.allCount = self.rightProp:getItemCount()
    self.text_curnum:setString(self.curCount)
    self.text_allnum:setString("/"..self.rightProp:getItemCount())
    local cell = FishGF.getPropUnitByID(self.itemData.sellPriceId)
    self.text_cangetcoin:setString((self.curCount*self.itemData.sellPrice)..cell)

    local isUsing = false
    if self.itemData.seniorData ~= nil then
        isUsing = FishGF.isSeniorUsing( self.itemData.seniorData )
        if self.itemData.propId == 1002 or self.itemData.propId == 1003 then
            local stringProp = self.itemData.seniorData.stringProp
            local resultTab = FishGF.spiltTime( stringProp )
            self.text_daytime:setString(resultTab["dayStr"])
            self.text_sectime:setString(resultTab["secStr"])
        end
    end

    self.node1BtnArr = {}
    local count = 0
    if self.itemData.sellPriceId == 0 then
        self.btn_sell:setVisible(false)
    else
        self.btn_sell:setVisible(true)
        count = count+1
        self.node1BtnArr[count] = self.btn_sell
    end

    if tonumber(self.itemData.allow_send) == 1 then
        self.btn_send:setVisible(true)
        count = count+1
        self.node1BtnArr[count] = self.btn_send
    else
        self.btn_send:setVisible(false)
    end

    if tonumber(self.itemData.can_buy) == 1 then
        self.btn_buy:setVisible(true)
        count = count+1
        self.node1BtnArr[count] = self.btn_buy
    else
        self.btn_buy:setVisible(false)
    end

    if tonumber(self.itemData.decomposable) == 1 then
        self.btn_resolve:setVisible(true)
        count = count+1
        self.node1BtnArr[count] = self.btn_resolve
    else
        self.btn_resolve:setVisible(false)
    end

    if tonumber(self.itemData.allow_exchange) == 1 then
        self.btn_exchange:setVisible(true)
        count = count+1
        self.node1BtnArr[count] = self.btn_exchange
    else
        self.btn_exchange:setVisible(false)
    end


    if tonumber(self.itemData.if_taste) == 1 then
        self.btn_taste:setVisible(true)
        count = count+1
        self.node1BtnArr[count] = self.btn_taste
    else
        self.btn_taste:setVisible(false)
    end

    self.node1BtnArr["count"] = count

    if isUsing ~= nil and isUsing == true then
        self:setShopType(4)
        return 
    end
    self:setShopType(1)
end

function Bag:setLeftCellChoose( propId,propItemId)
    local key = nil
    for k,child in pairs(self._propListView) do
        local id = child:getItemId()
        local count = child:getItemCount()
        local seniorData = child:getSeniorData()
        if propId == id then
            if propItemId == nil then
                key = k
            end
            if seniorData ~= nil and propItemId == seniorData.propItemId then
                key = k
            end
        end
    end    

    for k,child in pairs(self._propListView) do
        if key == k then
            child:setChooseState(true)
        else
            child:setChooseState(false)
        end
        
    end  

end

function Bag:upDataRightPropData( upDataType)
    if upDataType == "buy" then
        local itemData = self.itemData
        local buyCount = itemData.num_perbuy*self.buyCount
        self.text_buy_count:setString(buyCount)
        local allPrice = buyCount*itemData.priceCount
        local unit = FishGF.getPropUnitByID(itemData.priceId)
        local allPriceStr = FishGF.getChByIndex(800000280)..FishGF.getChByIndex(800000218)..allPrice..unit
        self.text_buy_allprice:setString(allPriceStr)
        local price_count = FishGF.getChByIndex(800000281).."/"..FishGF.getChByIndex(800000282)..FishGF.getChByIndex(800000218)..itemData.priceCount..unit.."/"..itemData.num_perbuy
        self.text_buy_price_count:setString(price_count)

    else



    end

end

function Bag:onClickClose( sender )
    self:hideLayer() 
end

function Bag:onClickBuy( sender )
    self:setShopType(2)
end

function Bag:onClickSell( sender )
    self:setShopType(3)
end

function Bag:onClickSend( sender )
    print("-------------onClickSend")
end

-- 确定分解
function Bag:onClickresolve( sender )
    print("-------------onClickresolve")
    --发送分解消息
    if self.rightProp:getItemCount() < 10 then
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000206),nil)
        return
    end
    self.resolvePropId = self.itemData.id-200000000
    FishGMF.isSurePropData(FishGI.myData.playerId,propId,10,false)
    FishGI.hallScene.net.roommanager:sendDecomposeReq(self.resolvePropId)
end

function Bag:onClickexchange( sender )
    print("-------------onClickexchange")
    local propId = self.itemData.propId
    if propId == 12 then
        local result = FishGI.hallScene.uiExchange:isCanExChange()
        if result then
            --弹出兑换面板
            FishGI.hallScene.uiExchange:showLayer() 
        end
    elseif propId == 18 then
        FishGF.openPortraitWebView(FishGI.Dapi:GetMallUrl(), "元宝商城")
    end
end

function Bag:onClicksurebuy( sender )
    print("-------------onClicksurebuy")
    local require_vip = tonumber(self.itemData.require_vip)
    if FishGI.myData.vip_level < require_vip then
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then
                print("---DialVIP--goto congzhi-")
                self:hideLayer(false) 
                FishGI.hallScene.uiShopLayer:showLayer() 
                FishGI.hallScene.uiShopLayer:setShopType(1)
            end
        end
        local str = FishGF.getChByIndex(800000111)..require_vip..FishGF.getChByIndex(800000112)
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,str,callback)
        return
    end

    local isCanBuy,allCostCount = self:isCanBuy()
    if not isCanBuy then
        local propId = tonumber(self.itemData.priceId)
        local str = ""
        if propId == FishCD.PROP_TAG_01 then
            str = FishGF.getChByIndex(800000129)
        elseif propId == FishCD.PROP_TAG_02 then
            str = FishGF.getChByIndex(800000093)
        end

        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then
                self:hideLayer(false) 
                FishGI.hallScene.uiShopLayer:showLayer() 
                FishGI.hallScene.uiShopLayer:setShopType(propId)
            end
        end
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,str,callback)
        return
    end

    self.allCostCount = allCostCount

    --发送购买消息
    local propId = self.itemData.id - 200000000
    FishGI.hallScene.net.roommanager:sendBuy(propId,self.buyCount);

end

--是否能购买
function Bag:isCanBuy(  )
    local propId = tonumber(self.itemData.priceId)
    local propCount = self.itemData.num_perbuy*self.itemData.priceCount*self.buyCount

    local myCount = 0
    if propId == FishCD.PROP_TAG_01 then
        myCount = FishGI.myData.fishIcon
    elseif propId == FishCD.PROP_TAG_02 then
        myCount = FishGI.myData.crystal
    end

    if propCount >myCount then
        return false
    end
    return true,propCount

end

--购买中的加回调
function Bag:onClickbuy_add( sender )
    self.buyCount = self.buyCount + 1
    local isCanBuy = self:isCanBuy()
    if not isCanBuy then
        self.buyCount = self.buyCount - 1
        return
    end
    
    self:upDataRightPropData("buy")
end
--购买中的减回调
function Bag:onClickbuy_minus( sender )
    if self.buyCount <=1 then
        return
    end
    self.buyCount = self.buyCount - 1
    self:upDataRightPropData("buy")
end

function Bag:onClickminus( sender )
    if self.curCount <=1 then
        return
    end
    self.curCount = self.curCount - 1
    self.text_curnum:setString(self.curCount)
    self.text_allnum:setString("/"..self.rightProp:getItemCount())
    self.text_cangetcoin:setString((self.curCount*self.itemData.sell_value)..FishGF.getChByIndex(800000098))

end

function Bag:onClickadd( sender )
    if self.curCount >= self.rightProp:getItemCount()then
        return
    end
    self.curCount = self.curCount + 1
    self.text_curnum:setString(self.curCount)
    self.text_allnum:setString("/"..self.rightProp:getItemCount())
    self.text_cangetcoin:setString((self.curCount*self.itemData.sell_value)..FishGF.getChByIndex(800000098))

end

function Bag:onClickmax( sender )
    if self.curCount == self.rightProp:getItemCount() then
        return
    end
    self.curCount = self.rightProp:getItemCount()
    self.text_curnum:setString(self.curCount)
    self.text_allnum:setString("/"..self.rightProp:getItemCount())
    self.text_cangetcoin:setString((self.curCount*self.itemData.sell_value)..FishGF.getChByIndex(800000098))
end

function Bag:onClicksuresell( sender )
    print("-------------onClicksuresell")
    local propId = self.itemData.propId
    local count = self.curCount
    local propItemId = 0
    if self.itemData.seniorData ~= nil then
        propItemId = self.itemData.seniorData.propItemId
    end
    if FishGI.hallScene.net.roommanager ~= nil then
        FishGI.hallScene.net.roommanager:sendSellItem(propId,propItemId,count)
    end

end

--体验
function Bag:onClicktaste( sender )
    print("-------------onClicktaste")
    local propId = self.itemData.propId
    if FishGI.hallScene.net.roommanager ~= nil then
        FishGI.hallScene.net.roommanager:sendUsePropCannon(0,propId)
    end
end

function Bag:setShopType( itemType )
    self.node_type_1:setVisible(false)
    self.node_type_2:setVisible(false)
    self.node_type_3:setVisible(false)
    self.node_timelimit:setVisible(false)

    if itemType == 1 then
        self.node_type_1:setVisible(true)
        local count = self.node1BtnArr["count"]
        local posType = math.mod(count,2)
        for i=1,count do
            if posType == 1 then
                self.node1BtnArr[i]:setPositionX((math.mod((i - 1),2)*2 -1)*math.ceil((i-1)/2)*154 )
            elseif posType == 0 then
                self.node1BtnArr[i]:setPositionX((math.mod((i - 1),2)*2 -1)*math.ceil((i-1)/2)*154 - 154/2 )
            end
        end

    elseif itemType == 2 then   --购买
        self.node_type_2:setVisible(true)
        self:upDataRightPropData("buy")
    elseif itemType == 3 then --出售
        self.node_type_3:setVisible(true)
    elseif itemType == 4 then --使用中
        self.node_type_1:setVisible(true)
        for k,v in pairs(self.node_type_1:getChildren()) do
            v:setVisible(false)
        end
        self.text_describe:setVisible(true)
        self.node_timelimit:setVisible(true)
        
    end
end

function Bag:receiveBuyData( netData )
    local isSuccess = netData.isSuccess
    if isSuccess then
        local propId = netData.propId
        local propCount = netData.propCount
        --更新水晶或鱼币
        local propData = FishGI.GameTableData:getItemTable(propId)
        local costPropId = propData.priceId
        local count = self.buyCount*propData.num_perbuy
        local costPropCount = -propData.priceCount*count
        FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,costPropId,costPropCount,true)

        --道具数据
        FishGMF.upDataByPropId(FishGI.myData.playerId,propId,propCount)

        FishGF.showSystemTip(nil,800000154,1);

        --更新道具
        self:setRightPropData(propId,propCount)

    else
        print("-----receiveBuyData-fail------")
    end
    self.allCostCount = 0
end

--分解
function Bag:onDecomposeResult( netData )
    local isSuccess = netData.isSuccess
    local newCrystalPower = netData.newCrystalPower
    
    local realCount = FishGMF.getPlayerPropData(FishGI.myData.playerId,11).realCount

    FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,self.resolvePropId,-10,false)
    FishGMF.isSurePropData(FishGI.myData.playerId,self.resolvePropId,10,true)
    
    FishGMF.upDataByPropId(FishGI.myData.playerId,11,newCrystalPower,true)
    if isSuccess then
        local count = FishGMF.getPlayerPropData(FishGI.myData.playerId,self.resolvePropId).realCount
        if count <= 0 then
            self:setRightPropData(self:getPropListFirst())
        else
            self:setRightPropData(self.resolvePropId)
        end
        
        local str = string.format(FishGF.getChByIndex(800000207), tostring(newCrystalPower-realCount))
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,str,nil)
    end
end

--使用限时炮台
function Bag:onUsePropCannon( netData )
    local isSuccess = netData.isSuccess
    local newCrystal = netData.newCrystal
    local useType = netData.useType
    local playerId = netData.playerID
    local propInfo = netData.propInfo

    if not isSuccess then
        print("---------used faile----------")
        FishGF.showSystemTip(FishGF.getChByIndex(800000321),nil,1);
        return 
    end

    FishGF.showSystemTip(FishGF.getChByIndex(800000320),nil,1);

    FishGMF.upDataByPropId(playerId,FishCD.PROP_TAG_02,newCrystal,true)

    FishGMF.refreshSeniorPropData(playerId,propInfo,1,0)

end

--出售
function Bag:onSellItem( netData )
    local errorCode = netData.errorCode                 --错误码 0:成功，1:道具数量不足, 2:道具不存在，3:道具不可出售
    local dropPropId = netData.dropPropId               --获得的道具id
    local dropPropCount = netData.dropPropCount         --获得的道具个数
    local dropPropNewValue = netData.dropPropNewValue   --新的道具总个数

	local propId = netData.propId                       --道具id
	local propItemId = netData.propItemId               --用于高级道具
	local count = netData.count                         --出售个数
    local playerId = FishGI.myData.playerId

    if errorCode ~= 0 then
        local str = ""
        if errorCode == 1 then
            str = FishGF.getChByIndex(800000317)
        elseif errorCode == 2 then
            str = FishGF.getChByIndex(800000318)
        elseif errorCode == 3 then
            str = FishGF.getChByIndex(800000319)
        end
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,str,nil)           
        return 
    else
        --恭喜获得---
        local str = FishGF.getChByIndex(800000005)..dropPropCount..FishGF.getPropUnitByID(dropPropId,true)
        FishGF.showSystemTip(str,nil,1);
    end

    --扣掉道具
    if propItemId <= 0  then    --普通道具
        FishGMF.addTrueAndFlyProp(playerId,propId,-count,true)
    else                        --高级道具
        local propData = {}
        propData.propId = propId
        propData.propItemId = propItemId
        FishGMF.refreshSeniorPropData(playerId,propData,3)
    end

    --获得道具
    FishGMF.addTrueAndFlyProp(playerId,dropPropId,dropPropCount,true)

    self:setRightPropData(self:getPropListFirst())

end

function Bag:showLayer()
    Bag.super.showLayer(self)
    self:setRightPropData(self:getPropListFirst())
    --FishGF.setViewListIsShow(self.scroll_bag_list,true,0,0)
end

function Bag:hideLayer()
    Bag.super.hideLayer(self)
    --FishGF.setViewListIsShow(self.scroll_bag_list,false,3.15,0)
end

return Bag;