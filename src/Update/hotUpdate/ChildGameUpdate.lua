local ChildGameUpdate = class("ChildGameUpdate", cc.load("mvc").ViewBase)

ChildGameUpdate.AUTO_RESOLUTION   = true
ChildGameUpdate.RESOURCE_FILENAME = "ui/update/uichildgameupdate"
ChildGameUpdate.RESOURCE_BINDING  = {    
    ["spr_logo"]       = { ["varname"] = "spr_logo" }, 
    ["slider_loading"] = { ["varname"] = "slider_loading" },
    ["spr_bar_light"]  = { ["varname"] = "spr_bar_light" },
    
    ["text_message"]   = { ["varname"] = "text_message" },    
    ["text_status"]    = { ["varname"] = "text_status" },  
    ["text_sizeper"]   = { ["varname"] = "text_sizeper" },
    ["text_version"]   = { ["varname"] = "text_version" },
    
}

function ChildGameUpdate:ctor()
    ChildGameUpdate.super.ctor(self)
    self:setItemVisible(false)
    self.spr_bar_light:setScaleY(0);
    self.text_message:setString("")
    self.text_status_pos = cc.p(self.text_status:getPositionX(), self.text_status:getPositionY());

    self:openTips(4)
end

function ChildGameUpdate:onCreate( ... )

end

function ChildGameUpdate:setVersion(version)
    local versionStr = table.concat(version, ".");
    self.text_version:setString(versionStr)
end

function ChildGameUpdate:openTips(time)
    local function callFunc()
        local index = "85000000"..math.random(0,5);
        local tip = FishGI.GameConfig:getConfigData("tips", index, "text");
        print("tip:"..tip)
        self.text_message:setString(tip)
    end
    callFunc();
    self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(callFunc))));
end

function ChildGameUpdate:setItemVisible(isVisible)
    
    self.spr_bar_light:setVisible(isVisible);
    self.text_sizeper:setVisible(isVisible);
    self.text_message:setVisible(isVisible);

    if isVisible then
        self.text_status:setString("资源下载中......");
        self.spr_bar_light:setAnchorPoint(cc.p(1, 0.5));
    else
        self.text_status:setString("正在检测最新版本......");
    end
    
end

function ChildGameUpdate:isCheckVer(isCheck)
    if isCheck then
        self:setItemVisible(false);
        self.text_status:setPositionY(text_sizeper:getPositionY());
    else
        self:setItemVisible(true);
        self.text_status:setPositionY(self.text_status_pos.y);
    end
end

function ChildGameUpdate:receiveData(cur,all,speed)
    local str = math.floor(cur/1024).."/".. math.floor(all/1024).."KB"
    local percent = (cur/all)*100
    self.slider_loading:setPercent(percent);
    local curX = self.slider_loading:getSize().width;
    self.spr_bar_light:setPositionX(curX*(percent/100));

    self.text_sizeper:setString(str)

    local scaleY = self.slider_loading:getScale()
    local scaleDis = 3
    if percent > 100-scaleDis then
        scaleY = (100 - percent)/scaleDis*scaleY
    end
    if percent <= scaleDis then
        scaleY = percent/scaleDis*scaleY
    end

    self.spr_bar_light:setScale(scaleY)
end

function ChildGameUpdate:loadingEnd()
    self.spr_bar_light:setVisible(false);
    self:getParent():runNextScene();
    self:removeFromParent()
end

return ChildGameUpdate