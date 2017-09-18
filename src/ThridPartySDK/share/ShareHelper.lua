-- Author: lee
-- Date: 2016-10-19 17:36:39
local CURRENT_MODULE_NAME = ...
local moudel = "WXShare"
--local appid = WX_APP_ID_LOGIN;
local ShareHelper = {
    providers_ = nil
}

function ShareHelper:lazyInit()
    if not self.providers_ then
        self.providers_ = require("ThridPartySDK/share/Share").create();
    end
end

function ShareHelper:reset()
    if self.providers_ then
        self.providers_:removeListener()
        self.providers_ = nil
    end
end

--执行分享调起
function ShareHelper:doShare(params)
    self:lazyInit()
    params=checktable(params)
    assert(params.sharetype,"sharetype is nil")
    if self.providers_ then
        --GameApp:dispatchEvent(gg.Event.SHOW_LOADING, "正在拉起微信,请稍后。。。",2)
        print("正在拉起微信,请稍后。。。");
        self.providers_:doWXShareReq(params)
    end
end

-- sharetype [web appweb text image]
-- appid
-- wxscene
-- title imgurl weburl desc text imgpath 

--执行分享调起 wxscene 默认朋友圈 appid 默认读取配置
function ShareHelper:doShareWebType(title,imgurl,weburl,wxscene,desc,appid)
    local args ={}
    args.sharetype="web"
    assert(title,"title is nil")
    assert(imgurl,"imgurl is nil")
    assert(weburl,"weburl is nil")

    args.title=title
    args.imgurl=imgurl
    args.desc=desc
    args.weburl=weburl
    args.wxscene=wxscene
    args.appid=appid
    self:doShare(args)
end

--执行分享调起 wxscene 默认朋友圈 appid 默认读取配置 默认缩略图为应用图标
function ShareHelper:doShareAppWebType(title,desc,weburl,wxscene,appid)
    assert(desc,"desc is nil")
    assert(desc,"desc is nil")
    assert(weburl,"weburl is nil")
    local args ={}
    args.sharetype="appweb"
    args.title=title
    args.desc=desc
    args.weburl=weburl
    args.wxscene=wxscene
    args.appid=appid
    self:doShare(args)
end

--执行分享调起 wxscene 默认朋友圈 appid 默认读取配置
function ShareHelper:doShareImageType(imgpath,wxscene,appid)
    local args ={}
    args.sharetype="image"
    assert(imgpath,"imgpath is nil")
    args.imgpath=imgpath
    args.wxscene=wxscene
    args.appid=appid
    self:doShare(args)
end

--执行分享调起 wxscene 默认朋友圈 appid 默认读取配置
function ShareHelper:doShareTextType(text,wxscene,appid)
    local args ={}
    args.sharetype="text"
    assert(text,"text is nil")
    args.text=text
    args.wxscene=wxscene
    args.appid=appid
    self:doShare(args)
end

--显示分享方式选择界面 wxscene 默认朋友圈 appid 默认读取配置
function ShareHelper:showShareMethod(node)
    -- body
end

return ShareHelper