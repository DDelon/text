local GameTableData = class("GameTableData",nil)

GameTableData.gameTableList  = {  
    { ["tableName"] = "item",           ["tableDataName"] = "itemAllData",      ["clearType"] = 0}, 
    { ["tableName"] = "vip",            ["tableDataName"] = "vipTab",           ["clearType"] = 0},
    { ["tableName"] = "cannonoutlook",  ["tableDataName"] = "cannonoutlookTab", ["clearType"] = 0},
    { ["tableName"] = "recharge",       ["tableDataName"] = "rechargeTab",      ["clearType"] = 0},
    { ["tableName"] = "task",           ["tableDataName"] = "taskTab",          ["clearType"] = 0},

    { ["tableName"] = "skill",          ["tableDataName"] = "skillTab",         ["clearType"] = 2}, 
    { ["tableName"] = "newtask",        ["tableDataName"] = "newtaskTab",       ["clearType"] = 2}, 
    { ["tableName"] = "reward",         ["tableDataName"] = "rewardTab",        ["clearType"] = 2},
    { ["tableName"] = "roomfish",       ["tableDataName"] = "roomfishTab",      ["clearType"] = 2},

}

function GameTableData.create()
    local data = GameTableData.new();
    data:init();
    return data;
end

function GameTableData:init()

end

--清除游戏数据 0 公用数据，1 大厅，2 普通场， 3 朋友场
function GameTableData:clearGameTable(NoClearIndex)
    for k,v in pairs(self.gameTableList) do
        if v.clearType ~= 0 and v.clearType ~= NoClearIndex then
            self[v.tableDataName] = nil
        end
    end
end

--得到鱼表
function GameTableData:getRoomfishTable(roomId)
    local back = FishGMF.getTableByName("roomfish")
    local resultMap = {}
    roomId = tonumber(roomId) + 910000000
    for k,v in pairs(back) do
        if tonumber(v.room_id) == roomId then
            if v.show_score == nil or v.show_score == "" then
                v.show_score = 0
            end
            v.id = tonumber(v.id)
            v.room_id = tonumber(v.room_id)
            v.fish_id = tonumber(v.fish_id)
            v.show_score = tonumber(v.show_score)
            v.fish_type = tonumber(v.fish_type)
            table.insert( resultMap,v )
        end
    end
    FishGF.sortByKey(resultMap,"id",1)
    return resultMap
end

--得到等級
function GameTableData:getLVByExp(gradeExp)
    local dataTab = {}
    dataTab.funName = "getLVByExp"
    dataTab.gradeExp = gradeExp
    local gradeData = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
    return gradeData
end

--日常任务数据
function GameTableData:initTaskTable()
    local back = FishGMF.getTableByName("task")
    self.taskTab = back
end
function GameTableData:getTaskTable(index)
    if self.taskTab == nil then
        self:initTaskTable()
    end
    if index == nil then
        return self.taskTab
    end
    index = tonumber(index)
    return self.taskTab[index]
end

--商店道具数据
function GameTableData:initRechargeTable()
    local back = FishGMF.getTableByName("recharge")
    self.rechargeTab = {}
    for k,v in pairs(back) do
        v.recharge_type = tonumber(v.recharge_type)
        if self.rechargeTab[v.recharge_type] == nil then
            self.rechargeTab[v.recharge_type] = {}
        end
        v.id = tonumber(v.id)
        v.recharge = tonumber(v.recharge)
        v.recharge_num = tonumber(v.recharge_num)
        v.gift_num = tonumber(v.gift_num)
        v.recharge_method = tonumber(v.recharge_method)
        v.frist_change_enable = tonumber(v.frist_change_enable)
        table.insert( self.rechargeTab[v.recharge_type],v)
    end

    --将除了鱼币水晶外的道具加入这2个列表中
    for k,v in pairs(self.rechargeTab) do
        local recharge_type = v.recharge_type
        if k ~= 1 and k ~= 2 then
            for k2,v2 in pairs(v) do
                table.insert( self.rechargeTab[1],v2)
                table.insert( self.rechargeTab[2],v2)
            end
        end
    end

    for k,v in pairs(self.rechargeTab) do
        FishGF.sortByKey(v,"recharge_num",1)
    end

    local a = 1
