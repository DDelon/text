
local InviteFriend = class("InviteFriend", cc.load("mvc").ViewBase)

InviteFriend.AUTO_RESOLUTION   = false
InviteFriend.RESOURCE_FILENAME = "ui/hall/wechatshare/uiinvitefriend"
InviteFriend.RESOURCE_BINDING  = {    
    ["panel"]            = { ["varname"] = "panel" },
    ["btn_close"]        = { ["varname"] = "btn_close" ,        ["events"]={["event"]="click",["method"]="onClickclose"}},     
    ["btn_getaward"]     = { ["varname"] = "btn_getaward" ,     ["events"]={["event"]="click",["method"]="onClickgetaward"}},     
    ["btn_copy"]         = { ["varname"] = "btn_copy" ,         ["events"]={["event"]="click",["method"]="onClickcopy"}},    
    
    ["tf_sharecode"]     = { ["varname"] = "tf_sharecode" }, 
    
    ["text_askcode"]     = { ["varname"] = "text_askcode" }, 
    
    ["text_word"]        = { ["varname"] = "text_word" }, 
    
    ["spr_getaward"]     = { ["varname"] = "spr_getaward" },  
    ["spr_getaward_end"] = { ["varname"] = "spr_getaward_end" },    

}

function InviteFriend:onCreate( ... )
    self:initData()
    self:initBgWord()

    self:openTouchEventListener()

end

function InviteFriend:initData()
end

function InviteFriend:initBgWord()
    self:initWinEditBox("tf_sharecode")
    self:child("text_word_mycode"):setString(FishGF.getChByIndex(800000127)..FishGF.getChByIndex(800000218))
    self.spr_getaward_end:setVisible(false)
    self.tf_sharecode:setPlaceHolder(FishGF.getChByIndex(800000166))

    local askcode_get = tostring(FishGI.GameConfig:getConfigData("config", tostring(990000043), "data"))..",0;"
    local askcodeTabData = FishGF.strToVec3(askcode_get)
    local straskcode = askcodeTabData[1].y..FishGF.getPropUnitByID(askcodeTabData[1].x)
    self.askcodeGet = askcodeTabData[1].y

    local askcode_count = tostring(FishGI.GameConfig:getConfigData("config", tostring(990000044), "data"))
    local countStr = FishGF.getChByIndex(800000126)..askcode_count..FishGF.getChByIndex(800000118)

    local str = FishGF.getChByIndex(800000125)..askcodeTabData[1].y..FishGF.getPropUnitByID(askcodeTabData[1].x)..FishGF.getChByIndex(800000162)..FishGF.getChByIndex(800000126)..askcode_count..FishGF.getChByIndex(800000118)
    self.text_word:setString("")

    local richText = ccui.RichText:create()  
    richText:ignoreContentAdaptWithSize(true)  
    local text1 = ccui.RichElementText:create( 1, cc.c3b(72, 79, 89), 255, FishGF.getChByIndex(800000125), "Arial", 28 )         
    richText:pushBackElement(text1)
    local text2 = ccui.RichElementText:create( 1, cc.c3b(192, 60, 2), 255, askcodeTabData[1].y..FishGF.getPropUnitByID(askcodeTabData[1].x), "Arial", 28 )         
    richText:pushBackElement(text2)
    local text3 = ccui.RichElementText:create( 1, cc.c3b(72, 79, 89), 255, FishGF.getChByIndex(800000162)..FishGF.getChByIndex(800000126), "Arial", 28 )         
    richText:pushBackElement(text3)
    local text4 = ccui.RichElementText:create( 1, cc.c3b(192, 60, 2), 255, askcode_count, "Arial", 28 )         
    richText:pushBackElement(text4)
    local text5 = ccui.RichElementText:create( 1, cc.c3b(72, 79, 89), 255, FishGF.getChByIndex(800000118)..FishGF.getChByIndex(800000220), "Arial", 28 )         
    richText:pushBackElement(text5)
    richText:setLocalZOrder(10)  
    richText:setTag(100)
    richText:setName("richText")
    richText:setPosition(cc.p(self.text_word:getPositionX(),self.text_word:getPositionY()));
    self.panel:addChild(richText);

    -- self.tf_sharecode:registerScriptEditBoxHandler(
    --     function(eventname,sender) 
    --         self:editBoxTextEventHandle(eventname,sender)
    --      end) --输入框的事件，主要有光标移进去，光标移出来，以及输入内容改变等
end

