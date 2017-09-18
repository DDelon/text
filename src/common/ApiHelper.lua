--[[
* 网站接口
* 回调函数事件原型
	err:错误原因，如果为nil，则没有错误
	data:数据，只有err为nil，才有效
function(err,data);
--]]
-- http://userapi.{domain}/{接口版本号}/{接口语言}/{品牌标识}/{接口名称}/app_id/{app_id}/channel_id/{channel_id}

-- local URL_HEADER = "http://userapi."
-- local DAPI_DOMAIN = URL_HEADER..WEB_DOMAIN;
-- local API_DOMAIN = "http://api.test."..WEB_DOMAIN;

-- 返回状态码
cc.exports.ApiStatus=
{
    Ok = 0,
    ShowMsg = 100,
    Success = 200,
    WXAuthFailed=351
}

local StateMsg = {
    [0] = "成功",
    [100] = "错误提示, 当状态为此值时请将错误信息显示给用户",
    [101] = "请求接口时必须使用https协议访问",
    [111] = "接口版本参数错误",
    [112] = "接口语言参数错误",
    [113] = "接口品牌参数错误",
    [119] = "缺少参数,具体缺少哪个参数请在msg中查看",
    [120] = "参数错误,具体哪个参数错误请在msg中查看",
    [121] = "请求的app_id参数错误",
    [122] = "请求的channel_id参数错误",
    [123] = "应用配置不存在",
    [124] = "用户API请求中的data参解密错误",
    [131] = "用户API请求中的token参数为空",
    [132] = "用户API请求中的token无效",
    [301] = "短信验证码发送太快(即:两次的间隔时间太短)",
    [302] = "单位时间内发送的短信验证码数量超限",
    [303] = "手机号码处于黑名单中,无法获取短信验证码",
    [351] = "微信授权过期",
    [500] = "服务器内部错误"
}

local dapi_ = "://dapi." .. WEB_DOMAIN
local userapi_ = "://userapi"..PREFIX_DOMAIN.."." .. WEB_DOMAIN
local payapi_ = "://payapi"..PREFIX_DOMAIN.."." .. WEB_DOMAIN
local payback_ = "://payback"..PREFIX_DOMAIN.."." .. WEB_DOMAIN
local thirdapi_ = "://third."..WEB_DOMAIN

-- local api_ver_="/v1"
-- local language_="/cn"
-- 平台 全局变量 BRAND 索引方式 获取 

--实现接口 url
local Dapi = {}
local Http = FishGI.Http

local function getPayApi_(name, channelId)
    if channelId == nil then
        channelId = CHANNEL_ID
    end
    local ver_str = FishGF.getHallVerison()
    return string.format("%s%s/%s/%d/%s/%s", payapi_, name,  APP_ID, channelId, ver_str, REGION_CODE)
end

local function getVerifyApi_(name, channelId)
    if channelId == nil then
        channelId = CHANNEL_ID
    end
    local ver_str = FishGF.getHallVerison()
    return string.format("%s%s/%s/%d/%s/%s", payback_, name,  APP_ID, channelId, ver_str, REGION_CODE)
end

local function getUserApi_(name, channelId)
    if channelId == nil then
        channelId = CHANNEL_ID
    end
    local ver_str = FishGF.getHallVerison()
    return string.format("%s%s/%s/%d/%s/%s", userapi_, name, APP_ID, channelId, ver_str, REGION_CODE)
end

--第三方登陆
local function getThirdApi_(name, channelId)
    if channelId == nil then
        channelId = CHANNEL_ID
    end
	local ver_str = FishGF.getHallVerison()
    return string.format("%s%s/%s/%d/%s/%s", thirdapi_, name, APP_ID, channelId, ver_str, REGION_CODE)
end

local function getToken_()
    if FishGI.hallScene then
        return { token = FishGI.hallScene.net:getSession() }
    else
        return { token = "0123456789abcdef0123456789abcdef" }
    end
