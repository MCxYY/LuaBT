BT.ReturnFailure = {
    base = BT.Decorator,
}
local this = BT.ReturnFailure

this.__index = this
setmetatable(this,this.base)

function BT.ReturnFailure:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end

function BT.ReturnFailure:OnStart()
    self.eStatus = BT.ETaskStatus.Inactive
end

function BT.ReturnFailure:OnChildExcuted(status)
    self.eStatus = BT.ETaskStatus.Failure
    return self.eStatus
end