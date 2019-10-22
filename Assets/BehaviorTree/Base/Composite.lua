require("Base/ParentTask")
BT.Composite = {
    base = BT.ParentTask,
}
local this = BT.Composite

this.__index = this
setmetatable(this,this.base)

function BT.Composite:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    o.abortType = BT.EAbortType.None
    return o
end

function BT.Composite:SetAbortType(abortType)
    if abortType < BT.EAbortType.None or abortType > BT.EAbortType.Both then
        abortType = BT.None
        return
    end
    self.abortType = abortType
end