end
function GameTableData:getRechargeTable(index)
    if self.rechargeTab == nil then
        self:initRechargeTable()
    end
    if index == nil then
        return self.rechargeTab
    end
    index = tonumber(index)
    return self.rechargeTab[index]
end

--炮类型数据
function GameTableData:initCannonoutlookTable()
    local back = FishGMF.getTableByName("cannonoutlook")
    self.cannonoutlookTab = {}
    for k,v in pairs(back) do
        v.id = tonumber(v.id)
        v.type = tonumber(v.type)
        v.net_radius = tonumber(v.net_radius)
        self.cannonoutlookTab[v.type] = v
    end
end
function GameTableData:getCannonoutlookTable(index)
    if self.cannonoutlookTab == nil then
        self:initCannonoutlookTable()
    end
    if index == nil then
        return self.cannonoutlookTab
    end
    index = tonumber(index)
    return self.cannonoutlookTab[index]
end

function GameTableData:getGunOutlookTableByVip(vip)
    vip = tonumber(vip)
    local gunType = self:getVipTable(vip).cannon_type
    return self:getCannonoutlookTable(gunType)
end

--vip数据
function GameTableData:initVipTable()
    local back = FishGMF.getTableByName("vip")
    self.vipTab = {}
    for k,v in pairs(back) do
        v.id = tonumber(v.id)
        v.vip_level = tonumber(v.vip_level)
        v.money_need = tonumber(v.money_need)
        v.cannon_type = tonumber(v.cannon_type)
        v.extra_sign = tonumber(v.extra_sign)
        v.checkin_rate = tonumber(v.checkin_rate)
        v.strData = self:splitVipShowText(v.show_text)
        self.vipTab[v.vip_level] = v
    end
end
--解析show_text
function GameTableData:splitVipShowText(show_text)
    local str1 = string.split( show_text, ";")
    local strData = {}
    --特权
    for i,val in ipairs(str1) do
        local str = val 
        local front = 1;
        local back = 1;
        local len = string.len(str);
        local strTab = {}
        local count = 1
        back = string.find(str, "%[", front);
        if back ~= nil then
            str = str.."|"
            local arg = string.sub(str,front,back-1);
            front = back+1;
            strTab[count] = arg
            count = count +1

            back = string.find(str, "%]", front);
            local num = string.sub(str,front,back-1);
            strTab[count] = num
            local numArr = self:splitTextShow(num)
            strTab["numArr"] = numArr

            front = back+1;
            count = count +1

            back = string.find(str, "|", front);
            local endStr = string.sub(str,front,back-1);
            strTab[count] = endStr

        else
            strTab[count] = {}
            strTab[count]= str
        end
        strData[i] = strTab
    end
    return strData
end

function GameTableData:splitTextShow(str)
    local arr = string.split(str,"|")
    local strArgTab = {};
    if arr == nil or #arr < 2 then
        return strArgTab
    end
    strArgTab["r"] = arr[1]
    strArgTab["g"] = arr[2]
    strArgTab["b"] = arr[3]
    strArgTab["a"] = arr[4]
    strArgTab["size"] = arr[5]
    strArgTab["word"] = arr[6]

    return strArgTab
end

function GameTableData:getVipTable(index)
    if self.vipTab == nil then
        self:initVipTable()
    end
    if index == nil then
        return self.vipTab
    end
    index = tonumber(index)
    return self.vipTab[index]
end

function GameTableData:getVIPByCostMoney(money)
    if self.vipTab == nil then
        self:initVipTable()
    end    
    money = tonumber(money)
    local count = table.nums(self.vipTab)
    local result = nil
    for i=0,count - 2 do
        local money_need_min = self.vipTab[i].money_need
        local money_need_Max = self.vipTab[i + 1].money_need
        if money >= money_need_min and money < money_need_Max then
            self.vipTab[i].next_All_money = money_need_Max
            return self.vipTab[i]
        end
    end
    self.vipTab[count - 1].next_All_money = 0
    return self.vipTab[count - 1]

end

