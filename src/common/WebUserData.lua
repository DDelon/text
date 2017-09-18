--
-- Author: lee
-- Date: 2016-09-10 16:42:06
--
--0--游客未激活
-- 1-- 已激活
-- 2-- 已绑定手机
-- 4-- 已绑定微信 
local ATTR_INACTIVE   =0
local ATTR_ACTIVITED  =1
local ATTR_BINDPHONE  =2
local ATTR_BINDWECHAT =4
local ATTR_BINDIDCARD =8


local UserData = {}
local localCfgFile = require("common/FileTable").New();
local writablePath = cc.FileUtils:getInstance():getWritablePath()

-- 本地配置路径变量
local localConfigPath ={}
local localCfgObj={}
local md5userid
local userWebData ={}
local isloaded_=false
local loadedCallback
--存储到文件
local function flush_()     
    localCfgFile:Save(localCfgObj, localConfigPath)    
end
 
-- 账号属性，二进制存储，各值含义如下：
-- 1-- 已激活
-- 2-- 已绑定手机
-- 4-- 已绑定微信
-- 8-- 已绑定身份证
-- notice (int)-- 未拉取的公告数量
-- usermsg (int)-- 未拉取的个人消息数量
-- popn (int)-- 强制弹出的公告ID
-- popm (int)-- 强制弹出的个人消息ID
-- popa (int)-- 强制弹出的活动ID
-- idcard (string)-- 身份证尾号后4位，仅在绑定身份证时返回
-- phone (string)-- 手机尾号后4位，仅在绑定手机时返回
 
-- icon (string)-- 分享图标
-- url (string)-- URL地址
-- taskver (int)-- 任务配置版本号
-- task array-- 任务状态数组，如下代码所示
-- {{
--         id=1, --任务ID
--         val=1, --当前任务进度值(整形), 注意此参数不一定存在
--         status=1, --任务状态, 1:不可用, 2:可用未激活, 3:已激活未完成, 4:已完成未领取, 5:已领取
--         awards={ -- 常规奖励，当任务类型为5时且奖励配置为空才会存在, 示意请参考task/config接口说明，
--             [1]={{15, 1000}, -- 奖励道具配置, 下标[1]为道具ID，下标[2]是数量
--                 {16, 10},{-1, 100} -- 奖励道具配置, 下标[1]为-1时, 表示奖励的是荣誉值
--             }
--         },
--         vip={ -- VIP附加奖励，当任务类型为5时且奖励配置为空才会存在, 示意请参考task/config接口说明
--             [1]={{15, 1000},{16, 10}},
--             [2]={{15, 2000},{16, 20}},
--             [3]={ {15, 4000},{16, 40}}
--         }
--     },
--     {
--         id=2,
--         status=3, },}

local function onuserinit_(data)
    userWebData.status=0x80000000  
    print("---------------000--------------------------------onuserinit_------------")
    FishGF.waitNetManager(false,nil,"web")
    if data.status==0 then
        table.merge(userWebData,data)  
        -- -- 拉取数据
        -- local mydata = require("hall.models.AnnounceData")
        -- mydata:pullData()

        -- -- 默认弹出公告窗口
        -- local noticeID = 37
        -- if noticeID then
        --     local itemData = mydata:GetDataById( noticeID )
        --     if itemData then 
        --         local pop = require("hall.views.announcement.AnnouncementDetailed"):create():pushInScene()
        --         pop:setData(itemData)
        --     end
        -- end 

        -- --帐号状态 
        local localtaskver=0
        if data.taskver> localtaskver then
            --todo  pull task config data
        end
        -- Web接口初始化成功 
        isloaded_=true
        if loadedCallback then
            loadedCallback()
            loadedCallback=nil
        end

        local isActivited = FishGI.WebUserData:isActivited();
        if isActivited then
            print("已经激活");
        end

        local isBindPhone = FishGI.WebUserData:isBindPhone();
        if isBindPhone then
            print("已经绑定");
        end
    else     
        if DEBUG>0 then
             FishGF.print("Web接口初始化失败，请联系东海！")
        end
    end

    if FishGI.hallScene ~= nil then
        if FishGI.hallScene.addHallNotice ~= nil then
            FishGI.hallScene:addHallNotice();
        end
    end
    
end


local function lazyInit_() 
    userWebData.status=checkint(userWebData.status)
    if userWebData.status>1 then
        userWebData.status=1
        FishGF.waitNetManager(true,nil,"web")
        FishGI.Dapi:UserInit(onuserinit_)
    elseif userWebData.status==1 then
     --todo 拉取数据中。。
        printf("拉取数据中。。。")
    end 
end

function UserData:initWithUserId(userid)
    userWebData.id=userid
    local md5id=Helper.Md5(userid)
    if md5userid ~= md5id then
        md5userid=md5id
        localConfigPath = writablePath ..tostring(md5userid)..".dat"
        localCfgObj=localCfgFile:Open(localConfigPath)
    end  
    self:initWebData()
end

function UserData:initWebData()
    userWebData.status=0x80000000
    isloaded_=false
    lazyInit_()
end

function UserData:checkLoaded(callback)
    if isloaded_ then
        callback()
        return true
    else
        lazyInit_()
        loadedCallback=callback
        return false
    end
end

--更新web 数据
function UserData:UpdateWebDate(key,value)
    lazyInit_()
    if key then
       userWebData[key]=value
    end
end

--获取当前用户id
function UserData:GetUserId()
    lazyInit_()
   return checkint(userWebData.id)
end

--获取当前用户任务版本号
function UserData:GetTaskVersion()
   return checkint(userWebData.taskver )
end

