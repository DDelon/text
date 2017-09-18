--全局配置，内容为只读
SEARCH_SRC="src/"  --脚本文件搜索路径
IS_REVIEW_MODE = false;  --//审核模式默认状态

--是否是内网测试
IS_LOCAL_TEST = false

--域名前缀
PREFIX_DOMAIN = "-fish"

--//默认网址
WEB_DOMAIN = "weile.com";

--//热线电话
HOT_LINE ="4008-323-777"

--//默认游戏LOGO下载地址
APP_ICON_PATH = "http://assets.weile.com/icon/weile/";

-- 应用名字
APP_NAME="微乐棋牌"

IS_WEILE = true;

--0 吉祥 1 微乐
BRAND=1
--//应用ID
APP_ID = "264";
--//应用KEY
APP_KEY = "a2E9AcEAa5Dfec6EcA2A3eEDb36DC6a9";
--//渠道ID
CHANNEL_ID_LIST = {
    -- 官网
    weile = 200,
    -- 自运营
    tencent = 225,
    -- 百度
    baidu = 202,
    -- 小米
    mi = 205,
    -- oppo
    oppo = 207,
    -- 360
    qihu = 201,
    -- vivo
    vivo = 206,
    -- 华为
    huawei = 224,
    -- 金立
    jinli = 204,
    -- 联想
    lenovo = 208,
    -- 应用宝
    yyb = 210,
    --ios
    ios = 11,
    --今日头条
    jrtt = 723,
    --广点通
    gdt = 209,
}
CHANNEL_ID = CHANNEL_ID_LIST.tencent

REGION_CODE= 0  --地区代码

GAME_ID = 226;

URLKEY = APP_ID .. APP_KEY .. APP_ID;

WX_APP_ID_LOGIN="wxf27383f02b99b8c4" --微信登录appid

--  wechar: 微信支付
-- alipay_client : 支付宝
-- unionpay_client : 银联支付
-- appstore : 苹果AppStore

PAY_CONFIG={
	["wechat"]={},
	["alipay_client"]={
		partner="",
		email=" ",
		rsa_private="MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBANY3GTv3SaqX/zNMhf4at61rJg1Cm9GpdHujJ3N5LnEtjXL6BwtGUlPe1A+XOSXoqZB1BeOi+aiE6yHfNs643nIPCLsSAmKZSulrssCDjnPOG/MuL8lcOT8c+rbezeWYmS2sm6ynE2lXxNHEA5u1bP+okR/zEdJIB01YgZUFnTJ1AgMBAAECgYEAqhRBIs1qXdoks1Q0ptYLs9L4+VpDYSoL5AZcUmCKsS2buwgtA5Sn1RN8h4xnwWODDcD8FgrV8ijmj5QsbeF2KuCElg+p4g4Moo1A/xznXfDm0ATY+8IzChuQkBtGoBNW1E5PWD0+BkaEf0+FhJDKVzGRAE+JLEyFbTDS9uZ0XwECQQD51oV+utG3cfNqBnedcrO4z6hROUs0tn+y+PuKPZUlVCH09YEkGyDX1Z9fBIRaUCFNiApl/VDIEChpNkbskqphAkEA23+npV2ABGu/ODJ1Fuu/fdJYIPXSGdvu9OalBkP2EpcKulFAH3gklQRfbkp5EBSX7GCFQkBm021hOLKdGA0IlQJBAND1ycXLP2itWCfPrO/1ZbgnhuIYh3xZP8lTUh+3ji0ghx440ICAaCHdvGRehMx8xL3yELBpBM2wJfyJtxxbN0ECQDssmwGVx2Fpus9nqvFW9PTytBeOremSxUT4uRyLTdeNKLM6HFNfjF0wJJoTMbgIFT0AeGx3+ECfiEpEvN0zBlECQGZ9JA9y91mKJS8ZlJrDc2HTB/wphQf5w5Mp+JuKmAWCk5I+k0TYm/8eAD9zTCTDTfrFG/kn0E3L87sEJ3KKGEY="
	},
	["unionpay_client"]={mode="00"},
	["appstore"]={
		[1] = {
			[6] = "com.weile.buyu.money1",
			[12] = "com.weile.buyu.money2",
			[30] = "com.weile.buyu.money3",
			[50] = "com.weile.buyu.money4",
			[108] = "com.weile.buyu.money5",
			[328] = "com.weile.buyu.money6",
			[648] = "com.weile.buyu.money7"
        },
        [2] = {
            [6] = "com.weile.buyu.money8",
            [12] = "com.weile.buyu.money9",
            [30] = "com.weile.buyu.money10",
            [50] = "com.weile.buyu.money11",
            [108] = "com.weile.buyu.money12",
            [328] = "com.weile.buyu.money13",
            [648] = "com.weile.buyu.money14"
        },
        [3] = {
            [30] = "com.weile.buyu.money15"
        }
	}
}

