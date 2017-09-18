
require("packages.mvc.extends.WidgetEx")

local ViewBase = class("ViewBase", cc.Node)
local LuaExtend= require ("res/LuaExtend")

function ViewBase:ctor(parent, node, name, ...)
    self.nodeType = "cocosStudio"
    self:enableNodeEvents()
    self.parent_ = parent
    self.name_ = name
    self.scaleX_=1
    self.scaleY_=1 
    self.scaleMin_= 0 
    --assert(scene ~= nil," scene  is  nil") 
    self:calcScale()
    self.resourceNode_ =nil
    self.waitingNode=nil
    self.onRemoveListeners_={}
    self.bCreateByNode = false
    
    -- check lua resource file

    local res = rawget(self.class, "RESOURCE_FILENAME")
    if node == nil then 
        if res then
            self:createResourceNode(res)
        end

        local binding = rawget(self.class, "RESOURCE_BINDING")
        if res and binding then
            self:createResourceBinding(binding)
        end
    else 
        self.bCreateByNode = true
        self.resourceNode_ = node
        local binding = rawget(self.class, "RESOURCE_BINDING")
        if res and binding then
            self:createResourceBindingByNode(binding)
        end
    end
    
    if self.onCreate then self:onCreate(...) end

    if node then 
        local parentNode = node:getParent()
        local localZOrder = node:getLocalZOrder()
        local anchorPoint = node:getAnchorPoint()
        local posX = node:getPositionX()
        local posY = node:getPositionY()
        local scaleX = node:getScaleX()
        local scaleY = node:getScaleY()
        node:removeFromParent()
        self:addChild(node)
        parentNode:addChild(self, localZOrder)
        self:setAnchorPoint(cc.p(anchorPoint))
        self:setPosition(cc.p(posX, posY))
        node:setPosition(cc.p(0, 0))
        self:setScaleX(scaleX)
        self:setScaleY(scaleY)
        node:setScaleX(1)
        node:setScaleY(1)
    end
end

function ViewBase:onEnter( )
    if self.parent_ == nil then 
        self.parent_ = self:getParent()
    end 
end

local function dispatchRemoveEvent_(listeners)
    for _,callback in ipairs(listeners) do
        callback()
    end
end

local function getChildNode( nodeParent, childName, tChildListTmp )
        local nodeChild = nil
        if table.getn(nodeParent:getChildren()) == 0 then 
            return nodeChild
        end 
        nodeChild = nodeParent:getChildByName(childName)
        if nodeChild then 
            if tChildListTmp then 
                tChildListTmp[childName] = nodeChild
            end
            return nodeChild
        end
        for i, v in ipairs(nodeParent:getChildren()) do 
            nodeChild = v:getChildByName(childName)
            if nodeChild then 
                if tChildListTmp then 
                    tChildListTmp[childName] = nodeChild
                end
                return nodeChild
            else 
                nodeChild = getChildNode(v, childName, tChildListTmp)
                if nodeChild then 
                    return nodeChild
                end 
            end 
        end 
        return nodeChild
    end

function ViewBase:getName()
    return self.name_
end

-- 根据name获取子节点 包括ui节点 子节点中不可出现重名
function ViewBase:child(name)
    local child=self:getChildByName(name)
    local res_ui= self.resourceNode_
    if not child and res_ui then
        if res_ui[name] then 
            return res_ui[name]
        elseif self.bCreateByNode then 
            return getChildNode(res_ui, name)
        end
    end
    return child
end

-- function ViewBase:getApp()
--     return self.app_
-- end

-- function ViewBase:getName()
--     return self.name_
-- end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_.root:removeSelf()
        self.resourceNode_ = nil
    end
    
   local lua_ui = require(resourceFilename).create()
   if lua_ui then   
        self:addChild(lua_ui.root)
        self.resourceNode_ = lua_ui
        local resolution = rawget(self.class, "AUTO_RESOLUTION") 
        local com =  lua_ui.root:getComponent("__ui_layout")
        if com and resolution then
             com:setSize(display.size)
             com:refreshLayout()
        end
   end
