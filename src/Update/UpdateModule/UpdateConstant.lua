local UpdateConstant = {}
UpdateConstant["CommandType"] = {
    VERSION_CHECK = 1,          --版本检查
    GET_UPDATE_LIST = 2,        --获取更新文件列表
    SMALL_VERSION_UPDATE = 3,   --小版本热更新
    BIG_VERSION_UPDATE = 4,     --大版本更新
    WAIT = 5,                   --等待玩家操作
}

UpdateConstant["VersionCheckStatus"] = {
    LATEST = 0,                 --是最新版本
    MAINTENANCE = 9,            --维护
    UPDATE = 11,                --需要更新
}

UpdateConstant["UpdateType"] = {
    HOT_UPDATE = 1,             --lua热更新
    WHOLE_UPDATE = 2,           --整包大版本更新
}

UpdateConstant["Operator"] = {
    OP_ADD = 0,                 --添加
    OP_DEL = 1,                 --删除文件
    OP_REN = 2,                 --重命名
    OP_CLOSE = 3,               --关闭当前客户端
    OP_RUN = 4,                 --执行LUA代码
}

return UpdateConstant