-- 品牌ID：2
-- AppID：11
-- 渠道ID：200
-- AppKey：840336fab6e3edba46f3a547a337da39
HALL_APP_VERSION ={1,4,1}; --大厅版本好(C++版本号)
--热更新地址
function GET_UPDATE_URL(vert)  
    vert=vert or HALL_APP_VERSION
    local a_id = "/" .. APP_ID
    local c_id = "/" .. CHANNEL_ID
    local verstr="/"..table.concat(vert,".")
    local preStr = PREFIX_DOMAIN;
    local up_url = "http://client."..WEB_DOMAIN .. "/update"..a_id..c_id..verstr.. "/" .. Helper.GetDeviceCode()
    return up_url;
end

--大厅接口版本
AUTO_LOGIN=false           --帐号自动登录

TARGET_PLATFORM_CHANNEL=1  --当前渠道平台



FILE_VERSION = 1; --文件版本号(LUA版本号)

--大厅更新版本
HALL_UPDATE_VERSION = 1;


--功能开关(1:添加游戏;2:开启福袋)
FUN_SWITCH = 0;
--支付开关(1:微信;2:支付宝;4:银联;8:AppStore)
PAY_SWITCH = -1;


--//登陆服务器列表
loginserverlist = {
	--{url="game0.weile.com",port=6532},
	-- {url="game1.weile.com",port=6532},
	-- {url="game2.weile.com",port=6532},
	-- {url="game3.weile.com",port=6532},
	-- {url="game4.weile.com",port=6532},
};


--//微信分享ID
WXSHAREID = "";
--//微信支付ID
WXPAYID = "";



loginserverlist[1]={url="58.23.237.222",port=6532};

-- loginserverlist[2]={url="game1.weile.com",port=6532};
-- loginserverlist[3]={url="game2.weile.com",port=6532};
-- loginserverlist[4]={url="game3.weile.com",port=6532};
-- loginserverlist[1]={url="123.59.100.148",port=6532};
 -- loginserverlist[1]={url="192.168.10.8",port=6532};
function DAPIURL(url)
	return "http://dapi."..WEB_DOMAIN.."/"..url.."/app_id/"..APP_ID;
end

HALL_LOCAL_SETTING_FILE = Helper.writepath .."hallconfig.lua"

--执行本地配置，本地配置会覆盖全局配置
if Helper.IsFileExist(HALL_LOCAL_SETTING_FILE) then
	dofile(HALL_LOCAL_SETTING_FILE);
end

---检查大版本号 比较 更新 server>client
function CompareVersion(serVer,clientVer)
    assert(#clientVer>2,"版本号错误")
    assert(#serVer>2,"版本号错误")
    local bgt=clientVer[1]<serVer[1]
    if not bgt and clientVer[1]==serVer[1] then
        bgt= clientVer[2]<serVer[2]        
    end
    if not bgt and clientVer[2]==serVer[2] then
        bgt= clientVer[3]<serVer[3]        
    end
    return bgt
end

--热更新版本文件
local versionPath = cc.FileUtils:getInstance():getWritablePath()..SEARCH_SRC.."version.lua";
if cc.FileUtils:getInstance():isFileExist(versionPath) == false then
    versionPath = SEARCH_SRC.."version.lua"
end
HOT_VERSION_FILE=loadfile(cc.FileUtils:getInstance():fullPathForFilename(versionPath));

local ok,ver=pcall(HOT_VERSION_FILE)  --大厅动态版本号 热更新自动增加s
 if ok then
    HALL_WEB_VERSION = ver
 else
    HALL_WEB_VERSION = ver
 end
print("热更新版本："..table.concat(HALL_WEB_VERSION,"."))
 

HALL_LOCAL_SETTING_FILE = cc.FileUtils:getInstance():fullPathForFilename(SEARCH_SRC.."hallconfig.lua") 

--执行本地配置，本地配置会覆盖全局配置
if HALL_LOCAL_SETTING_FILE and Helper.IsFileExist(HALL_LOCAL_SETTING_FILE) then
    dofile(HALL_LOCAL_SETTING_FILE) 
end

if CompareVersion(HALL_APP_VERSION,HALL_WEB_VERSION) then
    -- todo 执行清理操作
    HALL_WEB_VERSION = HALL_APP_VERSION;
    print("clear---------------------------")
    Helper.DeleteFile(Helper.writepath.."res")
    Helper.DeleteFile(Helper.writepath.."src")
    Helper.DeleteFile(HALL_LOCAL_SETTING_FILE)        
end
