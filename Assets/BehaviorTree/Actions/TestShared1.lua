require("Base/Action")
BT.TestShared1 = {
    base = BT.Action,
}
local this = BT.TestShared1

this.__index = this
setmetatable(this,this.base)

function BT.TestShared1:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    o.sharedVal = Const.Empty
    o.val = Const.Empty
    return o
end

function BT.TestShared1:OnStart()
    self.sharedVal = self.bTree.sharedData:GetData("testVal")
    self.val = "init1"
end

function BT.TestShared1:OnUpdate()
    if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Q) then
        self.sharedVal.val = "sharedVal: by TestShared1"
        self.val = "val: by TestShared1"
    end

    LogMgr.Normal("1: "..(self.sharedVal.val and self.sharedVal.val or Const.Empty).." "..self.val)
    return BT.ETaskStatus.Success
end