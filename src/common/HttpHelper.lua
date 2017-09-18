-- Author: lee
-- Date: 2016-08-25 10:43:06
local M = {}

--http事件表
local e = {};

local HTTPS_ = "https"
local HTTP_ = "http"

local function startwith_(source, str)
    local len = string.len(str)
    return string.lower(string.sub(source, 1, len)) == str
end

local function errorhandler_(http, msg)
    printf("http errorhandler_" .. tostring(msg))
    if http.callback then
        http.callback(http.code, msg)
    end
    http:Release();
end

--与服务器连接断开
-- function e.OnHttpClose(http,nErr)
-- 	local err_msg= "[错误] 与服务器连接失败,url:"..http.url
-- 	errorhandler_(http,err_msg) 
-- end

--请求错误
function e.OnHttpError(http, err)
    local err_msg = string.format("[错误] code:[%s],msg:%s,url:%s", tostring(http.code), err, http.url)
    errorhandler_(http, err_msg)
end

--请求完毕  {"msg":"token was empty","status":131}
function e.OnHttpComplete(http)
    printf("[完成],code:" .. tostring(http.code) .. ",url:" .. http.url);
    if http.callback then
        http.callback(nil, http:GetData())
    end
    http:Release();
end

-- 下载进度变化
function e.OnHttpDataArrival(http, size, dowanload, speed)
    if http and http.onProgressChanged then
        http.onProgressChanged(size.downloadobj, speed)
    end
end

-- 加密后的字符串替换处理将其中的 “/” 替换为 “-”，将 “+” 替换为 “,”。结果为：
local function cryptencode_(crypt)
    crypt = Helper.StringReplace(Helper.StringReplace(crypt, "/", "-"), "+", ",")
    return crypt
end

-- 解密 时字符串替换处理
local function cryptdecode_(crypt)
    local input = string.gsub(crypt, "%-", "/")
    return (string.gsub(input, "%,", "+"))
end

-- 拼接参数
local function joinParams_(params)
    local param_str = ""
    for k, v in pairs(checktable(params)) do
        param_str = param_str .. string.format("%s=%s&", tostring(k), tostring(v));
    end
    if param_str and string.len(param_str) > 1 then
        param_str = string.sub(param_str, 1, -2)
    end
    return param_str
end

-- 加密
local function encrypt_(params)
    local crypt = Helper.CryptStr(params, URLKEY);
    return cryptencode_(crypt)
end

-- -- 拼接参数
local function joinParams_(params)
    local param_str = ""
    for k, v in pairs(checktable(params)) do
        param_str = param_str .. string.format("%s=%s&", tostring(k), tostring(v));
    end
    if param_str and string.len(param_str) > 1 then
        param_str = string.sub(param_str, 1, -2)
    end
    return param_str
end

--生成 URL-encode 之后的请求字符串
function M:BuildQuery(params)
    return joinParams_(params)
end

function M:UploadFile(url, callback, path, params)
    local headers = headers or ""
    if startwith_(url, "://") then
        url = HTTPS_ .. tostring(url)
    end
    if params then
        url = url .. "/" .. encrypt_(joinParams_(params))
    end
    local http = CHttpClient.New();
    http.event = e;
    if callback then http.callback = callback; end
    http:AddRef();
    printf("---UploadFile url:" .. url)
    if http:StartUpload(url, path, "file", headers) then
        return http;
    elseif callback then
        callback("无法连接到服务器!");
    end
    http:Release();
end

-- get方式请求
function M:Get(url, callback, params, iscrypt)
    if params then
        if type(params) == "table" then
            params = joinParams_(params)
        end
        if iscrypt then
            url = url .. "/data/" .. encrypt_(params)
        else
            url = url .. "?" .. params
        end
    end
    return self:SendRequest(url, callback)
end

-- post 方式请求
function M:Post(url, callback, params, iscrypt)
    if params then
        if type(params) == "table" then
            params = joinParams_(params)
        end
        --printf("HttpPostParams:" .. params)
        if iscrypt then
            params = encrypt_(params)
          --  printf("HttpPostParams encrypt_:" .. params)
        end
        

    end
    return self:SendRequest(url, callback, "", "", true, params)
end

--[[
--发送请求
]]
function M:SendRequest(url, callback, filename, headers, post, data)
    post = post or false
    filename = filename or ""
    headers = headers or ""
    data = data or ""
    if startwith_(url, "://") then
        url = HTTPS_ .. tostring(url)
    end

    local http = CHttpClient.New();
    http.event = e;
    if callback then http.callback = callback; end
    http:AddRef();

    if http:Start(url, filename, headers, post, data, #data) then
        return http;
    elseif callback then
        callback("无法连接到服务器");
    end
    http:Release();
    return http
end

-- 添加http下载进度监听
function M:AddProgressListener(http, callback)
    if callback then
        http.onProgressChanged = callback
    end
end

function M:CancelRequest(http)
    if http then
        http:Cancel()
        http:Release();
    end
end

function M:encryptData(data)
    return encrypt_(joinParams_(data))
end

return M