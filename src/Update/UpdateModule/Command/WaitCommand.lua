local WaitCommand = class("WaitCommand", require("Update/UpdateModule/Command/CommandBase"))

function WaitCommand.create()
    local obj = WaitCommand.new()
    obj:init()
    return obj
end

function WaitCommand:init()
    WaitCommand.super.init(self)
end

function WaitCommand:doCommand()
    print("wait command")
    
end


return WaitCommand