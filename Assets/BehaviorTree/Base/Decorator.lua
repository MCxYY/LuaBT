require("Base/ParentTask")
BT.Decorator = {
    base = BT.ParentTask,
}
local this = BT.Decorator

this.__index = this
setmetatable(this,this.base)

function BT.Decorator:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    return o
end

function BT.Decorator:MaxChildCount()
    return 1
end