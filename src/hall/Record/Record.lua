
local Record = class("Record", cc.load("mvc").ViewBase)

Record.AUTO_RESOLUTION   = false
Record.RESOURCE_FILENAME = "ui/hall/record/uirecord"
Record.RESOURCE_BINDING  = {  
    ["panel"]              = { ["varname"] = "panel" },
    
    ["btn_close"]          = { ["varname"] = "btn_close" ,         ["events"]={["event"]="click",["method"]="onClickclose"}},   
    ["scroll_list"]        = { ["varname"] = "scroll_list",        ["nodeType"]="viewlist"   },
    
    ["img_down"]           = { ["varname"] = "img_down" }, 
    ["img_top"]            = { ["varname"] = "img_top" }, 
    
    ["text_notice"]        = { ["varname"] = "text_notice" }, 
    
    
    ["spr_words_norecord"] = { ["varname"] = "spr_words_norecord" }, 

}

function Record:onCreate( ... )
    --初始化
    self:init()

end

function Record:init()   
    
    self.panel:setSwallowTouches(false)
    self.scroll_list:setScrollBarEnabled(false)

    self.text_notice:setString(FishGF.getChByIndex(800000239))
    self:child("text_word_time"):setString(FishGF.getChByIndex(800000240))
    self:child("text_word_no"):setString(FishGF.getChByIndex(800000241))
    self:child("text_word_name"):setString(FishGF.getChByIndex(800000242))

    self.RecordListView = {}
    self:initView()

    self:openTouchEventListener()
    
end

function Record:initView()

    local cellCountSize = self.scroll_list:getContentSize()
    -- 计算出每个格子的宽高
    self.cellW = cellCountSize.width
    local RecordItem = self:createRecordItem(nil)
    self.cellH = RecordItem.img_bg:getContentSize().height+10
    self.topDis = 10

    local function scrollviewEvent(sender,eventType)
        if eventType==ccui.ScrollviewEventType.scrollToBottom then
           --print("滚动到底部噢")
           self.img_top:setVisible(true)
           self.img_down:setVisible(false)
        elseif eventType==ccui.ScrollviewEventType.scrollToTop then
            --print("滚动到顶部噢")
            self.img_top:setVisible(false)
            self.img_down:setVisible(true)
        elseif eventType== ccui.ScrollviewEventType.scrolling then
            --print("滚动中噢")
            self.img_top:setVisible(true)
            self.img_down:setVisible(true)
        end
    end
    self.scroll_list:addEventListener(scrollviewEvent)

end

function Record:onTouchBegan(touch, event)
    if self:isVisible() then
         return true  
    end

    return false
end

function Record:onClickclose( sender )
    self:hideLayer() 
    FishGI.hallScene.uiRecordBody:hideLayer()
end

function Record:setUnreadRecordData( data )
    print("-------setUnreadRecordData------")
    self.recordsList = data.items
    --self:upDataRecordList()
end

function Record:loadRecord(  )
    print("-------loadUnreadRecord------")
    local RecordList = self:getUnreadRecordData()
    if #RecordList <= 0  then
        self.spr_words_norecord:setVisible(true)
    else
        self.spr_words_norecord:setVisible(false)
    end

    local index = 1
    local function loadRecordscheduler()
        local val  = RecordList[index]
        if val == nil then
            if index >= #RecordList then
                self:closeAllSchedule()
                self:upDataRecordList()
                return
            end
            index = index + 1
            return
        end
        local friendGameId = val.friendGameId
        local RecordItem,key = self:getRecordByid( friendGameId )
        if not RecordItem then
            --print("--loadUnreadRecord--createRecordItem------")
            -- 创建新的
            RecordItem = self:createRecordItem(val)
            self.scroll_list:addChild( RecordItem)
            -- 加入视图列表
            table.insert(self.RecordListView,RecordItem)
        else
            -- 有更新数据
            RecordItem:setItemData(val)
        end   

        if index >= #RecordList then
            self:closeAllSchedule()
            self:upDataRecordList()
            return
        end
        index = index +1
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadRecordscheduler, 0.01, false);

end

function Record:removeRecord( id )
    print("-------removeRecord------")
    local leaveCount = 0
    local temTab = {}
    for k,val in pairs(self.recordsList) do
        if val.friendGameId ~= id then
            table.insert(temTab,val)
            leaveCount = leaveCount + 1
        end
    end

    self.recordsList = temTab
    self:upDataRecordList()

    return leaveCount
end

--得到列表
function Record:getUnreadRecordData(  )
    local RecordList = self.recordsList
    local tempRecord = {}
    self.RecordCount = 0
    for i,val in ipairs(RecordList) do
        if val ~= nil then
            self.RecordCount = self.RecordCount + 1
            tempRecord[self.RecordCount] = val
        end
    end

    return tempRecord
end

--得到列表
function Record:getRecordByid( friendGameId )
    local Recorditem = nil
    local key = nil
    for k,val in pairs(self.RecordListView) do
        local Recordid = val:getItemData().friendGameId
        if friendGameId == Recordid then
            Recorditem = val
            key = k
            break
        end
    end

    return Recorditem,key
end

function Record:createRecordItem(val)
    local RecordItem = require("hall/Record/RecordItem").create()
    RecordItem:setItemData(val)
    return RecordItem
end

--更新列表
function Record:upDataRecordList(  )
    
    local RecordList = self:getUnreadRecordData()
    if #RecordList <= 0  then
        self.spr_words_norecord:setVisible(true)
    else
        self.spr_words_norecord:setVisible(false)
    end

    local newViewList = {}
    -- 找到对应视图
    for k ,val in ipairs( RecordList ) do
        local id = val.id
        local RecordItem,key = self:getRecordByid( id )
        if not RecordItem then
            -- 创建新的
            RecordItem = self:createRecordItem(val)
            self.scroll_list:addChild( RecordItem)
            -- 加入视图列表
            newViewList[k] = RecordItem

        else
            -- 有更新数据
            RecordItem:setItemData(val)
            newViewList[k] = RecordItem
            self.RecordListView[key] = nil
        end
    end

    --清除不需要的邮件 
    local tab = self.RecordListView
    for k,val in pairs(self.RecordListView) do
        if val ~= nil then
            val:removeFromParent()
        end
    end

    self.RecordListView = newViewList

    self:upDataRecordPos()

end

--更新位置
function Record:upDataRecordPos(  )
    local sizwHeight = self.RecordCount*self.cellH + self.topDis*2
    self.scroll_list:setInnerContainerSize(cc.size(self.cellW, sizwHeight))
    local size = self.scroll_list:getContentSize()
    local topPos = 0
    if #self.RecordListView >=4 then
        topPos = sizwHeight - self.topDis - self.cellH/2
    else
        topPos = size.height - self.topDis - self.cellH/2
    end

    for i=1,#self.RecordListView do
        local item = self.RecordListView[i]
        item:setPositionX(self.cellW/2)
        item:setPositionY(topPos - (i - 1)*self.cellH)
    end

end

function Record:closeAllSchedule()
    if self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID )
        self.schedulerID = nil
    end
end

return Record;