local RuleIntroduction = class("RuleIntroduction", cc.load("mvc").ViewBase)

RuleIntroduction.AUTO_RESOLUTION   = false
RuleIntroduction.RESOURCE_FILENAME = "ui/hall/friend/uiruleintroduction"
RuleIntroduction.RESOURCE_BINDING  = {    
    ["panel"]           = { ["varname"] = "panel" }, 
    
    ["list_update"]     = { ["varname"] = "list_update" ,         ["nodeType"]="viewlist"   },
    ["img_listview_bg"] = { ["varname"] = "img_listview_bg" },
    
    ["btn_sure"]        = { ["varname"] = "btn_sure" ,         ["events"]={["event"]="click",["method"]="onClicksure"}},   
    ["btn_close"]       = { ["varname"] = "btn_close" ,        ["events"]={["event"]="click",["method"]="onClickclose"}}, 
}

function RuleIntroduction:onCreate( ... )
    self:openTouchEventListener()
    for i=0,3 do
        local strData = FishGF.getChByIndex(800000275 + i)
        local newStrData = string.gsub( strData,"\\n","\n")
        self:setVersionsData(newStrData)
    end

end

function RuleIntroduction:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function RuleIntroduction:onClicksure( sender )
    print("onClicksure")
    self:hideLayer()
end

function RuleIntroduction:onClickclose( sender )
    print("onClickclose")
    self:hideLayer()
end

function RuleIntroduction:setVersionsData( itemdata )
    print("RuleIntroduction--setVersionsData")
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
    custom_item.nodeType = "cocosStudio"
    -- 设置内容大小  
    custom_item:setContentSize(text_title:getContentSize())  
    -- 设置位置  
    text_title:setPosition(cc.p(48+custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))  
    -- 往布局中添加一个按钮  
    custom_item:addChild(text_title)  
    -- 往ListView中添加一个布局  
    self.list_update:addChild(custom_item) 

end

return RuleIntroduction;