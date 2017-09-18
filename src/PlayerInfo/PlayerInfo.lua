
local PlayerInfo = class("PlayerInfo", cc.load("mvc").ViewBase)

PlayerInfo.AUTO_RESOLUTION   = false
PlayerInfo.RESOURCE_FILENAME = "ui/playerinfo/uiplayerinfo"
PlayerInfo.RESOURCE_BINDING  = {    
    ["panel"]               = { ["varname"] = "panel" },
    ["image_all_bg"]        = { ["varname"] = "image_all_bg" },
    ["btn_close"]           = { ["varname"] = "btn_close" ,             ["events"]={["event"]="click",["method"]="onClickclose"}},  

    ["text_account"]        = { ["varname"] = "text_account" },
    ["spr_vip"]             = { ["varname"] = "spr_vip" },    

    ["text_name"]           = { ["varname"] = "text_name" },     
    ["text_grade"]          = { ["varname"] = "text_grade" },       
    ["text_id"]             = { ["varname"] = "text_id" }, 
    ["text_coin"]           = { ["varname"] = "text_coin" }, 
    ["text_crystal"]        = { ["varname"] = "text_crystal" },     

    ["btn_phone_act"]       = { ["varname"] = "btn_phone_act" ,         ["events"]={["event"]="click",["method"]="onClickphone_act"}},  
    ["btn_com_act"]         = { ["varname"] = "btn_com_act" ,           ["events"]={["event"]="click",["method"]="onClickcom_act"}},  
    ["btn_phone_unbind"]    = { ["varname"] = "btn_phone_unbind" ,      ["events"]={["event"]="click",["method"]="onClickphone_unbind"}}, 

    ["btn_change_password"] = { ["varname"] = "btn_change_password" ,   ["events"]={["event"]="click",["method"]="onClickchange_password"}},  
    ["btn_phone_bind"]      = { ["varname"] = "btn_phone_bind" ,        ["events"]={["event"]="click",["method"]="onClickphone_bind"}},  
    ["btn_photo"]           = { ["varname"] = "btn_photo" ,             ["events"]={["event"]="click",["method"]="onClickphoto"}}, 
    ["btn_setname"]         = { ["varname"] = "btn_setname" ,           ["events"]={["event"]="click",["method"]="onClicksetname"}}, 
    ["btn_copy"]            = { ["varname"] = "btn_copy" ,              ["events"]={["event"]="click",["method"]="onClickcopy"}},   
    ["text_copy"]           = { ["varname"] = "text_copy" },   
}

function PlayerInfo:onCreate( ... )

    self:openTouchEventListener()
    
    self.text_name:setString("")
    self.text_copy:setString(FishGF.getChByIndex(800000308))
end

--通过全局的自己数据更新界面
function PlayerInfo:upDataPlayerData()
    self:setPlayerAccount(FishGI.myData.account)
    self:setGrade(FishGI.myData.gradeExp)
    self:setVIP(FishGI.myData.vip_level)
    self.text_id:setString(FishGI.myData.id)
    self.text_coin:setString(FishGI.myData.fishIcon)
    self.text_crystal:setString(FishGI.myData.crystal)    

    self:setPlayerNickName(FishGI.myData.nickName)
    self:setNickNameChangeCount(FishGI.myData.nickNameChangeCount)

    self:upDataBtnState(FishGI.WebUserData:isActivited(),FishGI.WebUserData:isBindPhone())

end

--通过变量名称设置变量值
function PlayerInfo:setPlayerDataByName( keyname,val )
    if keyname == "account" then
        self:setPlayerAccount(val)
    elseif keyname == "gradeExp" then
        self:setGrade(val)
    elseif keyname == "vip_level" then
        self:setVIP(val)
    elseif keyname == "id" then
        self.text_id:setString(val)
    elseif keyname == "fishIcon" then
        self.text_coin:setString(val)
    elseif keyname == "crystal" then
        self.text_crystal:setString(val)   
    elseif keyname == "nickName" then
        self.text_name:setString(val)  
    end
end

--设置等级
function PlayerInfo:setGrade( gradeExp )
    local gradeData = FishGI.GameTableData:getLVByExp(gradeExp)

    local str = "LV"..gradeData.level.."("..gradeData.expCur.."/"..gradeData.expNext..")"
    self.text_grade:setString(str)
