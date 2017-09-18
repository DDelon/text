
local MailItem = class("MailItem", cc.load("mvc").ViewBase)

MailItem.AUTO_RESOLUTION   = false
MailItem.RESOURCE_FILENAME = "ui/hall/mail/uimailitem"
MailItem.RESOURCE_BINDING  = {  
    ["panel"]            = { ["varname"] = "panel" },  
    ["btn_look"]         = { ["varname"] = "btn_look" ,         ["events"]={["event"]="click",["method"]="onClicklook"}},   
    ["img_bg"]           = { ["varname"] = "img_bg" },     
    
    
    ["text_time"]        = { ["varname"] = "text_time" },   
    
    ["text_word_title"]  = { ["varname"] = "text_word_title" }, 
    ["text_word_sender"] = { ["varname"] = "text_word_sender" }, 
    ["text_title"]       = { ["varname"] = "text_title" }, 
    ["text_sender"]      = { ["varname"] = "text_sender" }, 

}

function MailItem:onCreate(...)   
    self.text_word_title:setString(FishGF.getChByIndex(800000198)..":")
    self.text_word_sender:setString(FishGF.getChByIndex(800000199)..":")
end

--设置邮件数据
function MailItem:setItemData(val)   
    if val == nil then
        return
    end

    self.mailData = val

    local id = val.id
    local title = val.title
    local sender = val.sender
    local sendTime =val.sendTime


    self.text_title:setString(title)
    self.text_sender:setString(sender)

    self.text_time:setString(sendTime)

end

--得到邮件id
function MailItem:getItemId()   
    return self.mailData.id
end

--得到邮件数据 
function MailItem:getItemData()   
    return self.mailData
end

function MailItem:onClicklook( sender )
    FishGI.hallScene.net.roommanager:sendGetMailDetail(self:getItemId())
end

return MailItem;