end

local function checkvalues_(...)
    local values = { ... }
    for _, v in ipairs(values) do
        if not v or (type(v) == "string" and string.len(v) < 1) then
            printf("[error]参数校验失败，请检查参数。")
            return false
        end
    end
    return true
end

local function errorhandler_(callback)
    return function(state, data)
        if state then
            local ms = StateMsg[tonumber(state)] or data
            callback({ msg = ms or "解析错误！" , status = tostring(state) })
        else
            printf("errorhandler_ %s", tostring(data))
            local ok, datatable = pcall(function() return loadstring(data)(); end)
			if ok == false and data ~= nil then
				datatable = json.decode(data);
			end
            datatable = checktable(datatable)
            if ok and datatable.status == ApiStatus.ShowMsg then
                --GameApp:dispatchEvent(gg.Event.SHOW_MESSAGE_DIALOG, datatable.msg)
            end
            callback(datatable)
        end
    end
end


-- 获取错误代码提示
function Dapi:GetErrorMsg(err_code)
    return StateMsg[err_code]
end

-- 接口名称
-- user/init
-- 功能描述
-- 登录后的初始化接口 长期更新 ※重要接口※
-- 请求方式-- POST
-- 额外返回参数
-- attr (int)-- 账号属性，二进制存储，各值含义如下：
-- 1-- 已激活
-- 2-- 已绑定手机
-- 4-- 已绑定微信
-- notice (int)-- 未拉取的公告数量
-- usermsg (int)-- 未拉取的个人消息数量
function Dapi:UserInit(callback)
    local url = getUserApi_("/user/init")
    local data = getToken_()
    Http:Post(url, errorhandler_(callback), data, true)
end

--今日头条统计接口
function Dapi:JrttStatistics(callback)
    local url = getUserApi_("/market/toutiao").."?udid="..Helper.GetDeviceCode().."&os=2";
    local data = getToken_()
    Http:Post(url, errorhandler_(callback), data, true)
end

--获取元宝商城地址接口
function Dapi:GetMallUrl()
    local encryptToken = FishGI.Http:encryptData(getToken_())
    return "http://mall."..WEB_DOMAIN.."/"..APP_ID.."/"..CHANNEL_ID.."/0/data/"..encryptToken;
end

-- userapi-- 接口名称
-- task/config 
-- https://client.{domain}/task/config/{品牌ID,吉祥:1,微乐:2}/{AppID}/{渠道ID}/{版本号}/{任务版本号}/{地区代码}
function Dapi:TaskConfig(taskver,callback)
    local url = getUserApi_("/task/config")
    url=url.."/"..tostring(taskver)
    Http:Get(url, errorhandler_(callback))
end

-- exchange/phoneFee 使用话费卡兑换话费
-- POST
-- realtime (integer)-- 是否为即时话费卡，0:否，1:是
-- phone (string)-- 要充值的手机号
-- value (integer)-- 面值，1、2、5、10、30、50、100
--- @return
-- content (string)-- 分享内容
-- icon (string)-- 分享图标或图片地址
-- url (string)-- URL地址
-- pic (string)-- 仅分享图片时的图片地址，当此值不存在或为空时，按照老版本的链接方式进行分享；否则则使用此参数中的地址进行图片分享
function Dapi:ExchangePhoneFee(realtime, phone, value, callback)
    if checkvalues_(phone) then
        local url = getUserApi_("/exchange/phoneFee")
        local data = { realtime = realtime, phone = phone, value = value }
        table.merge(data, getToken_())
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- exchange/redpack 使用红包卡兑换微信红包
-- POST
-- 所需的额外参数
-- value (integer)-- 面值（单位：角）
-- realtime (integer)-- 是否为即时红包，0:否，1:是
-- 额外返回参数
-- content (string)-- 分享内容
-- icon (string)-- 分享图标或图片地址
-- url (string)-- URL地址
-- pic (string)-- 仅分享图片时的图片地址，当此值不存在或为空时，按照老版本的链接方式进行分享；否则则使用此参数中的地址进行图片分享
function Dapi:ExchangeRedpack(value, realtime, callback)

    local url = getUserApi_("/exchange/redpack")
    local data = { realtime = realtime, value = value }
    table.merge(data, getToken_())
    Http:Post(url, errorhandler_(callback), data, true)
