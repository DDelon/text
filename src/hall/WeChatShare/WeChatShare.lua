
local WeChatShare = class("WeChatShare", cc.load("mvc").ViewBase)

WeChatShare.AUTO_RESOLUTION   = false
WeChatShare.RESOURCE_FILENAME = "ui/hall/wechatshare/uiwechatshare"
WeChatShare.RESOURCE_BINDING  = {    
    ["panel"]            = { ["varname"] = "panel" },
    ["btn_close"]        = { ["varname"] = "btn_close" ,            ["events"]={["event"]="click",["method"]="onClickclose"}},     
    
    ["btn_share"]        = { ["varname"] = "btn_share" ,            ["events"]={["event"]="click",["method"]="onClickshare"}},        

    ["text_title"]       = { ["varname"] = "text_title" },       
    
}

function WeChatShare:onCreate( ... )
    self:initData()
    self:initBgWord()

    self:openTouchEventListener()
    self.isSuccess = false
    self.shareType = nil
end

function WeChatShare:initData()
    local Weichat_get = tostring(FishGI.GameConfig:getConfigData("config", tostring(990000042), "data"))
    local propTab = string.split(Weichat_get,";")
    self.proptab = {}
    for i=1,#propTab do
        local data = string.split(propTab[i],",")
        local propId = tonumber(data[1])
        local node = self:child("image_prop_"..propId)
        local spr_prop = node:getChildByName("spr_prop")
        local spr_name = node:getChildByName("spr_name")
        local fnt = node:getChildByName("fnt")

        spr_prop:initWithFile(string.format("common/prop/prop_%03d.png",propId))
        spr_name:initWithFile(string.format("hall/share/share_pic_prop_%d.png",propId))
        fnt:setString("x"..data[2])

    end
end

function WeChatShare:initBgWord()
    self.text_title:setString(FishGF.getChByIndex(800000123))

end

function WeChatShare:onTouchBegan(touch, event)
    if not self:isVisible() then
         return false
    end
    return true
end

function WeChatShare:onClickclose( sender )
    self:hideLayer() 
end

function WeChatShare:onClickshare( sender )
    self.shareType = "self"
    print("onClickshare")
    FishGI.wechatShareType = 0
    local shareInfo = FishGI.WebUserData:GetShareDataTable();
    FishGI.ShareHelper:doShareWebType(shareInfo.text,shareInfo.icon,shareInfo.url, nil, nil, shareInfo.id);
end

function WeChatShare:shareResult( data )
    if data.props == nil then
        data.props = {}
    end
    if data.seniorProps == nil then
        data.seniorProps = {}
    end

    --local isNoPlayGetAct = (bit.band(FUN_SWITCH, 8) == 8)
    FishGI.isWechatShare = false
    local isSuccess = data.isSuccess;
    if isSuccess then
        self.shareLinkUsed = true
        if self.shareType ~= "self" then
            FishGI.hallScene.taskPanel:requestForTaskInfo()
        end

        for k,val in pairs(data.props) do
            if val ~= nil and val.propId ~= nil then      
                if self.shareType == "self" then
                    FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,val.propId,val.propCount,false)
                    FishGMF.setAddFlyProp(FishGI.myData.playerId,val.propId,val.propCount,false)
                else
                    FishGMF.addTrueAndFlyProp(FishGI.myData.playerId,val.propId,val.propCount,true)
                end
            end
        end

        for k,val in pairs(data.seniorProps) do
            if val ~= nil and val.propId ~= nil then
                local userType = 1
                if self.shareType == "self" then
                    userType = 8
                end
                FishGMF.refreshSeniorPropData(FishGI.myData.playerId,val,userType,0)
            end
        end

        if self.shareType ~= "self" then
            self.shareType = nil
            print("-----------------isNoPlayGetAct == true---------------")
            return 
        end
        print("-----------------isNoPlayGetAct == false---------------")
        --播放特效
        for k,val in pairs(data.props) do
            local propTab = {}
            propTab.playerId = FishGI.myData.playerId
            propTab.propId = val.propId
            propTab.propCount = val.propCount
            propTab.isRefreshData = true
            propTab.isJump = false
            propTab.firstPos = self:getFirstPosByPropId(val.propId)
            propTab.dropType = "normal"
            propTab.isShowCount = false
            FishGI.GameEffect:playDropProp(propTab)
        end

        for k,val in pairs(data.seniorProps) do
            local propTab = {}
            propTab.playerId = FishGI.myData.playerId
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
    end
    self.shareType = nil
end

function WeChatShare:getFirstPosByPropId( propId,type )
    if type == nil then
        local child = self:child("image_prop_"..(propId))
        if child == nil then
            return nil
        end 
        local spr = child:getChildByName("spr_prop")
        local pos = cc.p(spr:getPositionX(),spr:getPositionY())
        pos = child:convertToWorldSpace(pos)
        return pos
    else
        return cc.p(display.width/2,display.height/2)
    end

end


return WeChatShare;