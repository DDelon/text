
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/platform/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath())

LIB_SOCKET = require("socket.core")
LIB_CJSON = require("cjson")

require "config"

require "cocos.init"

--require所有global文件
require("Other/LoadFile");

local xpcallFun
if DEBUG > 0 then
    local target = cc.Application:getInstance():getTargetPlatform()
    if target == cc.PLATFORM_OS_WINDOWS then
        --LuaDebug配置
        local breakInfoFun
        breakInfoFun, xpcallFun = require("Other/LuaDebug")("localhost", 7003)
        --断点定时器添加，用于LuaDebug
        cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakInfoFun, 0.3, false)
    end
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    if xpcallFun then
        xpcallFun()
    end
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    math.randomseed(os.time());
    -- initialize director
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("HelloLua", FishCD.BASE_WIN_RECT)
        director:setOpenGLView(glview)
    end

   -- glview:setDesignResolutionSize(960, 640, cc.ResolutionPolicy.NO_BORDER)

    --turn on display FPS
    director:setDisplayStats(false)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)

    --require("app.MyApp"):create():run()
    FishGI.hotScene = require("Update/UpDateScene").create(URLKEY, APP_ID, CHANNEL_ID, HALL_WEB_VERSION)
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(FishGI.hotScene)
    else
        cc.Director:getInstance():runWithScene(FishGI.hotScene)
    end
    --LuaCppAdapter:getInstance():loadDataBin();
    --FishGI.mainManagerInstance:createLoginManager();

    
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
