
local Forged = class("Forged", cc.load("mvc").ViewBase)

Forged.AUTO_RESOLUTION   = false
Forged.RESOURCE_FILENAME = "ui/hall/forged/uiforged"
Forged.RESOURCE_BINDING  = {  
    ["panel"]                   = { ["varname"] = "panel" },
    ["btn_close"]               = { ["varname"] = "btn_close", ["events"]={["event"]="click",["method"]="onClickClose"}}, 
    ["img_update_text"]         = { ["varname"] = "img_update_text" },
    ["fnt_times"]               = { ["varname"] = "fnt_times" },
    ["spr_update_suc_text"]     = { ["varname"] = "spr_update_suc_text" },
    ["spr_gun"]                 = { ["varname"] = "spr_gun" },
    ["spr_gun_0"]               = { ["varname"] = "spr_gun_0" },
    ["fnt_gun_times"]           = { ["varname"] = "fnt_gun_times" },
    ["fnt_gun_times_0"]         = { ["varname"] = "fnt_gun_times_0" },
    ["fnt_gun_times_1"]         = { ["varname"] = "fnt_gun_times_1" },
    ["node_prop_1"]             = { ["varname"] = "node_prop_1" }, 
    ["node_prop_2"]             = { ["varname"] = "node_prop_2" },
    ["node_prop_3"]             = { ["varname"] = "node_prop_3" },
    ["node_prop_4"]             = { ["varname"] = "node_prop_4" },
    ["node_forged_info"]        = { ["varname"] = "node_forged_info" },
    ["spr_crystal_energy"]      = { ["varname"] = "spr_crystal_energy" },
    ["text_crystal_energy_tip"] = { ["varname"] = "text_crystal_energy_tip" },
    ["text_num_owns"]           = { ["varname"] = "text_num_owns" },
    ["text_num_need"]           = { ["varname"] = "text_num_need" },
    ["btn_hook_crystal_energy"] = { ["varname"] = "btn_hook_crystal_energy",   ["events"]={["event"]="click",["method"]="onClickOpenCrystalEnergy"} },
    ["spr_hook"]                = { ["varname"] = "spr_hook" },
    ["text_tip"]                = { ["varname"] = "text_tip" },
    ["btn_forged"]              = { ["varname"] = "btn_forged", ["events"]={["event"]="click",["method"]="onClickForged"}},
    ["spr_forged_title"]        = { ["varname"] = "spr_forged_title" },
    ["spr_forged_tip"]          = { ["varname"] = "spr_forged_tip" },
    ["fnt_forged_num"]          = { ["varname"] = "fnt_forged_num" },
    ["spr_prop_2"]              = { ["varname"] = "spr_prop_2" },
    ["text_finish_tip"]         = { ["varname"] = "text_finish_tip" },
}

function Forged:onCreate( ... )

    --初始化
    self:init()

    -- 初始化View
    self:initView() 

end

function Forged:init()   
    self.panel:setSwallowTouches(false)

    --添加触摸监听
    self:openTouchEventListener()

    --锻造进行中动画
    self.forgedingAni = false
    --锻造结果回调
    self.forgedResult = false
    
end

--初始化视图
function Forged:initView()
    self.spr_hook:setVisible(false)

    --锻造成功
    self.uiForgedSuccessLayer = require("hall/Forged/ForgedSuccess").create()
    self:addChild(self.uiForgedSuccessLayer,FishCD.ORDER_LAYER_TRUE)
    self.uiForgedSuccessLayer:setVisible(false)
    self.uiForgedSuccessLayer:setScale(self.scaleMin_)
    local function callback()
        self:setForgedBtnEnabled(true)
        self:updateMaxGunRateView(self.max_gun_rate == 10000)
    end
    self.uiForgedSuccessLayer:setCallBackClose(callback)

    self:runAction(self.resourceNode_["animation"])

    --是否勾选结晶能量
    self.is_open_crystal_energy = self.spr_hook and self.spr_hook:isVisible() or false
    --获取所有锻造倍数配置
    self.forgedDataTable = FishGMF.getForgedChangeData(920000029,920000046)
    --设置当前倍数
    self:setMaxGunRate(1000)
    self:updateMaxGunRateView(self.max_gun_rate == 10000)
end

function Forged:showLayer(isAct)
    self.super.showLayer(self,isAct)
    self.resourceNode_["animation"]:play("normal", true)
end

--点击关闭
function Forged:onClickClose( sender )
    if self.forgedingAni then
        return
    end
    self:hideLayer()
    self.resourceNode_["animation"]:pause()
