
local Mail = class("Mail", cc.load("mvc").ViewBase)

Mail.AUTO_RESOLUTION   = false
Mail.RESOURCE_FILENAME = "ui/hall/mail/uimail"
Mail.RESOURCE_BINDING  = {  
    ["panel"]            = { ["varname"] = "panel" },
    ["btn_close"]        = { ["varname"] = "btn_close" ,         ["events"]={["event"]="click",["method"]="onClickclose"}},   
    ["scroll_list"]      = { ["varname"] = "scroll_list" ,       ["nodeType"]="viewlist"   },
    
    ["img_down"]         = { ["varname"] = "img_down" }, 
    ["img_top"]          = { ["varname"] = "img_top" }, 
    
    ["text_notice"]      = { ["varname"] = "text_notice" }, 
    
    
    ["spr_words_nomail"] = { ["varname"] = "spr_words_nomail" }, 

}

function Mail:onCreate( ... )
    --初始化
    self:init()

end

function Mail:init()   
    
    self.panel:setSwallowTouches(false)
    self.scroll_list:setScrollBarEnabled(false)

    self.text_notice:setString(FishGF.getChByIndex(800000197))
    
    self.mailListView = {}
    self:initView()

    self:openTouchEventListener()
    
end

function Mail:initView()

    local cellCountSize = self.scroll_list:getContentSize()
    -- 计算出每个格子的宽高
    self.cellW = cellCountSize.width
    local mailItem = self:createMailItem(nil)
    self.cellH = mailItem.img_bg:getContentSize().height+10
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

function Mail:onTouchBegan(touch, event)
    if self:isVisible() then
         return true  
    end

    return false
end

function Mail:onClickclose( sender )
    self:hideLayer() 
end

function Mail:setUnreadMailData( data )
    print("-------setUnreadMailData------")
    self.unreadMails = data.unreadMails
    --self:upDataMailList()
end

function Mail:loadUnreadMail(  )
    print("-------loadUnreadMail------")
    local mailList = self:getUnreadMailData()
    if #mailList <= 0  then
        self.spr_words_nomail:setVisible(true)
    else
        self.spr_words_nomail:setVisible(false)
    end

    local index = 1
    local function loadUnreadMailscheduler()
        local val  = mailList[index]
        if val == nil then
            if index >= #mailList then
                self:closeAllSchedule()
                self:upDataMailList()
                return
            end
            index = index + 1
            return
        end
        local id = val.id
        local mailItem,key = self:getMailByid( id )
        if not mailItem then
            --print("--loadUnreadMail--createMailItem------")
            -- 创建新的
            mailItem = self:createMailItem(val)
            self.scroll_list:addChild( mailItem)
            -- 加入视图列表
            table.insert(self.mailListView,mailItem)
        else
            -- 有更新数据
            mailItem:setItemData(val)
        end   

        if index >= #mailList then
            self:closeAllSchedule()
            self:upDataMailList()
            return
        end
        index = index +1
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadUnreadMailscheduler, 0.01, false);

end

function Mail:removeMail( id )
    print("-------removeMail------")
    local leaveCount = 0
    local temTab = {}
    for k,val in pairs(self.unreadMails) do
        if val.id ~= id then
            table.insert(temTab,val)
            leaveCount = leaveCount + 1
        end
    end

    self.unreadMails = temTab
    self:upDataMailList()

    return leaveCount
end

--得到邮件列表
function Mail:getUnreadMailData(  )
    local mailList = self.unreadMails
    --排序的算法
    FishGF.sortByKey(mailList,"id",0)

    local tempMail = {}
    self.mailCount = 0
    for i,val in ipairs(mailList) do
        if val ~= nil then
            self.mailCount = self.mailCount + 1
            tempMail[self.mailCount] = val
        end
    end

    return tempMail
end

--得到邮件列表
function Mail:getMailByid( id )
    local mailitem = nil
    local key = nil
    for k,val in pairs(self.mailListView) do
        local mailid = val:getItemData().id
        if id == mailid then
            mailitem = val
            key = k
            break
        end
    end

    return mailitem,key
end

function Mail:createMailItem(val)
    local mailItem = require("hall/Mail/MailItem").create()
    mailItem:setItemData(val)
    return mailItem
end

--更新邮件列表
function Mail:upDataMailList(  )
    
    local mailList = self:getUnreadMailData()
    if #mailList <= 0  then
        self.spr_words_nomail:setVisible(true)
    else
        self.spr_words_nomail:setVisible(false)
    end

    local newViewList = {}
    -- 找到对应视图
    for k ,val in ipairs( mailList ) do
        local id = val.id
        local mailItem,key = self:getMailByid( id )
        if not mailItem then
            -- 创建新的
            mailItem = self:createMailItem(val)
            self.scroll_list:addChild( mailItem)
            -- 加入视图列表
            newViewList[k] = mailItem

        else
            -- 有更新数据
            mailItem:setItemData(val)
            newViewList[k] = mailItem
            self.mailListView[key] = nil
        end
    end

    --清除不需要的邮件 
    local tab = self.mailListView
    for k,val in pairs(self.mailListView) do
        if val ~= nil then
            val:removeFromParent()
        end
    end

    self.mailListView = newViewList

    self:upDataMailPos()

end

--更新邮件位置
function Mail:upDataMailPos(  )
    local sizwHeight = self.mailCount*self.cellH + self.topDis*2
    self.scroll_list:setInnerContainerSize(cc.size(self.cellW, sizwHeight))
    local size = self.scroll_list:getContentSize()
    local topPos = 0
    if #self.mailListView >=3 then
        topPos = sizwHeight - self.topDis - self.cellH/2
    else
        topPos = size.height - self.topDis - self.cellH/2
    end

    for i=1,#self.mailListView do
        local item = self.mailListView[i]
        item:setPositionX(self.cellW/2)
        item:setPositionY(topPos - (i - 1)*self.cellH)
    end
end

function Mail:closeAllSchedule()
    if self.schedulerID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID )
        self.schedulerID = nil
    end
end

return Mail;