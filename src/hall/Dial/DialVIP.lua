local DialVIP = class("DialVIP", cc.load("mvc").ViewBase)

DialVIP.AUTO_RESOLUTION   = false
DialVIP.RESOURCE_FILENAME = "ui/hall/dial/uidialvip"
DialVIP.RESOURCE_BINDING  = {    
    ["panel"]         = { ["varname"] = "panel" },
    ["node_dial"]     = { ["varname"] = "node_dial"  },
    
    ["node_light_1"]  = { ["varname"] = "node_light_1"  },
    ["node_light_2"]  = { ["varname"] = "node_light_2"  },
    ["btn_click"]     = { ["varname"] = "btn_click" ,      ["events"]={["event"]="click",["method"]="onClickStartUse"}},
    
    ["text_notice"]   = { ["varname"] = "text_notice"  },
    ["fnt_money"]     = { ["varname"] = "fnt_money"  },
    
    ["btn_close"]     = { ["varname"] = "btn_close" ,         ["events"]={["event"]="click",["method"]="onClickClose"}},   
    
    ["spr_cur_award"] = { ["varname"] = "spr_cur_award"  },
    

}

function DialVIP:onCreate( ... )
    self.name = "DialVIP"
    self:openTouchEventListener()    

    self.animation = self.resourceNode_["animation"]
    self:runAction(self.animation)
    self.spr_cur_award:setVisible(false)
    self.text_notice:setString(FishGF.getChByIndex(800000114))
    self.costMoney = tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000041), "data"));
    self.fnt_money:setString(self.costMoney/10000)
    self.vip = 0

    self.node_light_1:setVisible(true)
    self.node_light_2:setVisible(true)
    --灯泡闪动
    FishGI.GameEffect.lampBlink( self.node_light_1,0 )
    FishGI.GameEffect.lampBlink( self.node_light_2,0.5 )

    local keyID = tostring(990000037)
    local data = tostring(FishGI.GameConfig:getConfigData("config", keyID, "data"));
    self.rewardData = {}
    self.rewardData = FishGF.strToVec3(data..";")

    local count = #(self.node_dial:getChildren())-1
    self.node_dial.angleCell = 360/count
    self:initLayer()

end

function DialVIP:initLayer(  )
    local rewardData = self.rewardData
    for i=1,#rewardData do
        local data =rewardData[i] 
        local child = self.node_dial:getChildByName("node_dialitem_"..i)
        local fnt_count = child:getChildByName("fnt_count")
        local spr_prop = child:getChildByName("spr_prop")
        fnt_count:setString(FishGF.changePropUnitByID(data.x,data.y,false))
        local namefile = string.format("common/prop/prop_%03d.png",data.x)
        spr_prop:initWithFile(namefile)
    end
    
    local spr_word_click_1 = self.btn_click:getChildByName("spr_word_click_1")
    local spr_word_click_2 = self.btn_click:getChildByName("spr_word_click_2")
    spr_word_click_1:setVisible(false)
    spr_word_click_2:setVisible(true)
end

function DialVIP:onClickClose( sender )
    self:hideLayer()
    FishGI.hallScene:isShowShareEnd()
end

function DialVIP:onTouchBegan(touch, event) 
    if self:isVisible() == true then
        return true
    end   
    return false
end

function DialVIP:onClickStartUse( sender )
    print("-----onClickStartUse-")

    if self.leftCount <= 0  then
        FishGF.showSystemTip(nil,800000155,1);
        return
    end

    local isNoticeVipDailCost = FishGI.isNoticeVipDailCost
    if isNoticeVipDailCost then
        local function callback(sender)
            local tag = sender:getTag()
            print("---showMessageLayer--tag="..tag)
            if tag == 2 then
                self:startRotate()
                FishGI.isNoticeVipDailCost = isNoticeVipDailCost
            elseif tag == 4 then
                isNoticeVipDailCost = not isNoticeVipDailCost
                sender:getChildByName("spr_hook"):setVisible(not isNoticeVipDailCost)
            end
        end
        local str = FishGF.getChByIndex(800000119)..self.costMoney..FishGF.getChByIndex(800000098)
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE_HOOK,str,callback)
        return
    end

    self:startRotate()
end