end

--点击开启使用结晶能量
function Forged:onClickOpenCrystalEnergy( sender )
    self.is_open_crystal_energy = not self.is_open_crystal_energy
    self.spr_hook:setVisible(self.is_open_crystal_energy)
end

--点击锻造
function Forged:onClickForged( sender )
    if not self.isShow then
        return
    end
    
    if tonumber(self:getMyCrystal()) < tonumber(self.fnt_forged_num:getString()) then
        local function callback(sender)
            local tag = sender:getTag()
            if tag == 2 then
                self:hideLayer(false) 
                FishGI.hallScene.uiShopLayer:showLayer() 
                FishGI.hallScene.uiShopLayer:setShopType(1)
            end
        end
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,FishGF.getChByIndex(800000087),callback)
    elseif self:getPropItemCount(FishCD.PROP_TAG_07) < self:getPropItemNeedCount(FishCD.PROP_TAG_07) 
        or self:getPropItemCount(FishCD.PROP_TAG_08) < self:getPropItemNeedCount(FishCD.PROP_TAG_08) 
        or self:getPropItemCount(FishCD.PROP_TAG_09) < self:getPropItemNeedCount(FishCD.PROP_TAG_09) 
        or self:getPropItemCount(FishCD.PROP_TAG_10) < self:getPropItemNeedCount(FishCD.PROP_TAG_10) then
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000200),nil)
    elseif self.is_open_crystal_energy and self:getPropItemCount(FishCD.PROP_TAG_11) < self:getPropItemNeedCount(FishCD.PROP_TAG_11) then
        FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,FishGF.getChByIndex(800000202),nil)
    else
        self.forgedingAni = true
        self.btn_close:setEnabled(false)
        self:setForgedBtnEnabled(false)
        
        local frameEventCallFunc = function (frameEventName)
            if frameEventName:getEvent() == "forgeding_end" then
                self.forgedingAni = false
                if self.forgedResult then
                    self:onForgedResult()
                end
            end
        end
        self.resourceNode_["animation"]:play("forgeding", false)
        self.resourceNode_["animation"]:clearFrameEventCallFunc()
        self.resourceNode_["animation"]:setFrameEventCallFunc(frameEventCallFunc)
        FishGI.AudioControl:playEffect("sound/forged_forgeding.mp3")

        self:playPropItemsAni()

        self.curCrystalPower = FishGMF.getPlayerPropData(FishGI.myData.playerId,FishCD.PROP_TAG_11).realCount

        FishGMF.upDataByPropId(FishGI.myData.playerId,FishCD.PROP_TAG_07,
            self:getPropItemCount(FishCD.PROP_TAG_07)-self:getPropItemNeedCount(FishCD.PROP_TAG_07),true)
        FishGMF.upDataByPropId(FishGI.myData.playerId,FishCD.PROP_TAG_08,
            self:getPropItemCount(FishCD.PROP_TAG_08)-self:getPropItemNeedCount(FishCD.PROP_TAG_08),true)
        FishGMF.upDataByPropId(FishGI.myData.playerId,FishCD.PROP_TAG_09,
            self:getPropItemCount(FishCD.PROP_TAG_09)-self:getPropItemNeedCount(FishCD.PROP_TAG_09),true)
        FishGMF.upDataByPropId(FishGI.myData.playerId,FishCD.PROP_TAG_10,
            self:getPropItemCount(FishCD.PROP_TAG_10)-self:getPropItemNeedCount(FishCD.PROP_TAG_10),true)
        FishGMF.upDataByPropId(FishGI.myData.playerId,FishCD.PROP_TAG_02,self:getMyCrystal()-tonumber(self.forgedData.unlock_gem),true)
        if self.is_open_crystal_energy then
            FishGMF.upDataByPropId(FishGI.myData.playerId,FishCD.PROP_TAG_11,
                self:getPropItemCount(FishCD.PROP_TAG_11)-self:getPropItemNeedCount(FishCD.PROP_TAG_11),true)
        end
        FishGI.hallScene.net.roommanager:sendForgedReq(self.is_open_crystal_energy)
    end
end

function Forged:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false  
    end
    return true
end

function Forged:onTouchMoved(touch, event)
end

function Forged:onTouchEnded(touch, event) 
end

