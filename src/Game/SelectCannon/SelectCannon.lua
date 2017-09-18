
local SelectCannon = class("SelectCannon", cc.load("mvc").ViewBase)

SelectCannon.AUTO_RESOLUTION   = false
SelectCannon.RESOURCE_FILENAME = "ui/battle/selectcannon/uiselectcannon"
SelectCannon.RESOURCE_BINDING  = {  
    ["panel"]       = { ["varname"] = "panel" },
    ["btn_close"]   = { ["varname"] = "btn_close" ,         ["events"]={["event"]="click",["method"]="onClickClose"}},   
    
    ["scroll_list"] = { ["varname"] = "scroll_list" ,       ["nodeType"]="viewlist"   },

}

function SelectCannon:onCreate( ... )
    --初始化
    self:init()

    -- 初始化View
    self:initView() 

    FishGI.eventDispatcher:registerCustomListener("changePlayerGun", self, function(valTab) self:changePlayerGun(valTab) end);

    FishGI.eventDispatcher:registerCustomListener("propCountChange", self, function(valTab) self:propCountChange(valTab) end);

    FishGI.eventDispatcher:registerCustomListener("onUsePropCannon", self, function(valTab) self:onUsePropCannon(valTab) end);

end

function SelectCannon:init()   
    self.panel:setSwallowTouches(false)

    self.cell_h_count = 4      -- 格子横向数
    self.cell_v_count = 1      -- 格子纵向数
    local cellCountSize = self.scroll_list:getContentSize()
    -- 计算出每个格子的宽高
    self.cellW = cellCountSize.width / self.cell_h_count
    self.cellH = cellCountSize.height / self.cell_v_count

    --添加触摸监听
    self:openTouchEventListener()
    
    self.scroll_list:setSwallowTouches(false)
    self.scroll_list:setScrollBarEnabled(false)
    self.gunCardArr = {}
end

function SelectCannon:initView()
    local vipTab = FishGI.GameTableData:getVipTable()
    local count = table.nums(vipTab)
    for i=1,count do
        local gunCard = self:createGunCardByVIP(i-1)
        self.gunCardArr[i] = gunCard
        gunCard:setPosition(cc.p(self.cellW/2 + self.cellW*(i - 1),self.cellH/2))
        self.scroll_list:addChild(gunCard)
    end

    self.allCount = count
    self.scroll_list:setInnerContainerSize(cc.size(self.cellW*(count), self.cellH))

end

function SelectCannon:createGunCardByVIP(vip)
    local propNode = require("Game/SelectCannon/GunCard").create()
    propNode:setItemData(vip)
    return propNode
end

function SelectCannon:onTouchBegan(touch, event)
    if self:isVisible() then
         return true  
    end

    return false
end
 
function SelectCannon:onClickClose( sender )
    self:hideLayer() 
end

function SelectCannon:upDataList(playerVIP)
    for k,gunCard in pairs(self.gunCardArr) do
        gunCard:setType(playerVIP)
        if gunCard.vip+1 == self.curGunType then
            gunCard:setCurUse(true)
        else
            gunCard:setCurUse(false)
        end
        gunCard:updateView()
    end
end

function SelectCannon:setCurGunType(playerVIP,curGunType)
    self.playerVIP = playerVIP
    self.curGunType = curGunType
    print("-----playerVIP="..playerVIP.."---curGunType="..curGunType)
    self:upDataList(self.playerVIP)
end

function SelectCannon:changePlayerGun(data)
    print("---changePlayerGun--")
    local playerId = data.playerId
    local newGunType = data.newGunType
    local isSuccess = data.isSuccess
    if not isSuccess then
        FishGF.print("---changePlayerGun--is-faill---")
        return
    end

    local player = FishGI.gameScene.playerManager:getPlayerByPlayerId(playerId)
    if player ~= nil then
        local gunType = newGunType
        player.cannon:gunChangeByData(gunType)
        player.playerInfo.gunType = newGunType
        --设置c++方面换炮
        FishGMF.setGunChange(playerId,gunType +930000000)
    end

    local selfId = FishGI.gameScene.playerManager.selfIndex
    if selfId == playerId then
        self:setCurGunType(self.playerVIP,newGunType)
        FishGI.myData.gunType = newGunType
    end
    
end

function SelectCannon:showLayer()
    self.super.showLayer(self)
    local per = (self.curGunType - 2.5)/(self.allCount - self.cell_h_count)*100
    if per < 0 then
        per = 0
    elseif per >100 then
        per = 100
    end
    self.scroll_list:jumpToPercentHorizontal(per)
end

function SelectCannon:propCountChange( data )
    local propId = data.propId
    if not FishGF.isLimitCannon( propId ) then
        return 
    end
    local seniorData = data.seniorData
    local data = FishGI.GameTableData:getItemTable(propId)
    local use_outlook = tonumber(data["use_outlook"])

    for k,v in pairs(self.gunCardArr) do
        if (v.vip + 1) == use_outlook then
            v:setIsCanTaste(true,seniorData)
            v:updateView()
        end
    end
end

--使用限时炮台
function SelectCannon:onUsePropCannon( netData )
    local isSuccess = netData.isSuccess
    local newCrystal = netData.newCrystal
    local useType = netData.useType
    local playerId = netData.playerID
    local propInfo = netData.propInfo

    if not isSuccess then
        print("---------used faile----------")
        return 
    end

    FishGMF.upDataByPropId(playerId,FishCD.PROP_TAG_02,newCrystal,true)

    FishGMF.refreshSeniorPropData(playerId,propInfo,1,0)

    --换炮身
    local data = FishGI.GameTableData:getItemTable(propInfo.propId)
    local use_outlook = tonumber(data["use_outlook"])
    if use_outlook < 0  then
        print("-----use_outlook < 0 --------")
        return 
    end
    self:hideLayer()
    --发送换炮消息
    FishGI.gameScene.net:sendNewGunType(use_outlook)
end


return SelectCannon;