end

function ViewBase:createResourceBinding(binding)
    local res_node=self.resourceNode_
    for nodeName, nodeBinding in pairs(binding) do
        local node =  res_node[nodeName]     
        assert(node, "ViewBase:createResourceBinding():error"..nodeBinding.varname)          
        if nodeBinding.varname and node then
           self[nodeBinding.varname] = node
           if nodeBinding.nodeType ~= nil then
               node.nodeType = nodeBinding.nodeType
           end
        end
        if nodeBinding.events ~= nil then
            if nodeBinding.events.event == "touch" then
                node:onTouch(self:handler(self, self[nodeBinding.events.method]))
            elseif nodeBinding.events.event == "click" then
                node:onClickScaleEffect(self:handler(self,self[nodeBinding.events.method]),self:handler(self,self[nodeBinding.events.methodTouchBegin]),
                    self:handler(self,self[nodeBinding.events.methodTouchMove]),self:handler(self,self[nodeBinding.events.methodTouchCancel]))
            elseif nodeBinding.events.event == "click_color" then
                node:onClickDarkEffect(self:handler(self,self[nodeBinding.events.method]),self:handler(self,self[nodeBinding.events.methodTouchBegin]),
                    self:handler(self,self[nodeBinding.events.methodTouchMove]),self:handler(self,self[nodeBinding.events.methodTouchCancel]))
            end        
        end
    end
end 

function ViewBase:createResourceBindingByNode(binding)
    local res_node=self.resourceNode_
    local tChildListTmp = {}
    for nodeName, nodeBinding in pairs(binding) do
        local node = nil
        if tChildListTmp[nodeName] then
            node =  tChildListTmp[nodeName]
        else 
            tChildListTmp = {}
            node = getChildNode(res_node, nodeName, tChildListTmp)
        end
        assert(node, "ViewBase:createResourceBinding():error"..nodeBinding.varname)          
        if nodeBinding.varname and node then
           self[nodeBinding.varname] = node
        end
        if nodeBinding.events ~= nil then
            if nodeBinding.events.event == "touch" then
                node:onTouch(self:handler(self, self[nodeBinding.events.method]))
            elseif nodeBinding.events.event == "click" then
                node:onClickScaleEffect(self:handler(self,self[nodeBinding.events.method]),self:handler(self,self[nodeBinding.events.methodTouchBegin]),
                    self:handler(self,self[nodeBinding.events.methodTouchMove]),self:handler(self,self[nodeBinding.events.methodTouchCancel]))
            elseif nodeBinding.events.event == "click_color" then
                node:onClickDarkEffect(self:handler(self,self[nodeBinding.events.method]),self:handler(self,self[nodeBinding.events.methodTouchBegin]),
                    self:handler(self,self[nodeBinding.events.methodTouchMove]),self:handler(self,self[nodeBinding.events.methodTouchCancel]))
            end          
        end
    end
end

function ViewBase:handler(obj, method)
    if method == nil then
        return
    end
    return handler(obj, method)
end

function ViewBase:buttonClicked(viewTag, btnTag)
    print("ViewBase:buttonClicked", viewTag, btnTag)
end

--得到缩放比例
function ViewBase:calcScale()
    local cfg_ds= CC_DESIGN_RESOLUTION
    if cfg_ds.autoscale == "FIXED_WIDTH" then
        self.scaleY_= display.height/cfg_ds.height
    elseif cfg_ds.autoscale == "FIXED_HEIGHT" then
        self.scaleX_= display.width/cfg_ds.width        
    end 
    ----------------------------
    self.scaleMin_ = self.scaleX_
    if self.scaleMin_ > self.scaleY_ then
        self.scaleMin_ = self.scaleY_
    end
end 