--初始化锻造材料道具数据
function Forged:initPropItemData(node, propId)
    local spr_prop_box_bg = node:getChildByName("spr_prop_box_bg")
    local spr_prop = spr_prop_box_bg:getChildByName("spr_prop")
    local node_prop_count = spr_prop_box_bg:getChildByName("node_prop_count")
    local text_num_owns = node_prop_count:getChildByName("text_num_owns")
    local text_num_need = node_prop_count:getChildByName("text_num_need")
    self.table_node[propId] = {}
    self.table_node[propId].node = node
    self.table_node[propId].node_prop_count = node_prop_count
    self.table_node[propId].text_num_owns = text_num_owns
    self.table_node[propId].text_num_need = text_num_need
    self.table_node[propId].data = {}
    self.table_node[propId].data.owns_count = 0
    self.table_node[propId].data.need_count = 0

    local pos = spr_prop:getPosition()
    local scale = spr_prop:getScale()
    local AnchorPoint = spr_prop:getAnchorPoint()
    spr_prop:initWithFile("common/prop/"..FishGI.GameTableData:getItemTable(propId).res);
    spr_prop:setAnchorPoint(AnchorPoint)
    spr_prop:setScale(scale)

    self:updatePropItemData(propId, 0)
end

--初始化锻造材料道具数据
function Forged:initPropItemsData()
    self.table_node = {}
    self:initPropItemData(self.node_prop_1, FishCD.PROP_TAG_07)
    self:initPropItemData(self.node_prop_2, FishCD.PROP_TAG_08)
    self:initPropItemData(self.node_prop_3, FishCD.PROP_TAG_09)
    self:initPropItemData(self.node_prop_4, FishCD.PROP_TAG_10)
    self:initCrystalEnergyData()
end

--初始化结晶能量数据
function Forged:initCrystalEnergyData()
    local pos = self.spr_crystal_energy:getPosition()
    local scale = self.spr_crystal_energy:getScale()
    local AnchorPoint = self.spr_crystal_energy:getAnchorPoint()
    self.spr_crystal_energy:initWithFile("common/prop/"..FishGI.GameTableData:getItemTable(11).res);
    self.spr_crystal_energy:setAnchorPoint(AnchorPoint)
    self.spr_crystal_energy:setScale(scale)

    self.text_crystal_energy_tip:setString(FishGF.getChByIndex(800000203))
    self.text_tip:setString(FishGF.getChByIndex(800000204))
    self.text_finish_tip:setString(FishGF.getChByIndex(800000217))

    self.table_node[FishCD.PROP_TAG_11] = {}
    self.table_node[FishCD.PROP_TAG_11].node = node
    self.table_node[FishCD.PROP_TAG_11].text_num_owns = self.text_num_owns
    self.table_node[FishCD.PROP_TAG_11].text_num_need = self.text_num_need
    self.table_node[FishCD.PROP_TAG_11].data = {}
    self.table_node[FishCD.PROP_TAG_11].data.owns_count = 0
    self.table_node[FishCD.PROP_TAG_11].data.need_count = 0

    self:updateCrystalEnergyData(0)
end

--更新锻造材料道具数据
function Forged:updatePropItemData(propId, owns_count)
    if self.table_node[propId] == nil then
        return
    end
    if owns_count ~= nil then
        self:setPropItemCount(propId, owns_count)
    end
    self:setPropItemNeedCount(propId, tonumber(self.forgedData.unlock_item[tostring(propId)]))
    if self.table_node[propId].text_num_owns then
        if self:getPropItemCount(propId) < self:getPropItemNeedCount(propId) then
            self.table_node[propId].text_num_owns:setColor(cc.c3b(253, 85, 38))
        else
            self.table_node[propId].text_num_owns:setColor(cc.c3b(11, 255, 1))
        end
    end
end

--更新结晶能量数据
function Forged:updateCrystalEnergyData(owns_count)
    if self.table_node[FishCD.PROP_TAG_11] == nil then
        return
    end
    if owns_count ~= nil then
        self:setPropItemCount(FishCD.PROP_TAG_11, owns_count)
    end
    self:setPropItemNeedCount(FishCD.PROP_TAG_11, tonumber(self.forgedData.succ_need))
end

--更新道具数据
function Forged:updatePropData(propId, owns_count)
    if propId == FishCD.PROP_TAG_11 then
        self:updateCrystalEnergyData(owns_count)
    else
        self:updatePropItemData(propId, owns_count)
    end
end