end

---------------- user-------------------------

-- accounts/activatee 账号激活（普通激活）
-- POST
-- 所需的额外参数
-- username (string)-- 游戏帐号
-- password (string)-- 密码，一次MD5加密
-- udid (string)-- 设备码

function Dapi:ActivateAccount( user_name, pwd, uid, callback)
    if checkvalues_(user_name, pwd, uid) then
        local url = getUserApi_("/user/activate")
        local data = {  username = user_name, password = Helper.Md5(pwd), udid = uid }
        table.merge(data, getToken_())
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- accounts/activateMobile 账号激活（手机激活）
-- POST
-- 所需的额外参数
-- phone (string)-- 手机号码
-- captcha (string)-- 短信验证码，通过 captcha/sms 获取短信验证码 接口获取
-- password (string)-- 密码，一次MD5加密
-- udid (string)-- 设备码
function Dapi:ActivateMobile(phone_num, captcha_str, pwd, uid, callback)

    if checkvalues_(phone_num, captcha_str, pwd, uid) then
        local url = getUserApi_("/user/activateMobile")
        pwd = Helper.Md5(pwd)
        local data = { username = phone_num, captcha = captcha_str, password = pwd, udid = uid }
        table.merge(data, getToken_())
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- phone/captcha 获取短信验证码
-- POST
-- 所需的额外参数
-- phone (string)-- 手机号码
-- udid (string)-- 设备码
-- purpose (string)-- 验证码用途，可以是以下值：
-- activate：账号激活
-- bind：绑定手机
-- unbind：解绑手机
-- 额外返回参数
-- purpose (int)
-- 再次获取的间隔时间（秒），当status为0时返回
-- surplus (int)
-- 剩余的间隔时间（秒），当status为301时返回，可将此值直接显示于按钮上用于倒计时
function Dapi:PullCaptchaSms(phone, udid, purpose, callback)
    if checkvalues_(phone, udid, purpose) then
        local url = getUserApi_("/phone/captcha")
        local data = { phone = phone, udid = udid, purpose = purpose }
        table.merge(data, getToken_())
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- captcha/checkSms 验证短信验证码
-- POST
-- 所需的额外参数
-- captcha (string)-- 用户填写的短信验证码
-- phone (string)-- 手机号码
-- udid (string)-- 设备码
-- purpose (string)-- 验证码用途，可以是以下值：
-- activate：账号激活
-- bindphone：绑定手机
-- unbindphone：解绑手机
-- function Dapi:VerifyCaptchaSms(callback)
-- 	local  url =getUserApi_("/captcha/checkSms")
-- 	local data={captcha="",phone="",udid="",purpose="",activate="",bindphone="",unbindphone=""}
-- 	table.merge(data,getToken_())	
-- 	Http:Post(url,callback,data)
-- end