-- 视图对象自己压栈到当前场景
function ViewBase:pushInScene(invisiblePre)
   self:setVisible(true)    
   self.app_:pushViewInScene(self,invisiblePre)
   return self
end

--[[
添加事件监听 
eventName 事件名字
listener 事件监听函数
tag 事件tag
]]--
function ViewBase:addEventListener(eventName,listener)
    --GameApp:addEventListener(eventName,listener,self)    
end

function ViewBase:onCleanup()
    self.onRemoveListeners_={}
    --GameApp:removeEventListenersByTag(self)
end

-- 显示页面加载动画效果
function ViewBase:showLoading(msg,timeout)
    if msg then
        local onRemoveCallBack = function ( ... )
            self.waitingNode_=nil
            printf("remove waiting ...")
        end
        timeout= timeout or 30
        local waiting = require("common.widgets.WaitingDialog"):create(msg,timeout,onRemoveCallBack)
        self:addChild(waiting)
        self.waitingNode_ =waiting
    elseif self.waitingNode_  then      
        self.waitingNode_:removeFromParent()
        self.waitingNode_=nil      
    end
end

-- 层删除回掉事件
function ViewBase:addRemoveListener(onRemoveSelfCallback)
    if self.onRemoveListeners_ and onRemoveSelfCallback then
       table.insert(self.onRemoveListeners_,onRemoveSelfCallback)
    end
end

function ViewBase:removeSelf()
    dispatchRemoveEvent_(self.onRemoveListeners_)
    self:removeFromParent()
    return self
end

-- 发送返回键事件通知
function ViewBase:postKeyBackClick()
    self.app_:onKeyBackClicked()
end

-- 返回键处理函数  如需要 拦截返回键  ret1  是否已处理  ret2 是否已删除 
function ViewBase:keyBackClicked() 
    printf(" ViewBase:keyBackClicked")
    local ret,removed=false
    if self.waitingNode_ then
         ret,removed=self.waitingNode_:keyBackClicked()
    end
    if not ret then
        self:removeSelf();
        ret=true
        removed=true
    end
    return ret,removed
end
 
function ViewBase:showToast(text)
    self.app_:showToast(self,text)
end

