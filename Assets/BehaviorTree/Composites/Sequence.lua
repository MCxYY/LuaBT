require("Base/Composite")
BT.Sequence = {
    base = BT.Composite,
}
local this = BT.Sequence

this.__index = this
setmetatable(this,this.base)

function BT.Sequence:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end

function BT.Sequence:OnChildExcuted(status)
    self.eStatus = status
    if status == BT.ETaskStatus.Success and self.iCurChildIndex ~= #self.tChildTaskList then
        self.eStatus = BT.ETaskStatus.Running
        self.iCurChildIndex = self.iCurChildIndex + 1
    end
    return self.eStatus
end

function BT.Sequence:OnConditionalAbort()
    self:OnEnd()
end

function BT.Sequence:OnEnd()
    self.eStatus = BT.ETaskStatus.Inactive
    self.iCurChildIndex = 1
end