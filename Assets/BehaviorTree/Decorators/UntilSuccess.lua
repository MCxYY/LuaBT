BT.UntilSuccess = {
    base = BT.Decorator,
}
local this = BT.UntilSuccess

this.__index = this
setmetatable(this,this.base)

function BT.UntilSuccess:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end

function BT.UntilSuccess:OnStart()
    self.eStatus = BT.ETaskStatus.Inactive
end

function BT.UntilSuccess:OnChildExcuted(status)
    if status == BT.ETaskStatus.Success then
        self.eStatus = status
    else
        self.eStatus = BT.ETaskStatus.Running
    end
    return self.eStatus
end