function ViewBase:initWinEditBox(box,isPassword,isMediate)
     local mybox = self[box]
    local parent = mybox:getParent()
    isPassword = isPassword or false
    local editBoxSize = mybox:getContentSize()
    local grayColor = cc.c3b(172,181,186)
    self[box] = ccui.EditBox:create(cc.size(editBoxSize.width , editBoxSize.height + 20 ), "_")--editBoxSize.height
    self[box]:setPosition(cc.p(mybox:getPositionX() , mybox:getPositionY()))
    self[box]:setAnchorPoint(cc.p(mybox:getAnchorPoint()))
    self[box]:setPlaceHolder(mybox:getPlaceHolder())
    self[box]:setPlaceholderFontColor(grayColor)
    self[box]:setFontColor(mybox:getColor())
    self[box].mFontColor = mybox:getColor()
    --self[box]:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    self[box]:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self[box]:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    self[box]:setFontSize( mybox:getFontSize() )
    self[box].mFontSize = mybox:getFontSize()
    self[box]:setPlaceholderFontSize(mybox:getFontSize())
    --self[box]:setPosition(cc.p(node:getPositionX()*self.scaleMin_,node:getPositionY()*self.scaleMin_))
    
    local issetMaxLengthEnabled = mybox:isMaxLengthEnabled()
    if issetMaxLengthEnabled then
        self[box]:setMaxLength(mybox:getMaxLength())
    end

    self[box].isPassword = isPassword
    if isPassword then 
        self[box]:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
      else
        self[box]:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD);
    end
    parent:addChild(self[box])

    self[box].setString = function(self,str)
        self:setText(str)
    end
    self[box].getString = function(self)
        return self:getText()
    end

    isMediate = true
    --输入完之后是否居中
    if isMediate then
        self[box]:setPlaceholderFontColor(cc.c4b(255,255,255,0))
        local text_str = ccui.Text:create()
        text_str:ignoreContentAdaptWithSize(true)
        text_str:setTextAreaSize({width = 0, height = 0})
        text_str:setFontSize(mybox:getFontSize())
        text_str:setString("")
        text_str:setTextHorizontalAlignment(1)
        text_str:setTextVerticalAlignment(1)
        text_str:setLayoutComponentEnabled(true)
        text_str:setName("text_str")
        text_str:setCascadeColorEnabled(true)
        text_str:setCascadeOpacityEnabled(true)
        text_str:setTextColor(mybox:getColor())
        text_str.mFontColor = mybox:getColor()
        parent:addChild(text_str)   
        self[box].text_str = text_str
        text_str:setPosition(cc.p(mybox:getPositionX() , mybox:getPositionY()))
        text_str:setAnchorPoint(cc.p(mybox:getAnchorPoint()))
        text_str.isPassword = isPassword
        text_str.setStringData = function(self,str)
            local newStr = ""
            if self.isPassword then
                for i=1,#str do
                    newStr = newStr.."*"
                end
            else
                newStr = str
            end
            text_str:setString(newStr)
        end

        self[box].setString = function(self,str)
            self:setFontColor(cc.c4b(self.mFontColor.r,self.mFontColor.g,self.mFontColor.b,0))
            self:setText(str)
            self.text_str:setStringData(str)
            if str == "" then
                self.text_str:setString(self:getPlaceHolder())
                self.text_str:setTextColor(grayColor)
            else
                self.text_str:setTextColor(self.text_str.mFontColor)
            end
        end

        --没有初始化str的要调用这个
        self[box].setNewPlaceHolder = function(self,str)
            self:setPlaceHolder(str)
            self.text_str:setString(str)
            self.text_str:setTextColor(grayColor)
        end


        --输入框的事件，主要有光标移进去，光标移出来，以及输入内容改变等
        self[box]:registerScriptEditBoxHandler(
            function(strEventName,pSender) 
                if strEventName == "began" then --编辑框开始编辑时调用
                    print("----------------began---------")
                    pSender.text_str:setVisible(false)
                    local c3bColor = pSender.mFontColor
                    pSender:setFontColor(cc.c4b(c3bColor.r,c3bColor.g,c3bColor.b,255))
                elseif strEventName == "ended" then -- 当编辑框失去焦点并且键盘消失的时候被调用
                    print("----------------ended---------")
                    local str = pSender:getText()
                    pSender.text_str:setStringData(str)
                    pSender.text_str:setVisible(true) 
                    local c3bColor = pSender.mFontColor
                    pSender:setFontColor(cc.c4b(c3bColor.r,c3bColor.g,c3bColor.b,0))
                    if str == "" then
                        pSender.text_str:setString(pSender:getPlaceHolder())
                        pSender.text_str:setTextColor(grayColor)
                    else
                        pSender.text_str:setTextColor(pSender.text_str.mFontColor)
                    end
                elseif strEventName == "return" then --编辑框return时调用-- 当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
                    --判断是哪个编辑框，在多个编辑框同时绑定此函数时 需判断时哪个编辑框
                    if edit == EditName then 
                    --当编辑框EditName 按下return 时到此处
                    elseif edit == EditPassword then
                    --当编辑框EditPassword  按下return 时到此处
                    elseif edit == EditEmail then
                    --当编辑框EditEmail   按下return 时到此处
                    end
                elseif strEventName == "changed" then --编辑框内容改变时调用
                    print("---changed--text = "..pSender:getText())
                    --pSender.text_str:setString(pSender:getText())
                end
            end) 


    end

    mybox:removeFromParent()

end



function ViewBase:receiveNetData( netData )

end

function ViewBase:showLayer(isAct,opacity)
    if isAct == nil then
      isAct = true
    end

    if isAct then
      FishGI.showLayerData:showLayer(self,nil,opacity)
    else
      FishGI.showLayerData:showLayerByNoAct(self,nil,opacity)
    end

    self:initEditBoxStr("")