-- phone/bind 绑定手机
-- POST
-- 所需的额外参数
-- phone (string)-- 手机号码
-- captcha (string)-- 短信验证码，通过 phone/captcha  获取短信验证码 接口获取
function Dapi:BindPhone(phone, captcha,  callback)
    if checkvalues_(phone, captcha) then
        local url = getUserApi_("/phone/bind")
        local data = { phone = phone, captcha = captcha}
        table.merge(data, getToken_())
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- phone/unbinde 解绑手机
-- POST
-- 所需的额外参数
-- phone (string)-- 手机号码
-- captcha (string)-- 短信验证码，通过 phone/captcha 获取短信验证码 接口获取
function Dapi:UnbindPhone(phone, captcha, callback)
    if checkvalues_(phone, captcha) then
        local url = getUserApi_("/phone/unbind")
        local data = { phone = phone, captcha = captcha }
        table.merge(data, getToken_())
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- accounts/nickname 修改昵称
-- POST
-- 所需的额外参数（以下参数不传则不进行修改）
-- nickname (string)-- 昵称 
function Dapi:ModifyNickName(nickname, callback)
    if checkvalues_(nickname) then
        local url = getUserApi_("/user/nickname")
        local data = { nickname = nickname }
        table.merge(data, getToken_())
        -- Http:Post(url,callback,data)
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- accounts/sex 修改性别
-- POST
-- 所需的额外参数（以下参数不传则不进行修改）
-- sex (int)-- 性别，1：男，0：女
function Dapi:ModifySex(sex, callback)
    if checkvalues_(sex) then
        local url = getUserApi_("/user/sex")
        local data = { sex = sex }
        table.merge(data, getToken_())
        -- Http:Post(url,callback,data)
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- id 玩家id
function Dapi:isExist(id, callback)
    if checkvalues_(phone, captcha) then
        local url = getUserApi_("/user/exist")
        local data = { id = id}
        table.merge(data, getToken_())
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- user/password
-- POST
-- 所需的额外参数
-- old (string) 原密码
-- new (string) 新密码
function Dapi:ModifyPassword(old, new, callback)
    if checkvalues_(old, new) then
        local url = getUserApi_("/user/password")
        local data = { old = old, new = new }
        table.merge(data, getToken_())
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- user/avatar 上传头像
-- POST
-- 所需的额外参数不加密
-- 不加密-- 图片数据流
function Dapi:UploadAvatar(fullpath, callback)
    local url = getUserApi_("/user/avatar")
    Http:UploadFile(url, errorhandler_(callback), fullpath, getToken_())
end


-- userapi
-- 接口名称
-- login/wechat
-- POST
-- 所需的额外参数
-- wechat_id (string)-- 微信ID，请用打包内置的微信ID进行登录
-- code (string)-- 用户换取access_token的code，从微信SDK获得，首次登录或凭证失效必须带有该参数
-- openid (string)-- 微信用户与当前包对应的openid，每次登陆后web接口都将返回该值，二次登录可直接使用openid进行登录，不必再次进行授权
-- 额外返回参数
-- result (int)-- 游戏第三方登录服务器返回的状态码
-- msg (string)-- 游戏第三方登录服务器的提示信息
-- id (int)-- 用户ID
-- hallid (int)-- 登录的大厅ID
-- ip (int)-- 整形IP地址
-- port (int)-- 端口
-- code (string)-- 游戏第三方登录服务器返回的session
-- openid (string)-- 微信用户与当前包对应的openid，需在二次登录时传给web接口
function Dapi:LoginByWechat(wxappid,wxcode,wxopenid,callback)
    local url = getUserApi_("/login/wechat")
    wxappid=wxappid or WX_APP_ID_LOGIN    
    local deviceid = Helper.GetDeviceCode();
    local data ={wechat_id=wxappid,code=wxcode,openid=wxopenid,udid=deviceid} 
    Http:Post(url, errorhandler_(callback), data,true)
end


--[[
获取比赛配置信息
gameid  游戏id
roomid 房间id
--@返回xml数据----
 例：http://Dapi.jixiang.cn/static/data/game_1/awards_98.xml
<root>
<times>
<time value="全天24小时开赛"/>
</times>
<rule>循环赛,满45人开赛,前6名获奖</rule>
<awardinfo>第1名：10000豆 第2名：8000豆 第3名：5000豆 第4-6名：3000豆</awardinfo>
<awards>
<items rank="1">
<prize dataid="15" value="10000"/>
</items>
<items rank="2">
<prize dataid="15" value="8000"/>
</items>
<items rank="3">
<prize dataid="15" value="5000"/>
</items>
<items rank="4">
<prize dataid="15" value="3000"/>
</items>
</awards>
</root>
]]
function Dapi:StaticAwards(gameid, roomid, callback)
    local url = dapi_ .. "/static/data/game_" .. gameid .. "/awards_" .. roomid .. ".xml";
    return Http:Get(url, callback);
