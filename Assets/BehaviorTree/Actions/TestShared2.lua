require("Base/Action")
BT.TestShared2 = {
    base = BT.Action,
}
local this = BT.TestShared2

this.__index = this
setmetatable(this,this.base)

function BT.TestShared2:New(name)
    local o = this.base:New(name)
    setmetatable(o,this)
    o.sharedVal = Const.Empty
    o.val = Const.Empty
    return o
end

function BT.TestShared2:OnStart()
    self.sharedVal = self.bTree.sharedData:GetData("testVal")
    self.val = "init2"
end

function BT.TestShared2:OnUpdate()
    if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.W) then
        self.sharedVal.val = "sharedVal: by TestShared2"
        self.val = "val: by TestShared2"
    end

    LogMgr.Normal("2: "..(self.sharedVal.val and self.sharedVal.val or Const.Empty).." "..self.val)
    return BT.ETaskStatus.Success
end