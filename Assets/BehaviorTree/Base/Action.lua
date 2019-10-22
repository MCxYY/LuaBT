require("Base/Task")
BT.Action = {
    base = BT.Task,
}
local this = BT.Action

this.__index = this
setmetatable(this,this.base)

function BT.Action:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end