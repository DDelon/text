
local RecordItem = class("RecordItem", cc.load("mvc").ViewBase)

RecordItem.AUTO_RESOLUTION   = false
RecordItem.RESOURCE_FILENAME = "ui/hall/record/uirecorditem"
RecordItem.RESOURCE_BINDING  = {  
       ["panel"]       = { ["varname"] = "panel" },  
       ["btn_look"]    = { ["varname"] = "btn_look" ,         ["events"]={["event"]="click",["method"]="onClicklook"}},
       ["img_bg"]      = { ["varname"] = "img_bg" },   
       
       ["text_time"]   = { ["varname"] = "text_time" },   
       ["text_roomno"] = { ["varname"] = "text_roomno" }, 
       ["text_name"]   = { ["varname"] = "text_name" }, 

}

function RecordItem:onCreate(...)   

end

--设置数据
function RecordItem:setItemData(val)   
    if val == nil then
        return
    end

    self.recordData = val
    self.text_roomno:setString(val.friendRoomNo)
    self.text_name:setString(val.creatorNickName)
    self.text_time:setString(val.time)

end

--得到数据 
function RecordItem:getItemData()   
    return self.recordData
end

--查看
function RecordItem:onClicklook( sender )
    FishGI.FriendRoomManage:sendGetFriendDetail(self.recordData.friendGameId)
end

return RecordItem;