--获取任务表
-- id=1, --任务ID
--         val=1, --当前任务进度值(整形), 注意此参数不一定存在
--         status=1, --任务状态, 1:不可用, 2:可用未激活, 3:已激活未完成, 4:已完成未领取, 5:已领取
--         awards={ -- 常规奖励，当任务类型为5时且奖励配置为空才会存在, 示意请参考task/config接口说明，
--             [1]={
--                 {15, 1000}, -- 奖励道具配置, 下标[1]为道具ID，下标[2]是数量
--                 {16, 10},
--                 {-1, 100} -- 奖励道具配置, 下标[1]为-1时, 表示奖励的是荣誉值
--             }
--         },
--         vip={ -- VIP附加奖励，当任务类型为5时且奖励配置为空才会存在, 示意请参考task/config接口说明
--             [1]={
--                 {15, 1000},
--                 {16, 10}
--             },
--             [2]={
--                 {15, 2000},
--                 {16, 20}
--             },
--             [3]={
--                 {15, 4000},
--                 {16, 40}
--             }
--         }
function UserData:GetTaskTable()
    lazyInit_()
   return checktable(userWebData.task )
end

-- 获取充值类礼包配置
-- {
--     daily={ --每日礼包
--         {
--             id=1, -- 礼包ID, 3元礼包
--             status=0, -- 状态: 0:本日未购买, 4:本日已购买
--         },
--         {
--             id=2, -- 礼包ID, 12元礼包
--             status=0,
--         },
--         {
--             id=3, -- 礼包ID, vip12元礼包
--             status=0,
--         }
--     },
--     loop={ --一本万利礼包
--         {
--             id=4, -- 礼包ID, 7日礼包
--             status=0, -- 状态: -1:已过期, 0:未购买, 1:已购买, 2:已购买本日未领取, 3:已购买本日已领取, 4:已购买并全部领完
--         },
--         {
--             id=5, -- 礼包ID, 15日礼包
--             status=0,
--         },
--         {
--             id=6, -- 礼包ID, vip15日礼包
--             status=0,
--         }
--     }
-- }
function UserData:GetPackTable()
    lazyInit_()
   return checktable(userWebData.pack )
end

--获取分享数据表分享配置 return
-- id (string)-- 微信分享ID
-- pic (string)-- 仅分享图片时的图片地址，当此值不存在或为空时，按照老版本的链接方式进行分享；否则则使用此参数中的地址进行图片分享
-- text (string)-- 分享内容
-- icon (string)-- 分享图标
-- url (string)-- URL地址
function UserData:GetShareDataTable()
    lazyInit_()
   return checktable(userWebData.share  )
end

function UserData:GetWXShareAppId()
    lazyInit_()
   return checktable(userWebData.share).id
end

function UserData:GetUserData()
    lazyInit_()
   return checktable(userWebData)
end

function UserData:setUserData(key,val)
    userWebData[key] = val
end


--微信绑定
function UserData:isBindWx()
    lazyInit_()
   return  Helper.And(checkint(userWebData.attr),ATTR_BINDWECHAT)~=0
end

function UserData:isActivited()
    lazyInit_()
   return  checkint(userWebData.attr)>0
end

--手机激活
function UserData:isBindPhone()
    lazyInit_()
   return  Helper.And(checkint(userWebData.attr),ATTR_BINDPHONE)~=0
end

function UserData:isBindIdCard()
    lazyInit_()
     return  Helper.And(checkint(userWebData.attr),ATTR_BINDIDCARD)~=0
end

-- 绑定属性
function UserData:BindAttiribute(...)
    lazyInit_()
    local attr={...}
    if userWebData.attr and attr then
        for _,v in ipairs(attr) do
            userWebData.attr=Helper.Or(checkint(userWebData.attr),v)
        end        
    end 
end

--解绑属性
function UserData:unBindAttiribute(attr)
    lazyInit_()
    if userWebData.attr and attr then
        userWebData.attr=Helper.Xor(userWebData.attr,attr)
    end    
end

function UserData:GetUserMsgCount()
    lazyInit_()
   return checkint(userWebData.usermsg )  --未读消息数量
end

-- 未拉取的公告数量
-- usermsg (int)
function UserData:GetNoticeCount()
    lazyInit_()
    return checkint( userWebData.notice )        --公告数量
end

--获取身份证尾号-- idcard (string)
-- 身份证尾号后4位，仅在绑定身份证时返回
function UserData:GetIdCardSuffix()
    lazyInit_()
    return gg.IIF(userWebData.idcard == nil,"未激活","**********"..(userWebData.idcard or ""))
end

--获取手机号尾数
function UserData:GetPhoneSuffix()
    lazyInit_()
    return gg.IIF(userWebData.phone  == nil,"—","*******"..(userWebData.phone or ""))
end

--获取兑换话费人数
function UserData:GetExchangeTelCount()
    lazyInit_()
    return checkint(userWebData.c_tr)
end

--获取兑换微信红包人数
function UserData:GetExchangeWXRedPackCount()
    lazyInit_()
    return checkint(userWebData.c_rp)
end

function UserData:getFirstRechargeInfo()
    lazyInit_()
    return userWebData["fr"];
end

------------本地文件存储数据-----------------

--添加 数据表 k v 
function UserData:SetConfigKV(table)
    table.merge(checktable(localCfgObj),checktable(table))
    flush_()
end
--根据键值获取 配置
function UserData:getConfigByKey(key)
    return localCfgObj[key]
end
--根据键值删除 配置
function UserData:delConfigByKey(key)
    if key then
       localCfgObj[key]=nil
    end      
end

function UserData:Flush()
    return flush_()
end

return UserData