end

-- 获取房间配置数据
function Dapi:StaticRoomConfig(gameid, roomid, callback)
    local url = dapi_ .. "/static/data/game_" .. gameid .. "/roomconfig_" .. roomid .. ".xml";
    return Http:Get(url, callback);
end


-- notice/list 获取短信验证码
-- POST
-- 所需的额外参数
-- last (int)-- 上次列表拉取时的最后一条消息的ID，如果是首次拉取请传0
-- 额外返回参数
-- list (array)
-- 消息列表，所含键值如下
-- id (int)
-- 消息ID
-- status (int)
-- 之前是否拉取过该消息，0:未拉取过，1:已拉取过
-- time (string)
-- 消息发布时间
-- title (string)
-- 消息标题
-- body (string)
-- 消息内容

-- count (int)
-- 本次拉取的消息数量
-- last (int)
-- 最后一条消息的ID，请在翻页操作中将此值回传
function Dapi:NoticeList(callback)
    -- if checkvalues_(last) then
    local url = getUserApi_("/notice/list")
    local data = { last = last }
    table.merge(data, getToken_())
    -- Http:Post(url,callback,data,true)
    Http:Post(url, errorhandler_(callback), data, true)
    -- end
end

-- msg/list 获取短信验证码
-- POST
-- 所需的额外参数
-- last (int)-- 上次列表拉取时的最后一条消息的ID，如果是首次拉取请传0
-- 额外返回参数
-- list (array)
-- 公告列表，所含键值如下
-- id (int)
-- 公告ID
-- time (string)
-- 公告发布时间
-- title (string)
-- 公告标题
-- body (string)
-- 公告内容
-- count (int)
-- 本次拉取的公告数量
function Dapi:MsgList(last, callback)
    if checkvalues_(last) then
        local url = getUserApi_("/msg/list")
        local data = { last = last }
        table.merge(data, getToken_())
        -- Http:Post(url,callback,data,true)
        Http:Post(url, errorhandler_(callback), data, true)
    end
end


-- 所属子域-- payapi
-- 接口名称-- order/new
-- 功能描述-- 充值下单
-- 请求方式-- POST
-- 所需的额外参数
-- type (string)-- 充值方式
-- wechat : 微信支付
-- alipay_client : 支付宝
-- unionpay_client : 银联支付
-- appstore : 苹果AppStore
-- roomid (integer)-- 充值时玩家所在的房间ID, 没有或大厅为0
-- money (integer)-- 充值金额，单位为：分
-- virtual (integer)-- 是否充值为虚拟货币，1:表示充值为吉祥/微乐币,0或不传:表示直接充值为豆
-- autobuy (integer)-- 是否自动使用本次充值的吉祥/微乐币购买等价道具(并赠送豆) 1.自动够买 0.
-- ingame (integer)-- 是否为游戏中充值，0:否，1:是
-- udid (string)-- 唯一标识符
-- debug (integer)-- 是否为调试模式，0否，1是
-- 额外返回参数
-- orderid (string)-- 16位商户订单号
-- ext (array)-- 扩展数据结构
function Dapi:OrderNew(args, callback, debug)
    args["debug"] = checkint(args.debug or debug);
    args.ingame = args.ingame or 0;
    args.roomid = args.roomid or 0;
    args.virtual = args.virtual or 0;
    args.autobuy = args.autobuy or 0;
    local deviceid = Helper.GetDeviceCode();
    args.udid = args.udid or deviceid;
    args.type = args.type or ""
    if checkvalues_(args.type, args.money, args.autobuy) then
        local url = getPayApi_("/order/new", CHANNEL_ID)
        FishGF.print("pay url:"..url)
        table.merge(args, getToken_())
        Http:Post(url, errorhandler_(callback), args, true)
    end