--技能数据
function GameTableData:initSkillTable()
    local back = FishGMF.getTableByName("skill")
    self.skillTab = {}
    for k,v in pairs(back) do
        if v.item_need ~= nil and v.item_need ~= "" then
            local data = {}
            data.propId = tonumber(v.item_need)
            data.cool_down = tonumber(v.cool_down)
            data.duration = tonumber(v.duration)
            data.unlock_vip = tonumber(v.unlock_vip)
            self.skillTab[tonumber(v.item_need)] = data
        end
    end
end

function GameTableData:getSkillTable()
    if self.skillTab == nil then
        self:initSkillTable()
    end
    return self.skillTab
end

function GameTableData:initItemTable()
    local dataTab = {}
    dataTab.funName = "getAllItemData"
    local itemAllData = LuaCppAdapter:getInstance():luaUseCppFun(dataTab)
    local data = {}
    for i=1,itemAllData.count do
        local val = itemAllData[tostring(i)]
        val.propId = val.id - 200000000
        val.propCount = 0
        val.inner_value = tonumber(val.inner_value)
        val.can_buy = tonumber(val.can_buy)
        val.num_perbuy = tonumber(val.num_perbuy)
        val.require_num = tonumber(val.require_num)
        val.require_vip = tonumber(val.require_vip)
        val.if_show = tonumber(val.if_show)
        val.default_show = tonumber(val.default_show)
        val.decomposable = tonumber(val.decomposable)
        val.num_decompose = tonumber(val.num_decompose)
        val.allow_send = tonumber(val.allow_send)
        val.num_send = tonumber(val.num_send)
        val.sendreq_vip = tonumber(val.sendreq_vip)
        val.allow_exchange = tonumber(val.allow_exchange)
        val.if_taste = tonumber(val.if_taste)
        val.use_outlook = tonumber(val.use_outlook)
        val.taste_time = tonumber(val.taste_time)
        val.show_order = tonumber(val.show_order)
        val.if_senior = tonumber(val.if_senior)
        if val.if_senior == 1 then
            val.seniorData = nil
        end

        local priceStr = val.price
        local tab = string.split(priceStr,",")
        val.priceId = tonumber(tab[1])
        val.priceCount = tonumber(tab[2])

        local sellTab = string.split(val.sell_value,",")
        val.sellPriceId = tonumber(sellTab[1])
        val.sellPrice = tonumber(sellTab[2])
        
        table.insert(data,val)
    end
    --排序的算法
    FishGF.sortByKey(data,"id",1)
    self.itemAllData = data
end

function GameTableData:getItemTable(propId)
    if self.itemAllData == nil then
        self:initItemTable()
    end
    if propId == nil then
        return self.itemAllData
    end

    propId = tonumber(propId)
    for i,v in ipairs(self.itemAllData) do
        if v.propId == propId then
            return v
        end
    end
    return nil
end

--游戏内抽奖数据
function GameTableData:initRewardTable()
    local back = FishGMF.getTableByName("reward")
    self.rewardTab = {}
    for k,v in pairs(back) do
        v.id = tonumber(v.id)
        v.limit = tonumber(v.limit)
        local reward = v.reward
        v.prop = {}
        local prop = FishGF.strToVec3(reward..";")
        --v.prop = prop
        for i,v2 in ipairs(prop) do
            local propData = {}
            propData.propId = v2.x
            propData.propCount = v2.y
            table.insert( v.prop, propData)
        end
        table.insert( self.rewardTab, v)
    end
    FishGF.sortByKey(self.rewardTab,"id",1)
    local a =1
end

function GameTableData:getRewardTable(index)
    if self.rewardTab == nil then
        self:initRewardTable()
    end
    if index == nil then
        return self.rewardTab
    end
    index = tonumber(index)
    return self.rewardTab[index]
end

--新手任务数据
function GameTableData:initNewtaskTable()
    local back = FishGMF.getTableByName("newtask")
    self.newtaskTab = {}
    for k,v in pairs(back) do
        v.id = tonumber(v.id)
        v.task_type = tonumber(v.task_type)
        v.task_data = tonumber(v.task_data)
        self.newtaskTab[v.id] = v
    end
end

function GameTableData:getNewtaskTable(index)
    if self.newtaskTab == nil then
        self:initNewtaskTable()
    end
    if index == nil then
        return self.newtaskTab
    end
    index = tonumber(index)
    return self.newtaskTab[index]
end

return GameTableData;