end

function ViewBase:hideLayer(isAct,isRemove,isScale,allActTime)
    if isAct == nil then
      isAct = true
    end
    isRemove = isRemove or false
    if isAct then
      FishGI.AudioControl:playEffect("sound/exit_01.mp3")
      FishGI.showLayerData:hideLayer(self,isRemove,isScale,allActTime)
    else
      FishGI.showLayerData:hideLayerByNoAct(self,isRemove,isScale)
    end
end

function ViewBase:initEditBoxStr(str)

end

--初始化触摸监听
function ViewBase:openTouchEventListener(isSwallow)
    if isSwallow == nil then
        isSwallow = true
    end
    --添加触摸监听
    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(isSwallow)
    listener:registerScriptHandler(handler(self,self.onTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN);
    listener:registerScriptHandler(handler(self,self.onTouchMoved),cc.Handler.EVENT_TOUCH_MOVED);
    listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED);    
    listener:registerScriptHandler(handler(self,self.onTouchCancelled),cc.Handler.EVENT_TOUCH_CANCELLED);
    local eventDispatcher = self:getEventDispatcher() -- 得到事件派发器
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self) -- 将监听器注册到派发器中
    
end

function ViewBase:onTouchBegan(touch, event)
    return false
end

function ViewBase:onTouchMoved(touch, event)
end

function ViewBase:onTouchEnded(touch, event) 
end

function ViewBase:onTouchCancelled(touch, event) 
end

function ViewBase:getViewUIControll(uiFirstControll, ...)
    local uiControll = self:getViewUIControllNoAssert(uiFirstControll, ...)
    assert(uiControll)
    return uiControll
end

function ViewBase:getViewUIControllNoAssert(uiFirstControll, ...)
    local uiControll = uiFirstControll;
    local args = {...}
    for i, uiControllName in ipairs(args) do
        if uiControll then
            uiControll = uiControll:getChildByName(uiControllName)
        else
            break
        end
    end
    return uiControll
end

--控件类型
local g_eUIControllType = {
    None = 0,
    Node = 1,
    Sprite = 2,
    Label = 3,
    Button = 4,
    EditBox = 5,
    CheckBox = 6,
    ImageView = 7,
    Layout = 8,
    ScrollView = 9,
    ListView = 10,
}
local g_tUIControllType = {}
for i,v in pairs(g_eUIControllType) do
    g_tUIControllType[v] = i
end

--控件配置
local g_tUIControllInfo = {
    None = {
                false, --分辨率适配时可作为画布拉伸的控件
            },
    Node = {false},
    Sprite = {false},
    Label = {false},
    Button = {false},
    EditBox = {false},
    CheckBox = {false},
    ImageView = {false},
    Layout = {true},
    ScrollView = {true},
    ListView = {true},
}