function DialVIP:startRotate( )
    if self.fishCoin < self.costMoney then
        print("---DialVIP--goto congzhi-self.fishCoin="..self.fishCoin.."--self.costMoney="..self.costMoney)
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then
                print("---DialVIP--goto congzhi-")
                self:hideLayer(false) 
                FishGI.hallScene.uiShopLayer:showLayer() 
                FishGI.hallScene.uiShopLayer:setShopType(1)
            end
        end
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000129),callback)
        return
    end

    print("-----startRotate-")
    
    --self.btn_click:setBright(false)
    local spr_word_click_1 = self.btn_click:getChildByName("spr_word_click_1")
    local spr_word_click_2 = self.btn_click:getChildByName("spr_word_click_2")
    spr_word_click_1:setVisible(false)
    spr_word_click_2:setVisible(true)

    FishGMF.setAddFlyProp(FishGI.myData.playerId,1,self.costMoney,false)
    --发送抽奖消息
    FishGI.hallScene.net.roommanager:sendVipLoginDraw();

    self:setDialEnd(false)
end

--通过全局的自己数据更新界面
function DialVIP:upDataVIPData()
    self:setPlayerCoin(FishGI.myData.fishIcon)
    self:setVIPData(FishGI.myData.vip_level,FishGI.myData.extra_sign)
    self:setUsedCount(FishGI.myData.vipDrawCountUsed)

end

function DialVIP:setVIPData( vip_level,allCount)
    self.vip_level = vip_level
    self.allCount = FishGI.GameTableData:getVipTable(vip_level).extra_sign
end

function DialVIP:setUsedCount( UsedCount)
--    print("-----setUsedCount-UsedCount="..UsedCount)
    self.UsedCount = UsedCount
    self.leftCount = self.allCount - self.UsedCount
    self.text_notice:setString(FishGF.getChByIndex(800000116)..self.vip_level..FishGF.getChByIndex(800000117)..(self.allCount - self.UsedCount)..FishGF.getChByIndex(800000118))

end

function DialVIP:setPlayerCoin( fishCoin)
    self.fishCoin = fishCoin
end

function DialVIP:endRotate( valTabData)
    print("-----endRotate-")
    local countUsed = valTabData.countUsed
    self:setUsedCount(countUsed)

    local isSuccess = valTabData.isSuccess
    local propId = 0
    local propCount = 0

    for k,val in pairs(valTabData.props) do
        if val ~= nil and val.propId ~= nil then
            propId = val.propId
            propCount = val.propCount
        end
    end

    if valTabData.seniorProps == nil then
        valTabData.seniorProps = {}
    end
    for k,val in pairs(valTabData.seniorProps) do
        if val ~= nil and val.propId ~= nil then
            propId = val.propId
            propCount = propCount + 1
        end
    end

    local rewardData = self.rewardData
    local curId = nil
    for i=1,#rewardData do
        local data =rewardData[i]
        if data.x == propId and data.y == propCount then
            curId = i
            break
        end
    end

    if isSuccess == false or curId == nil then
        FishGMF.setAddFlyProp(FishGI.myData.playerId,1,self.costMoney,true)
        print("-------curId == nil-----")
        self:hideLayer()
        FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000174),"DialVIP")
        return
    end

    --抽奖成功，更新数据
    FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,1,-self.costMoney,false)
    FishGMF.setAddFlyProp(FishGI.myData.playerId,1,self.costMoney,true)

    for k,val in pairs(valTabData.props) do
        if val ~= nil and val.propId ~= nil then
            FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,val.propId,val.propCount,false)
            FishGMF.setAddFlyProp(FishGI.myData.playerId,val.propId,val.propCount,false)
        end
    end

    for k,val in pairs(valTabData.seniorProps) do
        if val ~= nil and val.propId ~= nil then
            FishGMF.refreshSeniorPropData(FishGI.myData.playerId,val,8,0)
        end
    end

    valTabData.playerId = FishGI.myData.playerId
    valTabData.propId = propId
    valTabData.propCount = propCount
    local endRotate = 360 - (curId - 1)*self.node_dial.angleCell
    FishGI.GameEffect.startRotateByEndRotate(self,self.node_dial,endRotate,valTabData)

end

function DialVIP:setDialEnd( isEnd)
    self.btn_click:setTouchEnabled(isEnd)
    -- self.isEnd = isEnd
    -- if self.isEnd then
    --     self.btn_click:setTouchEnabled(true)
    -- end
    self.btn_close:setTouchEnabled(isEnd)
end

function DialVIP:initDialAge( )
    self.node_dial:stopAllActions()
    if self.node_dial.rollingID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.node_dial.rollingID )
    end
    self:setDialEnd(true)
    self.node_dial:setRotation(0)
    self.spr_cur_award:setVisible(false)
end

return DialVIP;