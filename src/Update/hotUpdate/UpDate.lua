local UpDate = class("UpDate", cc.load("mvc").ViewBase)

UpDate.messageIndex = 0
UpDate.preloadData = {}
UpDate.AUTO_RESOLUTION = true
UpDate.RESOURCE_FILENAME = "ui/loading/uiUpDate"
UpDate.RESOURCE_BINDING = {    
    ["bar_update"]         = { ["varname"] = "bar_update" }, 
    
    ["spr_loading_circle"] = { ["varname"] = "spr_loading_circle" },
    ["text_bar_per"]       = { ["varname"] = "text_bar_per" },
    
    ["text_word_1"]        = { ["varname"] = "text_word_1" }, 
    ["text_sizeper"]       = { ["varname"] = "text_sizeper" },   
    ["text_message"]       = { ["varname"] = "text_message" },  

}

function UpDate:onCreate( ... )
    self.messageIndex = 0
    self.text_sizeper:setString("")
    self.text_word_1:setString("资源更新中……")
    self.spr_loading_circle:runAction(cc.RepeatForever:create(cc.RotateBy:create(2,360)))
    self.text_message:setString(math.random(0,9))

    self:openTouchEventListener()
    
    self:setPercent(0)
	self.text_message:setVisible(false)
    --local scheduler = cc.Director:getInstance():getScheduler()  
    --self.noticeSchedulerID = scheduler:scheduleScriptFunc(function(dt)
    --    self.text_message:setString(FishGF.getChByIndex(800000059 + math.random(0,9)))
    --end,2,false) 

    self:isCheckVer(true)

end

function UpDate:onEnter( )
    FishGF.print("------UpDate:onEnter--")
    --FishGMF.setGameState(0)
end

function UpDate:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function UpDate:receiveData( cur,all,speed )
    local str = math.floor(cur/1024).."/".. math.floor(all/1024).."KB"
    self.text_sizeper:setString(str)
    
    local per = cur/all*100
    self:setPercent(math.floor(per))

end

function UpDate:setPercent( per )
    self.bar_update:setPercent(per)
    self.text_bar_per:setString(per.."%")
end

function UpDate:loadingEnd(  )
    --cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.noticeSchedulerID )
    self:getParent():runNextScene();
    self:removeFromParent()
end

function UpDate:isCheckVer( isCheck )
    --self:setPercent(0)
    --self.spr_loading_circle:setVisible(not isCheck)
    self.text_bar_per:setVisible(not isCheck)
    self.text_sizeper:setVisible(not isCheck)
    --self.text_message:setVisible(not isCheck)

    if isCheck then
        self.text_word_1:setString("正在检测最新版本……")
    else
        self.text_word_1:setString("资源更新中……")
    end

end

return UpDate;