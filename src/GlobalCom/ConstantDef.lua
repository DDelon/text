cc.exports.FishCD = {}

--方位
FishCD.DIRECT = {
    LEFT_DOWN = 1;
    RIGHT_DOWN = 2;   
    RIGHT_UP = 3;
    LEFT_UP = 4;
}

FishCD.TAG = {
	WAIT_NET_CALLBACK = 1001;
    EFFECT_LAYER_TAG = 8887;
    UI_LAYER_TAG = 8888;
    PAY_VIEW_TAG = 8999;
    RANK_WEB_TAG = 9001;
}

FishCD.FRIEND_SKILL_ID = {
    FIRE = 1;
    CRAZY = 2;
    AIM = 3;
    CURSE = 4;
    WEAK = 5;
    DISPEL  =6;
}

FishCD.ViewMessageType = {
    HALL_HALL_INFO = 1110,
    HALL_SET_PLAYER_INFO = 1111,
    HALL_DIAL_END = 1113,
    HALL_VIPDIAL_END = 1114,
    HALL_MONTH = 1115,
    HALL_ALM_INFO = 1116,
    HALL_ALM_RESULT = 1117,
    HALL_ALM_RESULT = 1118,
    HALL_BAG_BUY = 1119,
    HALL_ACCOUNT = 1120,
    HALL_CHANGE_NICK = 1121,
    HALL_UNREADMAILS = 1122,   
    HALL_MAILS_DATA = 1123, 
    HALL_MARK_MAILS_READ = 1124,   
    HALL_FORGED = 1125,
    HALL_DECOMPOSE = 1126, 
    HALL_RECEIVE_PHONE_FARE = 1127,   
    HALL_GET_FRIENDSTATUS = 1128,   
    HALL_CREATE_FRIENDSTATUS = 1129,   
    HALL_CREATE_FRIEND_READY = 1130,
    HALL_JOIN_FRIEND_ROOM = 1131,
    HALL_ISOPEN_FRIEND_ROOM = 1132,
    HALL_WECHAT_SHARE_RESULT = 1133,
    HALL_INVITE_RESULT = 1134,
}

--是否内网
FishCD.IS_INTRANET = true;
-- FishCD.GAME_STEAE = 0;  --0外网   1，内网，无秘籍    2，内网，有秘籍

FishCD.WIN_SIZE = cc.Director:getInstance():getWinSize();
FishCD.BASE_WIN_SIZE = cc.size(1280, 720)
FishCD.BASE_WIN_RECT = cc.rect(0,0,1280,720)

FishCD.M_PI = 3.14159265358979323846;
FishCD.M_PI_2 = 1.57079632679489661923;


--帧数延迟的最大上限
FishCD.FRAME_DELAY_UP = 40;

--对象池 鱼的节点个数
FishCD.FISH_POOL_NUM = 300;
--对象池 子弹的节点个数
FishCD.BULLET_POOL_NUM = 100;

FishCD.FishState = {
    MOVE = 1;
    PAUSE = 2;
    DEATH = 3;
    FREEZE = 4,
    START_FREEZE = 5,
};

FishCD.LOGIN_TYPE_NONE		=0;--//!<无任何操作
FishCD.LOGIN_TYPE_BY_NAME 	=1;--//!<根据用户名登陆
FishCD.LOGIN_TYPE_BY_UNNAME	=2;--//!<匿名登陆
FishCD.LOGIN_TYPE_GET_ROLE_LIST	=3;--//!<拉取用户列表
FishCD.LOGIN_TYPE_ALLOC_USER	=4;--//!<分配新帐号
FishCD.LOGIN_TYPE_BY_THIRD_LOGIN = 5;--第三方登陆

FishCD.LOADING_C_COUNT = 70

--提示消息类型
FishCD.MODE_MIN_OK_ONLY = 1
FishCD.MODE_MIDDLE_OK_ONLY = 2
FishCD.MODE_MIDDLE_OK_CLOSE = 3
FishCD.MODE_MIDDLE_OK_CLOSE_HOOK = 4

--超时运动tag
FishCD.OVER_TIME_ACT_TAG = 8978

--超时时间
FishCD.OVER_TIME = 30

--心跳延迟时间
FishCD.HEART_DELAYTIME = 10

--鱼组Tag
FishCD.FISH_ARRAT = 100;

--子弹时间
FishCD.BULLET_TIME = 3.333333333