end

--设置昵称更改次数
function PlayerInfo:setNickNameChangeCount( nickNameChangeCount )
    if nickNameChangeCount > 0 then
        self.btn_setname:setVisible(false)
    else
        self.btn_setname:setVisible(true)
    end
end

--设置昵称
function PlayerInfo:setPlayerNickName( nickName )
    self.text_name:setString(nickName)
end

--设置账号
function PlayerInfo:setPlayerAccount( Account )
    self.text_account:setString(Account)
end

--设置VIP等级
function PlayerInfo:setVIP( vip_level )
    if vip_level == nil or vip_level < 0 then
        vip_level = 0 
    end
    local vipName = string.format("common/vip/vip_badge_%d.png",(vip_level))
    self.spr_vip:initWithFile(vipName)
end

--更新按键
function PlayerInfo:upDataBtnState( isActivited,isBindPhone )
    self.btn_phone_unbind:setVisible(false)
    self.btn_phone_bind:setVisible(false)
    self.btn_change_password:setVisible(false)
    self.btn_com_act:setVisible(false)
    self.btn_phone_act:setVisible(false)

    if FishGF.isThirdSdk() and FishGF.isThirdSdkLogin() then
        if self.noticeSpr == nil then
            self.noticeSpr = cc.Sprite:create("playerinfo/pinf_pic_zhsx.png")
            self.panel:addChild(self.noticeSpr)
            self.noticeSpr:setPosition(0,-200)
        end
        return
    end

    if isActivited == nil or isBindPhone == nil then
        return
    end

    -- 判断手机绑定状态
    if isActivited then
        if isBindPhone then
            FishGF.print("--手机解绑--")
            self.btn_phone_unbind:setVisible(true)
        else
            FishGF.print("--手机绑定--")
            self.btn_phone_bind:setVisible(true)
        end
        self.btn_change_password:setVisible(true)
        FishGI.PLAYER_STATE = 1
    else
        FishGF.print("--激活帐号--")
        self.btn_com_act:setVisible(true)
        self.btn_phone_act:setVisible(true)
        FishGI.PLAYER_STATE = 0
    end

end

function PlayerInfo:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function PlayerInfo:onClickclose( sender )
    self:hideLayer()
end

function PlayerInfo:onClickphone_act( sender )
    print("onClickphone_act")
    self:hideLayer() 
    FishGI.hallScene.uiPhoneAct:showLayer() 
end

function PlayerInfo:onClickcom_act( sender )
    print("onClickcom_act")
    self:hideLayer() 
    FishGI.hallScene.uiComAct:showLayer() 
end

function PlayerInfo:onClickphone_unbind( sender )
    print("onClickphone_unbind")
    self:hideLayer(self,false,self:getParent()) 
    FishGI.hallScene.uiPhoneUnbind:showLayer() 
end

function PlayerInfo:onClickchange_password( sender )
    print("onClickchange_password")
    self:hideLayer() 
    FishGI.hallScene.uiChangePassword:showLayer() 
end

function PlayerInfo:onClickphone_bind( sender )
    print("onClickphone_bind")
    self:hideLayer() 
    FishGI.hallScene.uiPhoneBind:showLayer() 
end

function PlayerInfo:onClickphoto( sender )
    print("onClickphoto")
end

function PlayerInfo:onClicksetname( sender )
    print("onClicksetname")
    if (not FishGF.isThirdSdk()) or CHANNEL_ID == CHANNEL_ID_LIST.baidu then
        if FishGI.PLAYER_STATE == 0 then
            local function callback(sender)
                local tag = sender:getTag()
                if tag == 2 then
                    print("---PlayerInfo--goto comAct-")
                    self:hideLayer(false) 
                    FishGI.hallScene.uiComAct:showLayer() 
                    --FishGI.hallScene.uiComAct:initEditBoxStr("") 
                end
            end
            local str = FishGF.getChByIndex(800000190)
            FishGF.showMessageLayer(FishCD.MODE_MIDDLE_OK_CLOSE,str,callback)
            return 
        end
    end

    self:hideLayer() 
    FishGI.hallScene.uiChangeNickName:showLayer() 

end

function PlayerInfo:onClickcopy( sender )
    print("onClickcopy")
    FishGF.copy(tostring(FishGI.myData.id))
end

return PlayerInfo;