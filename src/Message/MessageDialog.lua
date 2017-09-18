
local MessageDialog = class("MessageDialog", cc.load("mvc").ViewBase)

MessageDialog.AUTO_RESOLUTION   = false
MessageDialog.RESOURCE_FILENAME = "ui/common/uiMessageDialog"
MessageDialog.RESOURCE_BINDING  = {  
    ["panel"]              = { ["varname"] = "panel" },
    
    ["node_middle"]        = { ["varname"] = "node_middle" },
    ["btn_middle_only_OK"] = { ["varname"] = "btn_middle_only_OK" , ["events"]={["event"]="click",["method"]="onClickCallback"}},  
    ["btn_middle_OK"]      = { ["varname"] = "btn_middle_OK" ,      ["events"]={["event"]="click",["method"]="onClickCallback"}},      
    ["btn_middle_CANCEL"]  = { ["varname"] = "btn_middle_CANCEL" ,  ["events"]={["event"]="click",["method"]="onClickCallback"}},  
    
    ["node_hook"]          = { ["varname"] = "node_hook" },
    ["btn_hook"]           = { ["varname"] = "btn_hook" ,           ["events"]={["event"]="click",["method"]="onClickCallback"}},  
    ["text_notice"]        = { ["varname"] = "text_notice" },  
    
    ["text_middle_data"]   = { ["varname"] = "text_middle_data" },    
    
    ["node_min"]           = { ["varname"] = "node_min" },
    ["btn_min_only_OK"]    = { ["varname"] = "btn_min_only_OK" ,    ["events"]={["event"]="click",["method"]="onClickCallback"}},  
    ["text_min_data"]      = { ["varname"] = "text_min_data" },    

}

function MessageDialog:onCreate(...)   
    self.panel:setSwallowTouches(false)

    self:openTouchEventListener()
    
    self.btn_hook:getChildByName("spr_hook"):setVisible(false)
    --self.text_notice:setString(FishGF.getChByIndex(800000120)) 
end

function MessageDialog:initBtnShow()   
    self.node_middle:setVisible(false)
    self.node_min:setVisible(false)  

    self.btn_min_only_OK:setVisible(false)  
    self.btn_min_only_OK:setTag(0)

    self.btn_middle_only_OK:setVisible(false)  
    self.btn_middle_only_OK:setTag(1)

    self.btn_middle_OK:setVisible(false)  
    self.btn_middle_OK:setTag(2)
    self.btn_middle_CANCEL:setVisible(false)  
    self.btn_middle_CANCEL:setTag(3)

    self.node_hook:setVisible(false)  
    self.btn_hook:setTag(4)

end

function MessageDialog:setData(modeType ,strData, callBack,strHook) 
    self.modeType = modeType

    self:initBtnShow() 

    self.panel:setVisible(true)
    
    --tag值  0为小背景的确定，  1为中背景的确定，2为中背景的确定，3为中背景的取消, 4为勾选框
    if callBack ~= nil then
        self.btn_min_only_OK:addClickEventListener(callBack)
        self.btn_middle_only_OK:addClickEventListener(callBack)
        self.btn_middle_OK:addClickEventListener(callBack)
        self.btn_middle_CANCEL:addClickEventListener(callBack)
        self.btn_hook:addClickEventListener(callBack)
    end
   
    if modeType == FishCD.MODE_MIN_OK_ONLY then
        self.node_min:setVisible(true) 
        self.btn_min_only_OK:setVisible(true)  
    elseif modeType == FishCD.MODE_MIDDLE_OK_ONLY then 
        self.node_middle:setVisible(true)
        self.btn_middle_only_OK:setVisible(true)     
    elseif modeType == FishCD.MODE_MIDDLE_OK_CLOSE then 
        self.node_middle:setVisible(true)
        self.btn_middle_OK:setVisible(true)
        self.btn_middle_CANCEL:setVisible(true)
    elseif modeType == FishCD.MODE_MIDDLE_OK_CLOSE_HOOK then
        self.node_middle:setVisible(true)
        self.btn_middle_OK:setVisible(true)
        self.btn_middle_CANCEL:setVisible(true)
        self.node_hook:setVisible(true)
        self.btn_hook:getChildByName("spr_hook"):setVisible(false)
    end

    if strHook == nil then
        strHook = "本次登录不再提示！"
    end
    self.text_notice:setString(strHook) 
    self:setTextData(strData) 
end

function MessageDialog:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function MessageDialog:setTextData( str )
    self.text_middle_data:setString(str)
    self.text_min_data:setString(str)   
end

function MessageDialog:onClickCallback( sender )
    print("--MessageDialog:onClickCallback-")

    --tag值  0为小背景的确定，  1为中背景的确定，2为中背景的确定，3为中背景的取消
    local tag = sender:getTag()
    if tag == 0 or tag == 1 or tag == 2 or tag == 3 then
        self:hideLayer(true,true) 
    end

end

return MessageDialog;