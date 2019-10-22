require("Base/Action")
BT.Log = {
    base = BT.Action,
}
local this = BT.Log

this.__index = this
setmetatable(this,this.base)

function BT.Log:New(name,content)
    local o = this.base:New(name)
    o.sContent = content or Const.Empty
    setmetatable(o,this)
    return o
end

function BT.Log:OnUpdate()
    LogMgr.Normal(self.sContent)
    return BT.ETaskStatus.Success
end