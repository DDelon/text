
local Monthcard = class("Monthcard", cc.load("mvc").ViewBase)

Monthcard.AUTO_RESOLUTION   = false
Monthcard.RESOURCE_FILENAME = "ui/hall/uimonthcard"
Monthcard.RESOURCE_BINDING  = {  
    ["panel"]         = { ["varname"] = "panel" },
    ["btn_close"]     = { ["varname"] = "btn_close" ,         ["events"]={["event"]="click",["method"]="onClickClose"}},   
    
    ["btn_threetype"] = { ["varname"] = "btn_threetype" ,     ["events"]={["event"]="click",["method"]="onClickByType"}},   
    ["spr_word_1"]    = { ["varname"] = "spr_word_1" },
    ["spr_word_2"]    = { ["varname"] = "spr_word_2" },
    ["spr_word_3"]    = { ["varname"] = "spr_word_3" },
    ["fnt_daynum"]    = { ["varname"] = "fnt_daynum" },

    ["node_leave"]    = { ["varname"] = "node_leave" },
}

function Monthcard:onCreate( ... )
    self:openTouchEventListener()
    
    self:initView()
    --1，购买   2，领取    3，剩余次数
    self.showType = 1
    self.unit = "月卡";
    self.monthCardId = 830000015;
    self.recharge = FishGI.GameConfig:getConfigData("recharge", tostring(self.monthCardId), "recharge");
    self.recharge_type = tonumber(FishGI.GameConfig:getConfigData("recharge", tostring(self.monthCardId), "recharge_type"));

    self:setShowType(1)
end

--初始化奖品
function Monthcard:initView()
    local data = FishGI.GameConfig:getConfigData("config", tostring(990000032), "data");
    local vatTab = string.split(data,";")
    local resultTab = {}
    for i=0,#vatTab do
        if vatTab[i] == nil then
            vatTab[i] = "0,0"
        end
        local tab = string.split(vatTab[i],",")
        local prop = {}
        prop.propId = tonumber(tab[1])
        prop.propCount = tonumber(tab[2])
        table.insert(resultTab,prop)
    end

    self.rewardTab = {}
    for i,val in ipairs(resultTab) do
        local node = self:child("image_prop_"..(i-1))
        if node == nil then
            return 
        end
        local propId = val.propId
        local spr_prop = node:getChildByName("spr_prop")
        local spr_name = node:getChildByName("spr_name")

        local sprFile = string.format("hall/monthcard/monthcard_pic_%d.png",(propId+1))
        local result = spr_prop:initWithFile(sprFile)
        if not result then
            print("----------result == false-----")
            sprFile = string.format("common/prop/prop_%03d.png",(propId))
            spr_prop:initWithFile(sprFile)
        end

        local spr_name_path = string.format("hall/monthcard/monthcard_pic_name_%d.png",(propId))
        spr_name:initWithFile(spr_name_path)

        self.rewardTab[propId] = node
    end
end

function Monthcard:onTouchBegan(touch, event)
    if self:isVisible() then
         return true  
    end

    return false
end

function Monthcard:onClickClose( sender )
    self:hideLayer() 
end

function Monthcard:onClickByType( sender )

    if self.showType == 1 then
        local data = {}
        data["id"] = self.monthCardId;
        data["goods"] = self.monthCardId;
        data["name"] = self.unit;
        data["body"] = self.unit.." "..self.monthCardId.." x1";
        data["money"] = self.recharge;
        data["price"] = self.recharge/100;
        data["type"] = tonumber(self.recharge_type);
        data["autobuy"] = 1;
        data["subject"] = self.unit;
        data["ingame"] = 1;
        data["roomid"] = 0;
        data["count"] = 1;
        data["debug"] = 0;
        data["udid"] = Helper.GetDeviceCode()
        data["uiObj"] = self;
        FishGI.payHelper:doPay(data);
    elseif self.showType == 2 then
        FishGI.hallScene.net.roommanager:sendGetMonthCard();
        self.btn_threetype:setTouchEnabled(false)
        if FishGI.GAME_STATE == 3 then
            self:hideLayer() 
        end
    elseif self.showType == 3 then
        FishGF.showSystemTip(nil,800000172,1);
    end

end

function Monthcard:setShowType( showType )
    self.showType = showType

    self.node_leave:setVisible(false)
    for i=1,3 do
        self["spr_word_"..i]:setVisible(false)
    end

    self["spr_word_"..self.showType]:setVisible(true)
    if showType == 3 then
        self.btn_threetype:setVisible(false)
        self.node_leave:setVisible(true)
    end

end

function Monthcard:setLeftMonthCardDay( leftMonthCardDay ,monthCardRewardToken)
    if leftMonthCardDay == nil or monthCardRewardToken == nil then
        return
    end
    self.leftMonthCardDay = leftMonthCardDay
--    print("-----leftMonthCardDay="..leftMonthCardDay)
    local showType = nil
    if leftMonthCardDay <= 0 then
        showType = 1
        FishGI.isGetMonthCard = false
    elseif monthCardRewardToken then
        showType = 3
        FishGI.isGetMonthCard = true
        self.fnt_daynum:setString(leftMonthCardDay-1)
    else
        FishGI.isGetMonthCard = true
        self.fnt_daynum:setString(leftMonthCardDay-1)
        showType = 2 
    end
    self:setShowType(showType)

end

--月卡领取回调
function Monthcard:getMonthCardReward( data )
    local isSuccess = data.isSuccess
    local rewardItems = data.rewardItems
    local seniorProps = data.seniorProps
    if isSuccess then
        FishGI.AudioControl:playEffect("sound/congrat_01.mp3",false)
        self:setShowType(3)
        FishGF.showSystemTip(nil,800000156,2);
    end
    self.btn_threetype:setTouchEnabled(true)

    local playerId = FishGI.myData.playerId
    --普通道具
    for k,val in pairs(rewardItems) do
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

    self:hideLayer()

end

--得到飞行道具的初始位置
function Monthcard:getFirstPosByPropId( propId )
    local child = self.rewardTab[propId]
    if child == nil then
        return nil
    end 
    local spr = child:getChildByName("spr_prop")
    local pos = cc.p(spr:getPositionX(),spr:getPositionY())
    pos = child:convertToWorldSpace(pos)

    return pos
end

return Monthcard;