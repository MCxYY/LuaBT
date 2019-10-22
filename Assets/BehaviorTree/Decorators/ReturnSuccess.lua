BT.ReturnSuccess = {
    base = BT.Decorator,
}
local this = BT.ReturnSuccess

this.__index = this
setmetatable(this,this.base)

function BT.ReturnSuccess:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end

function BT.ReturnSuccess:OnStart()
    self.eStatus = BT.ETaskStatus.Inactive
end

function BT.ReturnSuccess:OnChildExcuted(status)
    self.eStatus = BT.ETaskStatus.Success
    return self.eStatus
end