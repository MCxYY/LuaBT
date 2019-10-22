BT.Inverter = {
    base = BT.Decorator,
}
local this = BT.Inverter

this.__index = this
setmetatable(this,this.base)

function BT.Inverter:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end

function BT.Inverter:OnStart()
    self.eStatus = BT.ETaskStatus.Inactive
end

function BT.Inverter:OnChildExcuted(status)
    if status == BT.ETaskStatus.Success then
        self.eStatus = BT.ETaskStatus.Failure
    elseif status == BT.ETaskStatus.Failure then
        self.eStatus = BT.ETaskStatus.Success
    else
        self.eStatus = status
    end
    return self.eStatus
end