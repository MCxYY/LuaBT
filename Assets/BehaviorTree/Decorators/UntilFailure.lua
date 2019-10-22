BT.UntilFailure = {
    base = BT.Decorator,
}
local this = BT.UntilFailure

this.__index = this
setmetatable(this,this.base)

function BT.UntilFailure:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end

function BT.UntilFailure:OnStart()
    self.eStatus = BT.ETaskStatus.Inactive
end

function BT.UntilFailure:OnChildExcuted(status)
    if status == BT.ETaskStatus.Failure then
        self.eStatus = status
    else
        self.eStatus = BT.ETaskStatus.Running
    end
    return self.eStatus
end
