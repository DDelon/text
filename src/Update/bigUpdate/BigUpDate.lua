local BigUpDate = class("BigUpDate", cc.load("mvc").ViewBase)

BigUpDate.AUTO_RESOLUTION   = false
BigUpDate.RESOURCE_FILENAME = "ui/update/uiupdateversion"
BigUpDate.RESOURCE_BINDING  = {    
    ["panel"]           = { ["varname"] = "panel" }, 
    
    ["list_update"]     = { ["varname"] = "list_update" },
    ["img_listview_bg"] = { ["varname"] = "img_listview_bg" },
    
    ["btn_cancel"]      = { ["varname"] = "btn_cancel" ,         ["events"]={["event"]="click",["method"]="onClickcancel"}},   
    ["btn_update"]      = { ["varname"] = "btn_update" ,         ["events"]={["event"]="click",["method"]="onClickupdate"}},   
    
}

function BigUpDate:onCreate( ... )
    self:openTouchEventListener()
        
    -- self:setCurVersions("1.1.1")
    -- for i=1,10 do
    --     self:setVersionsData(i..".".."更多vs公司粉色粉非非司法多vs公司粉色粉色色非色非非司法多vs公司粉色粉色色非色非非司法多vs公司粉色粉色色非色非非司法过滤法的女快乐的歌看到的女最幸福vb对方噶改变")
    -- end

    --灰背景
    self.gray_bg = cc.Scale9Sprite:create("common/layerbg/com_pic_graybg.png");
    self.gray_bg:setScale9Enabled(true);
    local size = cc.Director:getInstance():getWinSize();
    self.gray_bg:setContentSize(size);
    self.gray_bg:setPosition(cc.p(0,0))
    self:addChild(self.gray_bg,-1);
    self.gray_bg:setScale(2)
    self.func = nil;
end

function BigUpDate:onEnter( )
    print("------BigUpDate:onEnter--")
    --FishGMF.setGameState(0)
end

function BigUpDate:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function BigUpDate:setUpdateFunc(func)
    self.func = func;
end

function BigUpDate:onClickcancel( sender )
    print("onClickcancel")
    os.exit(0)

end

function BigUpDate:onClickupdate( sender )
    print("onClickupdate")
    self.func();
    self:setVisible(false);
    self.func = nil;
end

function BigUpDate:setCurVersions( versions )
    print("setCurVersions")
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

function BigUpDate:setVersionsData( itemdata )
    print("setVersionsData")
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

function BigUpDate:showLayer()
    self:setVisible(true)
    self.gray_bg:setVisible(true)

end

function BigUpDate:hideLayer()
    self:setVisible(false)
    self.gray_bg:setVisible(false)
end

return BigUpDate;