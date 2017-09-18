
local RecordBody = class("RecordBody", cc.load("mvc").ViewBase)

RecordBody.AUTO_RESOLUTION   = false
RecordBody.RESOURCE_FILENAME = "ui/hall/record/uirecordbody"
RecordBody.RESOURCE_BINDING  = {  
    ["panel"]     = { ["varname"] = "panel" },  
    ["img_bg"]    = { ["varname"] = "img_bg" },      
    ["node_no_1"] = { ["varname"] = "node_no_1" },   
    ["node_no_2"] = { ["varname"] = "node_no_2" },
    ["node_no_3"] = { ["varname"] = "node_no_3" }, 
    ["node_no_4"] = { ["varname"] = "node_no_4" }, 
    
}

function RecordBody:onCreate(...)   

    self:child("text_word_no"):setString(FishGF.getChByIndex(800000243))
    self:child("text_word_name"):setString(FishGF.getChByIndex(800000244))
    self:child("text_word_score"):setString(FishGF.getChByIndex(800000245))

    self.showTime =  tonumber(FishGI.GameConfig:getConfigData("config", tostring(990000073), "data"));

    self:openTouchEventListener()

end

function RecordBody:onTouchBegan(touch, event) 
    if not self:isVisible() then
        return false
    end

    local curPos = touch:getLocation()  
    local s = self.img_bg:getContentSize()
    local locationInNode = self.img_bg:convertToNodeSpace(curPos)
    local rect = cc.rect(0,0,s.width,s.height)
    if cc.rectContainsPoint(rect,locationInNode) then
        return true
    end

    self:hideLayer()
    return false
end

--设置数据
function RecordBody:setBodyData(val)   
    if val == nil then
        return
    end

    self.recordData = val

    local playerList = self.recordData.items
    --排序的算法
    FishGF.sortByKey(playerList,"order",1)

    self.recordData.items = playerList

    local count = #(self.recordData.items)
    for i=1,4 do
        local node = self["node_no_"..i]
        if i <= count then
            local v= self.recordData.items[i]
            local text_no = node:getChildByName("text_no")
            local text_name = node:getChildByName("text_name")
            local text_score = node:getChildByName("text_score")

            text_no:setString(v.order)
            text_name:setString(v.nickName)
            text_score:setString(v.score)

            node:setVisible(true)
        else
            node:setVisible(false)
        end
    end
end

--得到数据 
function RecordBody:getItemData()   
    return self.recordData
end


--显示
function RecordBody:showLayer()
    self:stopAllActions()
    self:setVisible(true)
    local seq = cc.Sequence:create(cc.DelayTime:create(self.showTime),cc.Hide:create())
    
    self:runAction(seq)
end

function RecordBody:hideLayer()
    self:stopAllActions()
    self:setVisible(false)
end

return RecordBody;