--更新道具数据
function Forged:updatePropItemsData()
    self:updatePropItemData(FishCD.PROP_TAG_07)
    self:updatePropItemData(FishCD.PROP_TAG_08)
    self:updatePropItemData(FishCD.PROP_TAG_09)
    self:updatePropItemData(FishCD.PROP_TAG_10)
    self:updateCrystalEnergyData()
end

--设置道具个数
function Forged:setPropItemCount(propId, showCount)
    if self.table_node[propId] == nil then
        return
    end
    self.table_node[propId].data.owns_count = showCount
    if self.table_node[propId].text_num_owns then
        self.table_node[propId].text_num_owns:setString(tostring(showCount))
    end
end

--获取道具个数
function Forged:getPropItemCount(propId)
    if self.table_node[propId] == nil then
        return 0
    end
    return self.table_node[propId].data.owns_count
end

--设置道具实际需要个数
function Forged:setPropItemNeedCount(propId, showCount)
    if self.table_node[propId] == nil then
        return
    end
    self.table_node[propId].data.need_count = showCount
    if self.table_node[propId].text_num_need then
        self.table_node[propId].text_num_need:setString(tostring(showCount))
    end
end

--获取道具实际需要个数
function Forged:getPropItemNeedCount(propId)
    if self.table_node[propId] == nil then
        return 0
    end
    return self.table_node[propId].data.need_count
end

--设置水晶个数
function Forged:setMyCrystal( crystal )
    self.crystal = crystal
end

--获取水晶个数
function Forged:getMyCrystal( crystal )
    return self.crystal
end

--设置vip
function Forged:setVIPLevel( vip_level )
    self.vip_level = vip_level
    local strGunImg = FishGI.GameTableData:getGunOutlookTableByVip(vip_level).cannon_img
    local strGumImg = string.format("battle/cannon/%s", strGunImg)
    self.spr_gun:initWithFile(strGumImg)
    self.spr_gun_0:initWithFile(strGumImg)
    self.uiForgedSuccessLayer:setVIPLevel(vip_level)
end

--获取vip
function Forged:getVIPLevel( vip_level)
    self.vip_level = vip_level
end

--设置当前炮倍及更新界面
function Forged:setMaxGunRate( max_gun_rate )
    local bInit = false
    if self.max_gun_rate == nil  then
        bInit = true
    elseif self.max_gun_rate == max_gun_rate then
        return
    end
    if max_gun_rate < 1000 then
        max_gun_rate = 1000
    elseif max_gun_rate > 10000 then
        max_gun_rate = 10000
    else
        local rate = max_gun_rate / 500
        if math.ceil(rate) ~= rate then
            rate = math.ceil(rate) - 1
        end
        max_gun_rate = 500 * rate
    end
    self.max_gun_rate = max_gun_rate

    local newGunRate = self.max_gun_rate
    local isMaxGunRate = false
    if self.max_gun_rate == 10000 then
        self:setForgedBtnEnabled(false)
        isMaxGunRate = true
    else
        newGunRate = newGunRate + 500
    end
    self.fnt_gun_times:setString(tostring(self.max_gun_rate))
    self.fnt_gun_times_0:setString(tostring(self.max_gun_rate))
    self.fnt_gun_times_1:setString(tostring(self.max_gun_rate))
    self.fnt_times:setString(tostring(newGunRate))
    self.forgedData = self.forgedDataTable[tostring(newGunRate)]
    if bInit == true then
        self:initPropItemsData()
    else
        self:updatePropItemsData()
    end
    self.fnt_forged_num:setString(self.forgedData.unlock_gem)
end

--判断是否符合锻造条件
function Forged:checkIfForged( )
    if tonumber(self:getMyCrystal()) < tonumber(self.fnt_forged_num:getString()) then
        return false
    elseif self:getPropItemCount(FishCD.PROP_TAG_07) < self:getPropItemNeedCount(FishCD.PROP_TAG_07) 
        or self:getPropItemCount(FishCD.PROP_TAG_08) < self:getPropItemNeedCount(FishCD.PROP_TAG_08) 
        or self:getPropItemCount(FishCD.PROP_TAG_09) < self:getPropItemNeedCount(FishCD.PROP_TAG_09) 
        or self:getPropItemCount(FishCD.PROP_TAG_10) < self:getPropItemNeedCount(FishCD.PROP_TAG_10) then
        return false
    elseif self.max_gun_rate < 1000 or self.max_gun_rate >= 10000 then
        return false
    else
        return true
    end
end