-- 分辨率适配
function ViewBase:makeResolutionAdaptation(uiControll, bIsLayer, uiControllBg)

    if uiControll == nil then
        return
    end

    if bIsLayer == nil then
        bIsLayer = false
    end

    --获取控件类型
    local function getControllType(uiControll)
        local strControllName = uiControll:getDescription()
        if string.byte(strControllName, 1) == 60--[['<'--]] then
            local iBlankIndex = string.find(strControllName, ' ')
            if iBlankIndex then
                strControllName = string.sub(strControllName, 2, iBlankIndex-1)
            end
        end
        if g_tUIControllInfo[strControllName] then
            return g_eUIControllType[strControllName]
        else
            return g_eUIControllType.None
        end
    end

    -- 控件可拉伸，用于分辨率适配
    local function getIsControllStretchable(eControllType)
        return g_tUIControllInfo[g_tUIControllType[eControllType]][1]
    end

    local function adaptationUIControll(uiControllTmp, fScaleX, fScaleY, fScale)
        for j, v in pairs(uiControllTmp:getChildren()) do
            local eControllType = getControllType(v)
            local layout = ccui.LayoutComponent:bindLayoutComponent(v)
            if getIsControllStretchable(eControllType) then
                if not layout:isPercentWidthEnabled() then 
                    v:setContentSize(cc.size(v:getContentSize().width*fScaleX, v:getContentSize().height))
                end 
                if not layout:isPercentHeightEnabled() then 
                    v:setContentSize(cc.size(v:getContentSize().width, v:getContentSize().height*fScaleY))
                end 
                -- if not layout:isPositionPercentXEnabled() then 
                --     v:setPositionX(v:getPositionX()*v:getScaleX()*fScaleX)
                -- end 
                -- if not layout:isPositionPercentYEnabled() then 
                --     v:setPositionY(v:getPositionY()*v:getScaleY()*fScaleY)
                -- end 
                v:setPosition(cc.p(v:getPositionX()*v:getScaleX()*fScaleX, v:getPositionY()*v:getScaleY()*fScaleY))
                adaptationUIControll(v, fScaleX, fScaleY, fScale)
            elseif eControllType == g_eUIControllType.Node and v.animation then
                v:setPosition(cc.p(v:getPositionX()*fScaleX, v:getPositionY()*fScaleY))
                adaptationUIControll(v, fScaleX, fScaleY, fScale)
            else
                v:setScaleX(v:getScaleX()*fScale)
                v:setScaleY(v:getScaleY()*fScale)
                -- if not layout:isPositionPercentXEnabled() then 
                --     v:setPositionX(v:getPositionX()*fScaleX)
                -- end 
                -- if not layout:isPositionPercentYEnabled() then 
                --     v:setPositionY(v:getPositionY()*fScaleY)
                -- end 
                v:setPosition(cc.p(v:getPositionX()*fScaleX, v:getPositionY()*fScaleY))
            end
        end
    end

    local fScaleX = display.width / CC_DESIGN_RESOLUTION.width
    local fScaleY = display.height / CC_DESIGN_RESOLUTION.height
    local fScale
    if CC_DESIGN_RESOLUTION.autoscale == "FIXED_HEIGHT" then
        fScale = fScaleX
    elseif CC_DESIGN_RESOLUTION.autoscale == "FIXED_WIDTH" then
        fScale = fScaleY
    else
        print("CC_DESIGN_RESOLUTION.autoscale error .")
        assert(false)
    end
    if bIsLayer then
        uiControll:setContentSize(cc.size(uiControll:getContentSize().width * fScaleX, uiControll:getContentSize().height * fScaleY))
    end
    for i, v in ipairs(uiControll:getChildren()) do
        local eControllType = getControllType(v)
        local layout = ccui.LayoutComponent:bindLayoutComponent(v)
        if getIsControllStretchable(eControllType) then
            if not layout:isPercentWidthEnabled() then 
                v:setContentSize(cc.size(v:getContentSize().width*fScaleX, v:getContentSize().height))
            end 
            if not layout:isPercentHeightEnabled() then 
                v:setContentSize(cc.size(v:getContentSize().width, v:getContentSize().height*fScaleY))
            end 
            v:setPosition(cc.p(v:getPositionX()*v:getScaleX()*fScaleX, v:getPositionY()*v:getScaleY()*fScaleY))
            adaptationUIControll(v, fScaleX, fScaleY, fScale)
        elseif eControllType == g_eUIControllType.Node and v.animation then
            v:setPosition(cc.p(v:getPositionX()*fScaleX, v:getPositionY()*fScaleY))
            adaptationUIControll(v, fScaleX, fScaleY, fScale)
        else 
            if uiControllBg == nil or v ~= uiControllBg then
                v:setScale(fScale)
            end
            v:setPosition(cc.p(v:getPositionX()*fScaleX, v:getPositionY()*fScaleY))
        end
    end
end

return ViewBase
