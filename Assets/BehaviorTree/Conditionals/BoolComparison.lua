require("Base/Conditional")
BT.BoolComparison = {
    base = BT.Conditional,
}
local this = BT.BoolComparison

this.__index = this
setmetatable(this,this.base)

function BT.BoolComparison:New(name,val1,val2)
    local o = this.base:New(name)
    o.bVal1 = val1 or false
    o.bVal2 = val2 or false
    setmetatable(o,this)
    return o
end

function BT.BoolComparison:OnUpdate()
    if self.bVal1 == self.bVal2 then
        return BT.ETaskStatus.Success
    else
        return BT.ETaskStatus.Failure
    end
end