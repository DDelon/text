local DialCommon = class("DialCommon", cc.load("mvc").ViewBase)

DialCommon.AUTO_RESOLUTION   = false
DialCommon.RESOURCE_FILENAME = "ui/hall/dial/uidialcommon"
DialCommon.RESOURCE_BINDING  = {    
    ["panel"]         = { ["varname"] = "panel" },
    ["node_dial"]     = { ["varname"] = "node_dial"  },
    
    ["node_light_1"]  = { ["varname"] = "node_light_1"  },
    ["node_light_2"]  = { ["varname"] = "node_light_2"  },
    ["btn_click"]     = { ["varname"] = "btn_click" ,      ["events"]={["event"]="click",["method"]="onClickStartUse"}},
    
    ["text_notice"]   = { ["varname"] = "text_notice"  },
    ["node_front"]    = { ["varname"] = "node_front"  },

    ["spr_cur_award"] = { ["varname"] = "spr_cur_award"  },
    
}

function DialCommon:onCreate( ... )
    self:openTouchEventListener()
    
    self.animation = self.resourceNode_["animation"]
    self:runAction(self.animation)
    --self.spr_cur_award:setVisible(false)
    self.text_notice:setString(FishGF.getChByIndex(800000114))
    self.node_light_1:setVisible(true)
    self.node_light_2:setVisible(true)
    --灯泡闪动
    FishGI.GameEffect.lampBlink( self.node_light_1,0 )
    FishGI.GameEffect.lampBlink( self.node_light_2,0.5 )

    local keyID = tostring(990000036)
    local data = tostring(FishGI.GameConfig:getConfigData("config", keyID, "data"));
    self.rewardData = {}
    self.rewardData = FishGF.strToVec3(data..";")

    local count = #(self.node_dial:getChildren())-1
    self.node_dial.angleCell = 360/count
    self:initLayer()

end

function DialCommon:initLayer(  )
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
    spr_word_click_1:setVisible(true)
    spr_word_click_2:setVisible(false)

end

function DialCommon:onTouchBegan(touch, event) 
    if self:isVisible() == true then
        if self.btn_click:isTouchEnabled() then
            self:startRotate()
        end
        return true
    end   
    return false
end

function DialCommon:onClickStartUse( sender )
    print("-----onClickStartUse-")
--    FishGI.AudioControl:playEffect("sound/com_btn01.mp3")
    self:startRotate()
end

function DialCommon:startRotate( )
    --发送抽奖消息
    if FishGI.hallScene.net.roommanager == nil then
        return 
    end
    --self.animation:play("getaward",false)
    -- print("-----startRotate-")
    self.btn_click:setTouchEnabled(false)
    local spr_word_click_1 = self.btn_click:getChildByName("spr_word_click_1")
    local spr_word_click_2 = self.btn_click:getChildByName("spr_word_click_2")
    spr_word_click_1:setVisible(false)
    spr_word_click_2:setVisible(true)
    --发送抽奖消息
    if FishGI.hallScene.net.roommanager ~= nil then
        FishGI.hallScene.net.roommanager:sendLoginDraw();
    end
    
end

function DialCommon:endRotate( valTabData)
    print("-----endRotate-")
    local isSuccess = valTabData.isSuccess
    local propId = 0
    local propCount = 0

    if valTabData.props == nil then
        valTabData.props = {}
    end
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
    local vip_level = valTabData.vip_level
    local checkin_rate = FishGI.GameTableData:getVipTable(vip_level).checkin_rate
    self:setDialEnd(false)
    local curId = nil
    for i=1,#rewardData do
        local data =rewardData[i]
        if data.x == propId and data.y == propCount/checkin_rate then
            curId = i
            break
        end
    end
    
    if isSuccess == false or curId == nil then
        print("-------curId == nil-----")
        self:hideLayer()
        FishGF.createCloseSocketNotice(FishGF.getChByIndex(800000174),"DialCommon")
        return
    end


    FishGI.myData.loginDrawUsed = true
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

function DialCommon:setDialEnd( isEnd)
    self.isEnd = isEnd
end

function DialCommon:initDialAge( )
    self.node_dial:stopAllActions()
    if self.node_dial.rollingID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.node_dial.rollingID )
    end
    self.btn_click:setTouchEnabled(true)
    self.node_dial:setRotation(0)
    self.spr_cur_award:setVisible(false)
end

return DialCommon;