--锻造结果
function Forged:onForgedResult( data )
    self.forgedResult = true
    if data then
        self.forgedResultData = data
    end
    if self.forgedingAni or self.forgedResultData == nil then
        return
    end

    local isSuccess = self.forgedResultData.isSuccess
    local newCrystalPower = self.forgedResultData.newCrystalPower
    local newGunRate = self.forgedResultData.newGunRate

    self.forgedResult = false
    self.forgedResultData = nil

    local function updateViewDatas()
        FishGMF.upDataByPropId(FishGI.myData.playerId,FishCD.PROP_TAG_11,newCrystalPower,true)
    end

    self:playPropItemsAni(false)
    if isSuccess then
        self:setMaxGunRate(newGunRate)
        FishGI.myData.maxGunRate = newGunRate
        FishGI.AudioControl:playEffect("sound/forged_success.mp3")
        local frameEventCallFunc = function (frameEventName)
            if frameEventName:getEvent() == "success_end" then
                self.btn_close:setEnabled(true)
                self.resourceNode_["animation"]:play("normal", true)
                self.resourceNode_["animation"]:clearFrameEventCallFunc()
                self.uiForgedSuccessLayer:showLayer(false)
                self.uiForgedSuccessLayer:setGunRate(newGunRate)
                updateViewDatas()
            end
        end
        self.resourceNode_["animation"]:play("success", false)
        self.resourceNode_["animation"]:clearFrameEventCallFunc()
        self.resourceNode_["animation"]:setFrameEventCallFunc(frameEventCallFunc)
    else
        FishGI.AudioControl:playEffect("sound/forged_fail.mp3")
        local frameEventCallFunc = function (frameEventName)
            if frameEventName:getEvent() == "fail_end" then
                self.btn_close:setEnabled(true)
                self.resourceNode_["animation"]:play("normal", true)
                self.resourceNode_["animation"]:clearFrameEventCallFunc()
                local function callback(sender)
                    local tag = sender:getTag()
                    if tag == 1 then
                        self:setForgedBtnEnabled(true)
                    end
                end
                local str = string.format(FishGF.getChByIndex(800000201), tostring(newCrystalPower-self.curCrystalPower))
                FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_ONLY,str,callback)
                updateViewDatas()
            end
        end
        self.resourceNode_["animation"]:play("fail", false)
        self.resourceNode_["animation"]:clearFrameEventCallFunc()
        self.resourceNode_["animation"]:setFrameEventCallFunc(frameEventCallFunc)
    end
    
end

--设置锻造按钮禁用状态
function Forged:setForgedBtnEnabled( bEnabled )
    if self.max_gun_rate == 10000 then
        bEnabled = false
    end
    self.btn_hook_crystal_energy:setEnabled(bEnabled)
    self.btn_forged:setEnabled(bEnabled)
    self.spr_forged_title:setVisible(bEnabled)
    self.spr_forged_tip:setVisible(bEnabled)
    self.spr_prop_2:setVisible(bEnabled)
end

--根据是否最高炮倍更新界面
function Forged:updateMaxGunRateView( isMaxGunRate )
    self.table_node[FishCD.PROP_TAG_07].node_prop_count:setVisible(not isMaxGunRate)
    self.table_node[FishCD.PROP_TAG_08].node_prop_count:setVisible(not isMaxGunRate)
    self.table_node[FishCD.PROP_TAG_09].node_prop_count:setVisible(not isMaxGunRate)
    self.table_node[FishCD.PROP_TAG_10].node_prop_count:setVisible(not isMaxGunRate)
    self.img_update_text:setVisible(not isMaxGunRate)
    self.spr_update_suc_text:setVisible(isMaxGunRate)
    self.node_forged_info:setVisible(not isMaxGunRate)
    self.text_finish_tip:setVisible(isMaxGunRate)
end

--播放道具动画
function Forged:playPropItemAni( propId, isPlay )
    if propId == nil or self.table_node[propId] == nil then
        return
    end
    if isPlay == nil then
        isPlay = true
    end
    if isPlay then
        self.table_node[propId].node["animation"]:play("forgeding", true)
    else
        self.table_node[propId].node["animation"]:stop()
    end
end

--播放道具动画
function Forged:playPropItemsAni( isPlay )
    self:playPropItemAni(FishCD.PROP_TAG_07, isPlay)
    self:playPropItemAni(FishCD.PROP_TAG_08, isPlay)
    self:playPropItemAni(FishCD.PROP_TAG_09, isPlay)
    self:playPropItemAni(FishCD.PROP_TAG_10, isPlay)
end

return Forged;