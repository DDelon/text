cc.exports.log_level = 0
cc.exports.log = function ( ... )
    if cc.exports.log_level == 0 then
        return
    end

    local line = tostring(debug.getinfo(2).currentline)
    local funcname = tostring(debug.getinfo(2).name)

    local args = {...}
    local strArgs = funcname .. ":" .. line .. "\t"
    for i = 1, #args do
        local str = "\t" .. tostring(args[i])

        strArgs = strArgs .. str
    end

    print(strArgs)
end

cc.exports.loge = function ( ... )
    local args = {...}
    local strArgs = ""
    for i = 1, #args do
        local str = tostring(args[i]) .. "\t"

        strArgs = strArgs .. str
    end
    
    print(strArgs)
    print(debug.traceback())
end

