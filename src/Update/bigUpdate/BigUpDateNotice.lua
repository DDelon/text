local BigUpDateNotice = class("BigUpDateNotice", cc.load("mvc").ViewBase)

BigUpDateNotice.AUTO_RESOLUTION   = false
BigUpDateNotice.RESOURCE_FILENAME = "ui/update/uiupdatenotice"
BigUpDateNotice.RESOURCE_BINDING  = {    
    ["panel"]           = { ["varname"] = "panel" }, 
    
    ["list_update"]     = { ["varname"] = "list_update" },
    ["img_listview_bg"] = { ["varname"] = "img_listview_bg" },
    
    ["btn_sure"]        = { ["varname"] = "btn_sure" ,         ["events"]={["event"]="click",["method"]="onClicksure"}},   

}

function BigUpDateNotice:onCreate( ... )
    self:openTouchEventListener()
    
end

function BigUpDateNotice:onEnter( )
    print("------BigUpDateNotice:onEnter--")
    --FishGMF.setGameState(0)
end

function BigUpDateNotice:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function BigUpDateNotice:onClicksure( sender )
    print("onClicksure")
    self:setVisible(false)
end


function BigUpDateNotice:setCurVersions( versions )
    print("BigUpDateNotice--setCurVersions")
    self.list_update:removeAllChildren()
    local text_title = ccui.Text:create()
    text_title:ignoreContentAdaptWithSize(true)
    text_title:setTextAreaSize({width = 0, height = 0})
    text_title:setFontSize(26)
    text_title:setString("版本"..versions.."更新简要")
    text_title:setTextHorizontalAlignment(1)
    text_title:setLayoutComponentEnabled(true)
    text_title:setCascadeColorEnabled(true)
    text_title:setCascadeOpacityEnabled(true)
    text_title:setTextColor({r = 94, g = 18, b = 238})
 
    -- 创建一个布局
    local custom_item = ccui.Layout:create()  
    -- 设置内容大小
    local size = text_title:getContentSize()
    custom_item:setContentSize(cc.size(size.width,size.height+30))  
    -- 设置位置
    text_title:setPosition(cc.p(50+custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))  
    -- 往布局中添加一个按钮
    custom_item:addChild(text_title)
    -- 往ListView中添加一个布局
    self.list_update:addChild(custom_item) 

end

function BigUpDateNotice:setVersionsData( itemdata )
    print("BigUpDateNotice--setVersionsData")
    local text_title = ccui.Text:create()
    text_title:ignoreContentAdaptWithSize(true)
    text_title:setTextAreaSize({width = 670, height = 0})
    text_title:setFontSize(24)
    text_title:setString(itemdata)
    text_title:setTextHorizontalAlignment(1)
    text_title:setLayoutComponentEnabled(true)
    text_title:setCascadeColorEnabled(true)
    text_title:setCascadeOpacityEnabled(true)
    text_title:setTextColor({r = 70, g = 73, b = 78})
    text_title:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)

    -- 创建一个布局  
    local custom_item = ccui.Layout:create()  
    -- 设置内容大小  
    custom_item:setContentSize(text_title:getContentSize())  
    -- 设置位置  
    text_title:setPosition(cc.p(48+custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))  
    -- 往布局中添加一个按钮  
    custom_item:addChild(text_title)  
    -- 往ListView中添加一个布局  
    self.list_update:addChild(custom_item) 

end

return BigUpDateNotice;