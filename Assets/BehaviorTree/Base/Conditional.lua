require("Base/Task")
BT.Conditional = {
    base = BT.Task,
}
local this = BT.Conditional

this.__index = this
setmetatable(this,this.base)

function BT.Conditional:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end