-- function InviteFriend:editBoxTextEventHandle(strEventName,pSender)
--         if strEventName == "began" then --编辑框开始编辑时调用
--         elseif strEventName == "ended" then --编辑框完成时调用
--         elseif strEventName == "return" then --编辑框return时调用
--             --判断是哪个编辑框，在多个编辑框同时绑定此函数时 需判断时哪个编辑框
--             if edit == EditName then 
--               --当编辑框EditName 按下return 时到此处
--             elseif edit == EditPassword then
--             --当编辑框EditPassword  按下return 时到此处
--             elseif edit == EditEmail then
--             --当编辑框EditEmail   按下return 时到此处
--             end
--         elseif strEventName == "changed" then --编辑框内容改变时调用
--             print("---------"..pSender:getString())
--         end

-- end

function InviteFriend:initEditBoxStr(str)
    self.tf_sharecode:setString(str);
end

function InviteFriend:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function InviteFriend:onClickclose( sender )
    self:hideLayer() 
end

function InviteFriend:onClickgetaward( sender )
    print("onClickgetaward")
    local otherCode = self.tf_sharecode:getString()
    if tostring(self.askcode) == otherCode then
        FishGF.showToast(FishGF.getChByIndex(800000179))
        return
    end

    if otherCode == nil or otherCode == "" then
        FishGF.showToast(FishGF.getChByIndex(800000177))
        return
    end

    self:setLayerType(true)
    FishGF.waitNetManager(true,nil,"getAward")
    local callback=function(x)
        -- 隐藏等待框
        FishGF.waitNetManager(false,nil,"getAward")
        if x.status == 0 then 
            if x.exist  == 1 then
                --发送消息
                FishGI.hallScene.net.roommanager:sendInviteCode();
            else
                self:setLayerType(false)
                FishGF.showSystemTip(nil,800000179,1);
            end
        else
            self:setLayerType(false)
            FishGF.showToast(x.msg)
        end
    end
    FishGI.Dapi:isExist(tonumber(otherCode), callback)

end

function InviteFriend:onClickcopy( sender )
    print("onClickcopy")
    FishGF.copy(tostring(self.askcode))
end

function InviteFriend:setMyCode( askcode )
    self.askcode = askcode
    self.text_askcode:setString(askcode)
end

function InviteFriend:setInviteCodeUsed( inviteCodeUsed )
    self.inviteCodeUsed = inviteCodeUsed
    self:setLayerType(inviteCodeUsed)
end

function InviteFriend:setLayerType( isUsed )
    self.isUsed = isUsed
    if isUsed then
        self.spr_getaward:setVisible(false)
        self.spr_getaward_end:setVisible(true)
        self.btn_getaward:setTouchEnabled(false)
        self.btn_getaward:setBright(false)
    else
        self.spr_getaward:setVisible(true)
        self.spr_getaward_end:setVisible(false)
        self.btn_getaward:setTouchEnabled(true)
        self.btn_getaward:setBright(true)
    end
end

function InviteFriend:inviteResult( data )
    if data.props == nil then
        data.props = {}
    end
    if data.seniorProps == nil then
        data.seniorProps = {}
    end

    FishGI.isInviteFriend = false
    local isSuccess = data.isSuccess;
    if isSuccess then
        print("领取成功");
        FishGF.showSystemTip(nil,800000156,1);
        self:setInviteCodeUsed(true) 
        for k,val in pairs(data.props) do
            if val ~= nil and val.propId ~= nil then
                FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,val.propId,val.propCount,false)
                FishGMF.setAddFlyProp(FishGI.myData.playerId,val.propId,val.propCount,false)
            end
        end

        for k,val in pairs(data.seniorProps) do
            if val ~= nil and val.propId ~= nil then
                FishGMF.refreshSeniorPropData(FishGI.myData.playerId,val,8,0)
            end
        end

        --播放特效
        for k,val in pairs(data.props) do
            local propTab = {}
            propTab.playerId = FishGI.myData.playerId
            propTab.propId = val.propId
            propTab.propCount = val.propCount
            propTab.isRefreshData = true
            propTab.isJump = false
            propTab.firstPos = self:getFirstPosByPropId(val.propId)
            propTab.dropType = "normal"
            propTab.isShowCount = false
            FishGI.GameEffect:playDropProp(propTab)
        end

        for k,val in pairs(data.seniorProps) do
            local propTab = {}
            propTab.playerId = FishGI.myData.playerId
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
    else
        FishGF.showToast(FishGF.getChByIndex(800000078))
    end

end

function InviteFriend:getFirstPosByPropId( propId,type )
    return cc.p(display.width/2,display.height/2)
end


return InviteFriend;