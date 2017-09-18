cc.exports.FishGI = {}

FishGI.eventDispatcher = require("Other/EventDispatcher").create()
--0外网   1，内网无秘籍   2，内网有秘籍  3.外网225测试房间
FishGI.SYSTEM_STATE = 0

--MainManager instance
FishGI.mainManagerInstance = require("MainManager").create();
FishGI.AudioControl = require("AudioManager/AudioControl").create();
FishGI.showLayerData = require("GlobalCom/showLayerData").create();
FishGI.GameEffect = require("GlobalCom/GameEffect").create();
FishGI.GameConfig = require("Other/GameConfig").create();
FishGI.serverConfig = require("luaconfig/serverconfig");
FishGI.WritePlayerData = require("GlobalCom/WritePlayerData").create();
--FishGI.payAdapter = require("pay/PayAdapter").create();
FishGI.payHelper = require("ThridPartySDK/pay/PayHelper").create();
--------------------平台
FishGI.Http = require("common/HttpHelper");
FishGI.Dapi = require("common/ApiHelper");
--FishGI.PayHelper = require("pay/weile/PayHelper");
FishGI.ShareHelper = require("ThridPartySDK/share/ShareHelper");
FishGI.WebUserData = require("common/WebUserData");

FishGI.FriendRoomManage = require("hall/FriendRoom/FriendRoomManage").new();
FishGI.GameTableData = require("GlobalCom/GameTableData").create();

--GameCenterSDK
if FishGF.isThirdSdk() then
    FishGI.GameCenterSdkBase = require("ThridPartySDK/SDKInterface")
    FishGI.GameCenterSdk = require("ThridPartySDK/Repository/"
        ..FishGI.GameCenterSdkBase.ChannelInfoList[FishGI.GameCenterSdkBase.ChannelIdList[CHANNEL_ID]][FishGI.GameCenterSdkBase.ChannelInfoIndex.lua_file_name]).new()
    FishGI.GameCenterSdkBase:initGcsdk()
end

------------------------------------
local messageDefine = require("Other/MessageDefine")
FishGI.gameNetMesProto = jmsg.create(messageDefine);

FishGI.myData = nil
FishGI.shop = nil;

FishGI.bulletCount = 0;

FishGI.curGameRoomID = 0;

FishGI.isPlayerFlip = false;

FishGI.isFishGroupCome = false;

FishGI.isOpenDebug = false;

FishGI.enterBackTime = 0;	--退到后台的时间差值

FishGI.PLAYER_STATE = 0;	--玩家状态   0，游客登录  1，账号登录

--当前游戏状态   
FishGI.GAME_STATE = 0;  --0,更新界面   1，登录界面   2，大厅    3，游戏内

--当前游戏状态   
FishGI.SERVER_STATE = 0;        --0,未开始   1，开始     2，游戏结算

FishGI.FRIEND_ROOM_STATUS = 0   --0不在朋友场内  1，创建朋友场， 2.加入朋友场 3.已经在朋友场内了  4.将要离开
--朋友场 roomId
FishGI.FRIEND_ROOMID = nil
--朋友场 roomNo
FishGI.FRIEND_ROOMNO = nil

--是否今天第一次登录
FishGI.ISFIRST_IN = false

--是否领取过每日VIP奖励
FishGI.IS_GET_VIP_REWARD = true

--转圈引用次数
FishGI.CIRCLE_COUNT = 0

--是否boss来临
FishGI.isBossComing = false

--是否正在特效
FishGI.isPlayEffect = false

--是否加载过资源
FishGI.ISLOADING_END = false

--是否充值中
FishGI.IS_RECHARGE = 0

--发送到c++的数据列表
FishGI.refreshDataList = {}

--游戏帧数
FishGI.frame = 0;

--子弹计数ID
FishGI.bulletNumMax = 25;

FishGI.scaleMin_ = 0
FishGI.scaleX_ = 0
FishGI.scaleY_ = 0

--c++中进度的索引，速度，是否完成
FishGI.loading_index = 0
FishGI.loading_sp = 1
FishGI.isloadingEnd = false
FishGI.deskId = 0;


FishGI.isAutoFire = false	--是否自动开炮
FishGI.isLock = false	--是否锁定中

FishGI.gameClientIsNil = false;	

--退出房间的方式	 nil 第一次进入大厅 0 正常退出 1超出房间高倍数被踢   2朋友场被踢   3朋友场解散   4朋友场结束
FishGI.exitType = nil;
FishGI.callFishCount = 1;
FishGI.nbombCount = 1;

FishGI.isNoticeVipDailCost = true
FishGI.isNoticeNBombCost = true

--是否开通月卡
FishGI.isGetMonthCard = false

FishGI.isExitRoom = false;

--是否提示断线
FishGI.isNoticeClose = true;

--朋友场技能id计数
FishGI.friendSkillCount = 1;

--时光沙漏
FishGI.isCurTimehour = false
FishGI.timehourRemain = 0
FishGI.timehourGlodCount = 0

--等待net的数据列表
FishGI.waitNetlist = {
    noIdCount = 0,
    Idlist = {},
};

--微信
FishGI.wechatShareType = nil    --0 正常分享    1 邀请好友   2 分享战绩
--是否开启微信
FishGI.isOpenWechat = true

--是否微信好友分享了
FishGI.isWechatShare = false

--重连次数
FishGI.connectCount = 0

--是否是测试屏蔽号
FishGI.isTestAccount = false;





