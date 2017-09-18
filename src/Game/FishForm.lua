local FishForm = class("FishForm", cc.load("mvc").ViewBase)

FishForm.isOpen            = false
FishForm.AUTO_RESOLUTION   = false
FishForm.RESOURCE_FILENAME = "ui/battle/fishform/uifishform"
FishForm.RESOURCE_BINDING  = {    
    ["panel"]            = { ["varname"] = "panel" },
    ["btn_close"]        = { ["varname"] = "btn_close"  ,      ["events"]={["event"]="click",["method"]="onClickExit"}},
    ["scroll_fish_list"] = { ["varname"] = "scroll_fish_list" ,         ["nodeType"]="viewlist"   },
    ["image_top"]        = { ["varname"] = "image_top" },
    ["image_down"]       = { ["varname"] = "image_down" },
}

function FishForm:onCreate( ... )
    self:openTouchEventListener()
    
    self.isFromLottery = false
    self:initData()

    self.scroll_fish_list:setScrollBarEnabled(false)
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
    self.scroll_fish_list:addEventListener(scrollviewEvent)

end

function FishForm:onTouchBegan(touch, event) 
    if self:isVisible() == true then
        return true
    end   
    return false
end

function FishForm:onTouchCancelled(touch, event)
    if self:isVisible() == true then
        return true
    end   
    return false    
end

function FishForm:onClickExit( sender )
    print("onClickExit")
    if self.isFromLottery == nil then
        self:hideLayer()
    elseif self.isFromLottery == "LotteryLayer" then
        self:hideLayer(false)
        self:getParent().uiLotteryLayer:showLayer()
    end
    
end

function FishForm:initData( )
    self.scrollSize = self.scroll_fish_list:getContentSize()
    
    self.normal_v_count = 8
    self.special_v_count = 4

    -- 计算出每个格子的宽高
    self.cellW1 = self.scrollSize.width / self.normal_v_count
    self.cellW2 = self.scrollSize.width / self.special_v_count
    self.cellH = 100

end

function FishForm:initFishForm( curroomID )
    print("initFishForm")
    local RoomFishArr = FishGI.GameTableData:getRoomfishTable(curroomID)
    local count = #RoomFishArr

    self.fishList = {}
    self.specialFishList = {}
    
    for i=1,count do
        local RoomFish = RoomFishArr[i]
        if RoomFish == nil or RoomFish == "" then
            break
        end
        local item = self:createFishItem(RoomFish)
        self.scroll_fish_list:addChild(item)
        if RoomFish.fish_type ~= 6 then
            table.insert( self.fishList, item)
        else
            table.insert( self.specialFishList, item)
        end
    end
    self:updataScrollView(self.scroll_fish_list,self.fishList,self.specialFishList)
end

function FishForm:updataScrollView(listView,fishList,specialFishList)
    local count1 = #fishList
    local h_count1 = math.floor((count1-1) /self.normal_v_count)+1

    local count2 = #specialFishList
    local h_count2 = math.floor((count2-1) /self.special_v_count)+1

    local all_h_size = (h_count1 + h_count2)*self.cellH
    listView:setInnerContainerSize(cc.size(self.scrollSize.width, all_h_size))

    for i=1,count1 do
        local fishItem = fishList[i]
        local posX = self.cellW1/2 + math.mod(i-1,self.normal_v_count) * self.cellW1
        local posY = all_h_size - self.cellH/2 - math.floor((i-1)/self.normal_v_count) *self.cellH
        fishItem:setPosition(cc.p(posX, posY))
    end

    for i=1,count2 do
        local fishItem = specialFishList[i]
        local posX = self.cellW2/2 + math.mod(i-1,self.special_v_count) * self.cellW2
        local posY = all_h_size - h_count1*self.cellH -self.cellH/2 - math.floor((i-1)/self.special_v_count) *self.cellH
        fishItem:setPosition(cc.p(posX, posY))
    end

end

function FishForm:createFishItem( valtab )
    local fishID = valtab.fish_id - 100000000
    local show_score = valtab.show_score
    local fish_type = valtab.fish_type
    local item = require("ui/battle/fishform/uiformitem").create().root
    item.nodeType = "cocosStudio"
    local fishSpr = item:getChildByName("panel"):getChildByName("spr_fish")
    fishSpr:initWithFile("battle/form/pic_fishid/fishid_"..fishID..".png")

    local rate = item:getChildByName("panel"):getChildByName("fnt_rate")
    rate:setString(show_score)
    if tonumber(show_score) <= 0 then
        rate:setVisible(false)
    else
        rate:setVisible(true)
    end

    local filename = nil
    if fish_type == 1 then
        filename = "battle/form/form_box_1.png"
    elseif fish_type == 2 then
        filename = "battle/form/form_box_1.png"
    elseif fish_type == 3 then
        filename = "battle/form/form_box_2.png"
    elseif fish_type == 4 then
        filename = "battle/form/form_box_1.png"
    elseif fish_type == 5 then
        filename = "battle/form/form_box_3.png"
    elseif fish_type == 6 then
        filename = "battle/form/form_box_1.png"

    end
    local bg = item:getChildByName("panel"):getChildByName("image_formbg")
    bg:loadTexture(filename,0)
    if fish_type == 6 then
        local size = bg:getContentSize()
        bg:setContentSize(cc.size(size.width + 134,size.height))
        rate:setVisible(false)
    end

    item["fish_type"] = fish_type
    return item
end




return FishForm;