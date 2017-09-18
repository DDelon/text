
local MailBody = class("MailBody", cc.load("mvc").ViewBase)

MailBody.AUTO_RESOLUTION   = false
MailBody.RESOURCE_FILENAME = "ui/hall/mail/uimailbody"
MailBody.RESOURCE_BINDING  = {  
    ["panel"]        = { ["varname"] = "panel" },  
    ["btn_sure"]     = { ["varname"] = "btn_sure" ,         ["events"]={["event"]="click",["method"]="onClicksure"}},   
    ["btn_close"]    = { ["varname"] = "btn_close" ,        ["events"]={["event"]="click",["method"]="onClickclose"}},   
    
    
    ["text_time"]    = { ["varname"] = "text_time" },   
    ["text_sender"]  = { ["varname"] = "text_sender" },
    ["text_body"]    = { ["varname"] = "text_body" }, 
    ["text_title"]   = { ["varname"] = "text_title" }, 
    
    ["scroll_props"] = { ["varname"] = "scroll_props" }, 
 
}

function MailBody:onCreate(...)   

    self.scroll_props:setScrollBarEnabled(false)

    self:openTouchEventListener()
    
end

function MailBody:onTouchBegan(touch, event)
    if self:isVisible() then
         return true  
    end

    return false
end

function MailBody:onClickclose( sender )
    self:hideLayer() 
end

--设置邮件数据
function MailBody:setBodyData(val)   
    if val == nil then
        return
    end

    self.mailData = val

    local id = val.id
    local title = val.title
    local sender = val.sender
    --local sendTime =val.sendTime
    local sendTime = FishGF.clipTime(val.sendTime)
    local content =val.content
    local props =val.props
    self:createGetProp(props)

    self.text_sender:setString(sender)
    self.text_time:setString(sendTime)
    self.text_body:setString(content)
    self.text_title:setString(title)

    --更新按键
    self.btn_sure:getChildByName("spr_gb"):setVisible(not self.isGetProp)
    self.btn_sure:getChildByName("spr_lq"):setVisible(self.isGetProp)

end

--得到邮件数据 
function MailBody:getItemData()   
    return self.mailData
end

function MailBody:onClicksure( sender )
    print("--MailBody--onClicksure-------")
    if self.isGetProp then
        FishGI.hallScene.net.roommanager:sendMarkMailAsRead(self.mailData.id)
    else
        self:hideLayer()
    end
end

function MailBody:receiveBodyData( data )
    print("--MailBody--receiveBodyData-------")
    local success = data.success
    if success then
        self:showLayer()
    else
        return
    end

    self.isGetProp = false
    if next(data.props) ~= nil then
        self.isGetProp = true
    end
    if data.seniorProps == nil then
        data.seniorProps = {}
    end
    if next(data.seniorProps) ~= nil then
        self.isGetProp = true
        for k,val in pairs(data.seniorProps) do
            val.propCount = 1
            table.insert( data.props,val)
        end
    end

    if not self.isGetProp then
        FishGI.hallScene.net.roommanager:sendMarkMailAsRead(data.id)
    end

    self:setBodyData(data)

end

--领取道具
function MailBody:getMailProp( data )
    local success = data.success
    local id = data.id
    local props = data.props
    local seniorProps = data.seniorProps

    if not success then
        print("---getMailProp--fail----")
        return
    end

    local playerId = FishGI.myData.playerId
    for k,val in pairs(props) do
        --更新数据
        FishGMF.addTrueAndFlyProp(playerId,val.propId,val.propCount,false)
        FishGMF.setAddFlyProp(playerId,val.propId,val.propCount,false)

        local propTab = {}
        propTab.playerId = playerId
        propTab.propId = val.propId
        propTab.propCount = val.propCount
        propTab.isRefreshData = true
        propTab.isJump = false
        propTab.firstPos = self:getFirstPosByPropId(val.propId)
        propTab.dropType = "normal"
        propTab.isShowCount = false
        FishGI.GameEffect:playDropProp(propTab)

    end

    --高级道具
    for k,val in pairs(seniorProps) do
        --更新数据
        FishGMF.refreshSeniorPropData(playerId,val,8,0)

        local propTab = {}
        propTab.playerId = playerId
        propTab.propId = val.propId
        propTab.propCount = 1
        propTab.isRefreshData = true
        propTab.isJump = false
        propTab.firstPos = self:getFirstPosByPropId(val.propId)
        propTab.dropType = "normal"
        propTab.isShowCount = false
        propTab.seniorPropData = val
        FishGI.GameEffect:playDropProp(propTab)
    end

    self.isGetProp = false
    if next(data.props) ~= nil then
        self.isGetProp = true
        self:hideLayer(false)
    end
    
    if next(data.seniorProps) ~= nil then
        self.isGetProp = true
        self:hideLayer(false)
    end

end

--创建要领取的道具列表
function MailBody:createGetProp( props )
    self.scroll_props:removeAllChildren()
    self.propList = {}
    local count = 0
    for k,prop in pairs(props) do
        local propNode = require("hall/Bag/Bagitem").create()
        local result = propNode:setItemData(prop.propId , prop.propCount)
        if result then
            self.scroll_props:addChild(propNode)
            self.propList[prop.propId] = propNode
            count = count+1
        end
    end

    local size = self.scroll_props:getContentSize()
    local dis = 150
    local leftPosX = size.width/2 - ((count - 1)*dis/2)

    local i = 1
    for k,val in pairs(self.propList) do
        val:setPositionX(leftPosX +(i - 1)*dis)
        val:setPositionY(size.height/2)        
        i = i+1
    end

end

--得到飞行道具的初始位置
function MailBody:getFirstPosByPropId( propId )
    local winSize = cc.Director:getInstance():getWinSize();
    local pos = cc.p(winSize.width/2,winSize.height/2)
    local child = self.propList[propId]
    pos = cc.p(child:getPositionX(),child:getPositionY())
    pos = self.scroll_props:convertToWorldSpace(pos)

    return pos
end

return MailBody;