end

-- payapi-- 接口名称
-- currency/exchange-- 功能描述
-- 使用虚拟货币兑换道具，兑换过程中请显示接口的提示信息给用户
-- 请求方式-- POST
-- 所需的额外参数
-- propid (int)-- 要兑换的道具ID
-- expend (int)-- 兑换所要花费的虚拟货币数量
-- game_id (int)-- 兑换时所处的游戏ID
-- room_id (int)-- 兑换时所处的房间ID
-- udid (string)-- 设备码
-- 额外返回参数-- after (array)
-- 兑换
function Dapi:Exchange(propid, expend, game_id, room_id, callback)
    local args = {}
    args.propid = checkint(propid)
    args.expend = checkint(expend)
    args.game_id = checkint(game_id)
    args.room_id = checkint(room_id)
    args.udid = Helper.GetDeviceCode();
    table.merge(args, getToken_())
    local url = getPayApi_("/currency/exchange")
    Http:Post(url, errorhandler_(callback), args, true)
end


-- callback/appstore
-- payapi
-- 所属子-- payapi
-- 接口名称-- callback/appstore
-- 功能描述
-- App Store充值回调
-- 请求方式-- POST
-- 所需的额外参数-- orderid (string)
-- 由 order/new 接口返回的订单号-- retry (integer)
-- 重试次数, 订单重试回调请求的次数，从0开始-- receipt (string)
-- 苹果返回的支付凭证-- 额外返回参数
-- dataid (int)
-- 此次充值成功所给予的道具ID
-- value (int)
-- 给予的道具数量
function Dapi:VerifyIosReceipt(args, callback)
    args = checktable(args)
    args.retry = 5
    table.merge(args, getToken_())
    local url = getVerifyApi_("/callback/appstore")
    Http:Post(url, errorhandler_(callback), args, true)
end

--[[
* @brief 拉取游戏信息
* @parm gameIDList 游戏ID列表
* @parm callback 请求回调
]]
function Dapi:PullGameInfo(gameIDList, callback)
    -- 拼接地址
    local url = "https://client." .. WEB_DOMAIN .. "/gameinfos/" .. gg.IIF(IS_WEILE, 2, 1) .. "/" .. APP_ID .. "/" .. CHANNEL_ID .. "/"
    if type(gameIDList) == "table" then
        for k, v in pairs(gameIDList) do
            if k ~= 1 then
                url = url .. "," .. v
            else
                url = url .. v
            end
        end
    end

    -- 请求
    Http:Get(url, callback)
end

--[[
* @brief 意见反馈
* @parm gameId 游戏ID
* @parm roomId 房间ID
* @parm content 反馈文本
* @parm img 上传图片链接地址使用||连接两个URL地址
* @parm callback 请求回调
]]
function Dapi:FeedBack(udid, gameId, roomId, content, img, callback)

    local url = getUserApi_("/feedback/add")
    local data = { udid = udid, game_id = gameId or 0, room_id = roomId or 0, content = content or "", img = img or "" }
    table.merge(data, getToken_())
    Http:Post(url, errorhandler_(callback), data, true)
end

--[[
* @brief 图片云存储
* @parm fullpath 图片路径
]]
function Dapi:Cloudimg(fullpath, callback)

    local url = getUserApi_("/upload/cloudimg")
    Http:UploadFile(url, errorhandler_(callback), fullpath, getToken_())
end

