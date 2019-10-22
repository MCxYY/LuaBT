require("Base/Composite")
BT.Selector = {
    base = BT.Composite,
}
local this = BT.Selector

this.__index = this
setmetatable(this,this.base)

function BT.Selector:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end

function BT.Selector:MaxChildCount()
    return 2
end

function BT.Selector:CheckChildCount()
    if self.base.CheckChildCount(self) == false or #self.tChildTaskList ~= self:MaxChildCount() then
        return false
    end
    return true
end

function BT.Selector:OnChildExcuted(status)
    self.eStatus = status
    if status == BT.ETaskStatus.Failure then
        if self.iCurChildIndex ~= #self.tChildTaskList then
            self.iCurChildIndex = self.iCurChildIndex + 1
            self.eStatus = BT.ETaskStatus.Running
        end
    end
    return self.eStatus
end

function BT.Selector:OnConditionalAbort()
    self:OnEnd()
end

function BT.Selector:OnEnd()
    self.eStatus = BT.ETaskStatus.Inactive
    self.iCurChildIndex = 1
end