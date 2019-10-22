BT.Repeater = {
    base = BT.Decorator,
}
local this = BT.Repeater

this.__index = this
setmetatable(this,this.base)

function BT.Repeater:New(name)
    local o = this.base:New(name)
    o.iCount = 0
    o.iExecutionCount = 1
    o.bRepeatForever = false
    o.bEndOnFailure = false
    setmetatable(o,this)
    return o
end

function BT.Repeater:SetExecutionCount(val)
    self.iExecutionCount = val
end

function BT.Repeater:SetRepeatForever(val)
    self.bRepeatForever = val
end

function BT.Repeater:SetEndOnFailure(val)
    self.bEndOnFailure = val
end

function BT.Repeater:OnStart()
    self.iCount = 0
    self.eStatus = BT.ETaskStatus.Inactive
end

function BT.Repeater:OnChildExcuted(status)
    if status == BT.ETaskStatus.Failure then
        if self.bEndOnFailure then
            self.eStatus = BT.ETaskStatus.Failure
            return self.eStatus
        end
        self.iCount = self.iCount + 1
    elseif status == BT.ETaskStatus.Success then
        self.iCount = self.iCount + 1
    end

    if self.bRepeatForever or self.iCount < self.iExecutionCount then
        self.eStatus = BT.ETaskStatus.Running
    else
        self.eStatus = status
    end

    return self.eStatus
end