--帧时间间隔
FishCD.FRAME_TIME_INTERVAL = 0.05

--点间隔帧数
FishCD.POINT_INTERVAL_FRAME = 3

--鱼巢提前清场的时间
FishCD.FISH_GROUP_COMING_CLEAR_TIME = 3;

--玩家炮台发射频率
FishCD.PLAYER_SHOOT_INTERVAL = 0.5;

--语言类型
FishCD.LanguageType = "ch";


--炮塔坐标
FishCD.posTab = {};
FishCD.posTab[FishCD.DIRECT.LEFT_UP]       = cc.p(332.43, 720);
FishCD.posTab[FishCD.DIRECT.LEFT_DOWN]     = cc.p(332.43, 0);
FishCD.posTab[FishCD.DIRECT.RIGHT_UP]      = cc.p(945.05, 720);
FishCD.posTab[FishCD.DIRECT.RIGHT_DOWN]    = cc.p(945.05, 0);

--收取道具坐标
FishCD.aimPosTab = {};
FishCD.aimPosTab[FishCD.DIRECT.LEFT_UP]    = cc.p(332.43, 680);
FishCD.aimPosTab[FishCD.DIRECT.LEFT_DOWN]  = cc.p(332.43, 40);
FishCD.aimPosTab[FishCD.DIRECT.RIGHT_UP]   = cc.p(945.05, 680);
FishCD.aimPosTab[FishCD.DIRECT.RIGHT_DOWN] = cc.p(945.05, 40);

--转盘速度
FishCD.DIAL_SPEED  = 680

--光环旋转速度
FishCD.LIGHT_SPEED = 60

--大厅房间图标间隔
FishCD.ROOM_DIS = 320

--大厅常量
FishCD.ROOMTYPE_TAG_01 = 1   --新手房
FishCD.ROOMTYPE_TAG_02 = 2   --中级房
FishCD.ROOMTYPE_TAG_03 = 3   --高级房
FishCD.ROOMTYPE_TAG_04 = 4   --朋友场
FishCD.ROOMTYPE_TAG_05 = 5   --千倍场

FishCD.BAG_NULL_BOX  = 1000000     --背包的空格子

--游戏技能ID
FishCD.SKILL_TAG_FREEZE     = 3  --冰冻
FishCD.SKILL_TAG_LOCK       = 4	 --锁定
FishCD.SKILL_TAG_CALLFISH   = 5  --神灯
FishCD.SKILL_TAG_BOMB       = 6  --核弹
FishCD.SKILL_TAG_TIMEREVERT = 14 --时光倒流
FishCD.SKILL_TAG_MISSILE    = 15 --导弹
FishCD.SKILL_TAG_SUPERBOMB  = 16 --氢弹
FishCD.SKILL_TAG_VIOLENT    = 17 --狂暴

FishCD.SKILLS = {
    FishCD.SKILL_TAG_FREEZE,
    FishCD.SKILL_TAG_LOCK,
    FishCD.SKILL_TAG_CALLFISH,
    FishCD.SKILL_TAG_BOMB,
    FishCD.SKILL_TAG_TIMEREVERT,
    FishCD.SKILL_TAG_MISSILE,
    FishCD.SKILL_TAG_SUPERBOMB,
    FishCD.SKILL_TAG_VIOLENT
}

--道具ID
FishCD.PROP_TAG_01  = 1     --鱼币
FishCD.PROP_TAG_02  = 2     --水晶
FishCD.PROP_TAG_03  = 3     --冰冻
FishCD.PROP_TAG_04  = 4     --锁定
FishCD.PROP_TAG_05  = 5     --神灯
FishCD.PROP_TAG_06  = 6     --核弹
FishCD.PROP_TAG_07  = 7     --烈焰结晶
FishCD.PROP_TAG_08  = 8     --寒冰结晶
FishCD.PROP_TAG_09  = 9     --狂风结晶
FishCD.PROP_TAG_10  = 10    --厚土结晶
FishCD.PROP_TAG_11  = 11    --结晶能量
FishCD.PROP_TAG_12  = 12    --奖券
FishCD.PROP_TAG_13  = 13    --房间卡
FishCD.PROP_TAG_14  = 14    --时光沙漏
FishCD.PROP_TAG_15  = 1001  --房间卡（当日）
FishCD.PROP_TAG_16  = 2001  --VIP经验
FishCD.PROP_TAG_17  = 2002  --月卡
FishCD.PROP_TAG_18  = 15    --导弹
FishCD.PROP_TAG_19  = 16    --氢弹
FishCD.PROP_TAG_20  = 17    --狂暴
FishCD.PROP_TAG_21  = 18    --元宝
FishCD.PROP_TAG_22  = 1002  --潮汐之音（体验卡）
FishCD.PROP_TAG_23  = 1003  --火焰之翼（体验卡）


