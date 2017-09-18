
local ChangeAccount = class("ChangeAccount", cc.load("mvc").ViewBase)

ChangeAccount.AUTO_RESOLUTION   = true
ChangeAccount.RESOURCE_FILENAME = "ui/login/uichangeaccount"
ChangeAccount.RESOURCE_BINDING  = {    
       ["panel"]       = { ["varname"] = "panel" }, 
       ["btn_OK"]      = { ["varname"] = "btn_OK",         ["events"]={["event"]="click",["method"]="onClickOK"} }, 
       
       ["scroll_list"] = { ["varname"] = "scroll_list",    ["nodeType"]="viewlist"   },
}

function ChangeAccount:onCreate( ... )
    self.scroll_list:setScrollBarEnabled(false)
    self.scroll_list:setSwallowTouches(false)

    self:openTouchEventListener()

    self:initData()
end

function ChangeAccount:initData( )
    --self.WritePlayerData = require("Other/WritePlayerData").create();
    FishGI.WritePlayerData:loadFile("accountlist.plist")
    self.count = FishGI.WritePlayerData:getMaxKeys()
    print("----self.count="..self.count)
    self:upDataListByData()
end

function ChangeAccount:getEndAccount()
    return FishGI.WritePlayerData:getEndData()
end

function ChangeAccount:upDataListByData( )
    self.accountListView = {}
    local accountList = FishGI.WritePlayerData:getAllData()
    self.cellW = self.scroll_list:getContentSize().width 
    self.sizeH =self.scroll_list:getContentSize().height 
    self.cellH = 0
    for i=1,self.count do
        local data = accountList[tostring(i)]
        if data ~= nil then
            local accountItem = self:addAccount(i,data.account,data.password,data.isVisitor)
            self.scroll_list:addChild( accountItem)
            self.accountListView[i] = accountItem
            local image_bg = accountItem.panel:getChildByName("image_bg")
            self.cellH = image_bg:getContentSize().height 
        end
    end

    self:upDataListPos()
end

function ChangeAccount:addAccount(tag,account, password,isVisitor)
    local uiaccountItem = require("ui/login/uiaccountitem").create()
    local accountItem = uiaccountItem.root
    accountItem.nodeType = "cocosStudio"
    accountItem["account"] = account
    accountItem["password"] = password
    accountItem["isVisitor"] = isVisitor
    local text_account = uiaccountItem["text_account"]
    local btn_del = uiaccountItem["btn_del"]
    accountItem["btn_del"] = btn_del
    btn_del:setTag(tonumber(tag))
    btn_del["account"] = account
    btn_del["password"] = password
    btn_del["isVisitor"] = isVisitor
--    print("------password="..password)
    btn_del:addTouchEventListener(handler(self, self.onDelAccount))
    if isVisitor ~= nil then
        account = isVisitor
    end
    text_account:setString(account)
    accountItem.panel = uiaccountItem["panel"] 
    return accountItem
end

function ChangeAccount:upDataListPos()
    self.scroll_list:setInnerContainerSize(cc.size(self.cellW, self.cellH*self.count))
--    print("--------------self.count="..self.count.."----self.cellH="..self.cellH)

    if self.accountListView == nil then
        return
    end
    local topY = self.cellH*self.count
    if topY <= self.sizeH then
        topY = self.sizeH
    end
    for i=1,#self.accountListView do
--        print("----self.i="..i)
        local accountItem = self.accountListView[i]
        accountItem:setPosition(cc.p(self.cellW/2,topY - self.cellH/2 - (#self.accountListView - i)*self.cellH ))
        if #self.accountListView == 1 then
            accountItem["btn_del"]:setVisible(false)
        else
            accountItem["btn_del"]:setVisible(true)
        end
    end
end

function ChangeAccount:onTouchBegan(touch, event)
    if not self:isVisible() then
        return false  
    end
    FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    local curPos = touch:getLocation()  
    local key = nil 
    for k,child in pairs(self.accountListView) do
        local image_bg = child.panel:getChildByName("image_bg")
        local s = image_bg:getContentSize()
        local locationInNode = image_bg:convertToNodeSpace(curPos)
        local rect = cc.rect(0,0,s.width,s.height)
        if cc.rectContainsPoint(rect,locationInNode) then
            key = k
            break
        end
    end
    if key ~= nil then
        for k,child in pairs(self.accountListView) do
            local image_bg = child.panel:getChildByName("image_bg")
            if k == key then
                image_bg:setColor(cc.c3b(0,128,0))
                local text_account = child.panel:getChildByName("text_account")
                text_account:setTextColor(cc.c3b(255,255,255))
                self.curChose = child
            else
                image_bg:setColor(cc.c3b(255,255,255))
                local text_account = child.panel:getChildByName("text_account")
                text_account:setTextColor(cc.c3b(0,0,0))
            end
        end
    end

    return true
end

function ChangeAccount:onDelAccount( sender,eventType )
    FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    if eventType == ccui.TouchEventType.ended then
        local tag = sender:getTag()
        local newData = {};
        local item = nil
        for key, val in ipairs(self.accountListView) do
            if val["account"] ~= sender["account"] then
                table.insert(newData, val);
            else
                item = val
            end
        end
        if newData ~= {} and #newData ~= 0 then
            item:removeFromParent()
            self.accountListView = newData
            self:removeByKey(sender["account"])
        end
    end

end

function ChangeAccount:removeByKey( account )
    local key = FishGI.WritePlayerData:getKey("account",account)
    FishGI.WritePlayerData:removeByKey(key)
    self:upDataListPos()
end

function ChangeAccount:onClickOK( sender )
    --FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    local account = nil
    if self.curChose ~= nil and self.curChose["account"] ~= nil then
        account= self.curChose["account"]
        if self.curChose["isVisitor"] ~= nil then
            account = self.curChose["isVisitor"]
        end
        local AccountTab = {}
        AccountTab["account"] = self.curChose["account"]
        AccountTab["password"] = self.curChose["password"]
        AccountTab["isVisitor"] = self.curChose["isVisitor"]
        FishGI.WritePlayerData:upDataAccount(AccountTab)
    else
        local EndAccount = self:getEndAccount()
        if EndAccount ~= nil then
            account = EndAccount["account"]
            if EndAccount["isVisitor"] ~= nil then
                account = EndAccount["isVisitor"]
            end
        else
            account = ""
        end
    end
    self:getParent().text_account:setString(account)

    self:hideLayer() 
end

return ChangeAccount;