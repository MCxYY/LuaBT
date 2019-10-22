require("Base/Composite")
BT.Parallel = {
    base = BT.Composite,
}
local this = BT.Parallel

this.__index = this
setmetatable(this,this.base)

function BT.Parallel:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    o.tChildStatus = {}
    return o
end

function BT.Parallel:CanExcuteParallel()
    return true
end

function BT.Parallel:OnChildStart(relativeChildIndex)
    self.iCurChildIndex = self.iCurChildIndex + 1
    if self.eStatus == BT.ETaskStatus.Inactive then
        self.eStatus = BT.ETaskStatus.Running
    end
end

function BT.Parallel:OnChildExcuted(status, relativeChildIndex)
    if status == BT.ETaskStatus.Failure then
        self.eStatus = BT.ETaskStatus.Failure
    end
    if self.eStatus == BT.ETaskStatus.Failure then
        return self.eStatus
    end
    self.tChildStatus[relativeChildIndex] = status

    local bAllSuccess = true
    for i = 1, #self.tChildTaskList do
        if self.tChildStatus[i] ~= BT.ETaskStatus.Success then
            bAllSuccess = false
            break
        end
    end
    self.eStatus = bAllSuccess and BT.ETaskStatus.Success or BT.ETaskStatus.Running
    return self.eStatus
end

function BT.Parallel:OnConditionalAbort()
    self:OnEnd()
end

function BT.Parallel:OnEnd()
    self.eStatus = BT.ETaskStatus.Inactive
    self.tChildStatus = {}
    self.iCurChildIndex = 1
end