FishCD.SKILLS = {
    FishCD.SKILL_TAG_FREEZE,
    FishCD.SKILL_TAG_LOCK,
    FishCD.SKILL_TAG_CALLFISH,
    FishCD.SKILL_TAG_BOMB,
    FishCD.SKILL_TAG_TIMEREVERT,
    FishCD.SKILL_TAG_MISSILE,
    FishCD.SKILL_TAG_SUPERBOMB,
    FishCD.SKILL_TAG_VIOLENT
}

--限时炮台列表
FishCD.TASTE_CANNON = {
    FishCD.PROP_TAG_22,
    FishCD.PROP_TAG_23
}

FishCD.FRIEND_INDEX = 10000;                    --朋友场道具增加的id索引
FishCD.PROP_TAG_SCORE = FishCD.FRIEND_INDEX + 100    --积分
FishCD.PROP_TAG_USED_BULLET = FishCD.FRIEND_INDEX + 101   --已用子弹个数

FishCD.PROP_TAG_BULLET = FishCD.FRIEND_INDEX + 7   --子弹个数

--朋友场道具ID
FishCD.FRIEND_PROP_01   = 1   --火力
FishCD.FRIEND_PROP_02   = 2   --狂暴
FishCD.FRIEND_PROP_03   = 3   --瞄准
FishCD.FRIEND_PROP_04   = 4   --诅咒
FishCD.FRIEND_PROP_05   = 5   --虚弱
FishCD.FRIEND_PROP_06   = 6   --驱散

--技能锁定时间
FishCD.LOCK_TIME = 30
--技能冰冻时间
FishCD.FREEZE_TIME = 10

FishCD.PAY_EVENT = {}
FishCD.PAY_EVENT.ON_PAY_RESULT = "event_on_pay_result" --支付结果

 FishCD.__LAYOUT_COMPONENT_NAME = "__ui_layout"

 FishCD.WEILE_PAY_PLATFORM = "WEILE";

FishCD.RANK_LAYER           = 3001 -- 排行榜层
FishCD.ORDER_SYSTEM_MESSAGE = 3000 -- 系统提示框
FishCD.ORDER_LOADING        = 2500 -- 进度条
FishCD.ORDER_GAME_MESSAGE   = 2000 -- 游戏提示框
FishCD.HALL_RECEIVE_UPDATE_NOTICE = 1999 --大厅公告
FishCD.ORDER_LAYER_TRUE     = 1000 -- 游戏长时间存在的层
FishCD.ORDER_LAYER_VIRTUAL  = 800 -- 游戏短时间存在的层
FishCD.ORDER_GRAYBG         = 700 -- 灰背景
FishCD.ORDER_SCENE_UI       = 500 -- 场景UI
FishCD.ORDER_GAME_UI        = 100 -- 游戏UI

FishCD.ORDER_GAME_prop      = 90 --游戏掉落道具
FishCD.ORDER_GAME_nets      = 4 --网
FishCD.ORDER_GAME_bullet    = 3 --子弹
FishCD.ORDER_GAME_player    = 6 --玩家
FishCD.ORDER_GAME_lock      = 5 --锁定ui
FishCD.ORDER_GAME_fish      = 3 --鱼
FishCD.ORDER_GAME_emotion   = 7 --表情
FishCD.ORDER_GAME_magicprop = 7 --道具
FishCD.ORDER_GAME_task      = 7 --任务


FishCD.HALL_BTN_1  = 1 --背包
FishCD.HALL_BTN_2  = 2 --微信分享
FishCD.HALL_BTN_3  = 3 --签到
FishCD.HALL_BTN_4  = 4 --排行榜
FishCD.HALL_BTN_5  = 5 --vip转盘
FishCD.HALL_BTN_6  = 6 --救济金
FishCD.HALL_BTN_7  = 7 --锻造

FishCD.HALL_BTN_8  = 8 --vip特权
FishCD.HALL_BTN_9  = 9 --月卡
FishCD.HALL_BTN_10 = 10 --商店






