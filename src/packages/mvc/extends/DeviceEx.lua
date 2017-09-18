--  android  ios  通用接口
-- Author: lee  
-- Date: 2016-09-12 11:12:06
-- 
local CLASS_NAME = 
{
    android="",
    ios="AppController",
    windows="",
}
local DeviceEx = device
--pickertype camera album library

local function getclassname_()    
    return  CLASS_NAME[device.platform]
end

function DeviceEx.callImagePicker(type,callback,allowedit)
    if device.platform =="android" then
        error("无效的平台");
    elseif device.platform =="ios" then
        local luaoc=require("cocos.cocos2d.luaoc")
        local args={pickertype=type,listener=callback,allowedit=allowedit }
        local ok, ret = luaoc.callStaticMethod(getclassname_(), "callImagePicker", args)
        if ok then
            --print_r(ret)
        end
    end
end

-- 设备电量 
function DeviceEx.getBatteryLevel()
    if device.platform =="android" then
     
    elseif device.platform =="ios" then
  
    else
       return -1
    end
end

-- 应用名字
function DeviceEx.getAppName()

end

-- 应用图标
function DeviceEx.getAppIcon()

end
-- 应用签名信息
function DeviceEx.getAppSign()

end

-- 应用包名
function DeviceEx.getAppPackageName()

end

-- 获取设备名字

function DeviceEx.getDeviceName()

end


--[[
 屏幕方向
 @ return 0 横屏 1 竖屏
  gg.SCREEN_ORIENTATION_LANDSCAPE=0
 gg.SCREEN_ORIENTATION_PORTRAIT=1
]]
function DeviceEx.getScreenOrientation()

end

--[[--

返回设备的 OpenUDID 值
OpenUDID 是为设备仿造的 UDID（唯一设备识别码），可以用来识别用户的设备。
但 OpenUDID 存在下列问题：
-   如果删除了应用再重新安装，获得的 OpenUDID 会发生变化
-   iOS 7 不支持 OpenUDID
@return string 设备的 OpenUDID 值

]]
function DeviceEx.getOpenUDID()

end

--[[--
震动
@param int millisecond 震动时长(毫秒) (设置震动时长仅对android有效，默认200ms) 

android 需要添加震动服务权限
<uses-permission android:name="android.permission.VIBRATE" />  
]]

function DeviceEx.vibrate(millisecond)
end

--[[--
用浏览器打开指定的网址
-- 打开网页
device.openURL("http://xxx.ccc.w/")
-- 打开设备上的拨号程序
device.openURL("tel:123-456-7890")
@param string 网址，邮件，拨号等的字符串
]]
function DeviceEx.openURL(url)
    if DEBUG > 1 then
        printInfo("device.openURL() - url: %s", tostring(url))
    end
end


function DeviceEx.showAlert(title, message, buttonLabels, listener)
end

-- 安装apk包
function DeviceEx.installApk()

end

--[[--
取消正在显示的对话框。
提示：取消对话框，不会执行显示对话框时指定的回调函数。
]]
function DeviceEx.cancelAlert()
    if DEBUG > 1 then
        printInfo("device.cancelAlert()")
    end
end

--[[
安装安卓apk
]]
function DeviceEx.installApk(filename)
    assert(false);
    if device.platform ~="android" then
        error("无效的平台");
    end
end