--客服地址
--https://chat.jixiang.cn:8080/auth?app_id={APP_ID}&channel_id={渠道ID}&code={加密数据}
--加密密串，密串内容为：id={用户ID}&version={客户端版本号}&region={所选地区代码}&ui={UI界面标识符}，拼接后通过AuthCode算法进行加密
function Dapi:GeServicetUrl(code)
    local userid = 0
    if hallmanager then
        userid = checkint(hallmanager.userinfo.id)
    end
    local region = 0
    local codeparam = string.format("id=%d&version=%s&region=%d&ui=%s", userid, gg.GetHallVerison(), region, code)
    print("codeparam = "..codeparam)
    local cryptdata = Helper.CryptStr(codeparam, URLKEY)
    local newcryptdata = Helper.StringReplace(Helper.StringReplace(cryptdata, "/", "-"), "+", ",")
    local url = "https://chat." .. WEB_DOMAIN .. ":8080/auth?app_id=" .. APP_ID .. "&channel_id=" .. CHANNEL_ID .. "&code=" .. newcryptdata
    printf("service url =" .. url)
    return url
end

-- task/award
-- userapi
-- 所属子-- userapi
-- 接口名称-- task/award
-- 功能描述
-- 领取任务完成奖励
-- 请求方式-- POST
-- 所需的额外参数-- id (int) 任务ID
-- 额外返回参数-- time (int)
-- 距任务到期所剩的秒数，仅在领取限时类任务奖励时返回（出现这个参数的原因是可能用户本地已完成了，
-- 但却超过了服务器到期时间的临界点，此时服务器会给予错误提示，并为用户重新开启一个新的限时任务）
function Dapi:TaskAward( id, callback )
    if checkvalues_(id) then
        local url = getUserApi_("/task/award")
        local data = { id = id }
        table.merge( data, getToken_() )
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- task/activate
-- userapi
-- 所属子-- userapi
-- 接口名称-- task/activate
-- 功能描述
-- 激活任务
-- 请求方式-- POST
-- 所需的额外参数-- id (int) 任务ID，
-- 初始值,完成条件的前当值，限时类任务必传-- val (int)  
-- 额外返回参数-- time (int)
-- 距任务到期所剩的秒数，仅在激活限时类任务时返回
function Dapi:TaskActivate( id, val, callback )
    local url = getUserApi_("/task/activate")
    local data = {}
    data.id = id
    data.val = val
    table.merge( data, getToken_() )
    Http:Post(url, errorhandler_(callback), data, true)
end

-- pack/buy
-- userapi
-- 所属子-- userapi
-- 接口名称-- pack/buy
-- 功能描述
-- 购买礼包，用于购买每日礼包及一本万利礼包
-- 请求方式-- POST
-- 所需的额外参数-- id (int) 任务ID
function Dapi:PackBuy( id, callback )
    if checkvalues_(id) then
        local url = getUserApi_("/pack/buy")
        local data = { id = id }
        table.merge( data, getToken_() )
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

-- pack/award
-- userapi
-- 所属子-- userapi
-- 接口名称-- pack/award
-- 功能描述
-- 领取礼包奖励，用于领取一本万利礼包每日的奖励
-- 请求方式-- POST
-- 所需的额外参数-- id (int) 任务ID
function Dapi:PackAward( id, callback )
    if checkvalues_(id) then
        local url = getUserApi_("/pack/award")
        local data = { id = id }
        table.merge( data, getToken_() )
        Http:Post(url, errorhandler_(callback), data, true)
    end
end

function Dapi:feedBackUrl(callback)
    local url = getUserApi_("/feedback/old");
    local data = getToken_();
    Http:Post(url, errorhandler_(callback), data, true)
end

function Dapi:thirdLogin(channel, data, callback)
    data.type = channel

	local url = getThirdApi_("/login");
	Http:Post(url, callback, data, true)
end

function Dapi:getLoginNotice(url, data, callback, isEncrypt)
    Http:Post("userapi-fish.weile.com/loginNotice/list", errorhandler_(callback), data, isEncrypt);
end

return Dapi;