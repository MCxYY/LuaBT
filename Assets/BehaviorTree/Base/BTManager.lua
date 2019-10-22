require("Common/Common")
require("Base/Shared")

BT.Mgr = {
    treeList = {},
    globalSharedData = BT.Shared:New()

}
local this = BT.Mgr

function BT.Mgr.EnabledBT(bt)
    bt:EnabledBT()
end

function BT.Mgr.DisabledBT(bt)
    bt:DisabledBT()
end

function BT.Mgr.PauseBT(bt)
    bt:PauseBT()
end

function BT.Mgr.UnPauseBT(bt)
    bt:UnPauseBT()
end

function BT.Mgr.RestartBT(bt)
    bt:RestartBT()
end

function BT.Mgr.DelTree(bt)
    this.DisabledBT(bt)
    Common.TableRemove(this.treeList,bt)
end
-----------------------runtime----------------------
function BT.Mgr.Update()
    if this.treeList == nil then
        return
    end

    for k,v in pairs(this.treeList) do
        if v.eStatus == BT.EBTreeStatus.Active then
            if v:Update() ~= BT.ETaskStatus.Running then
                this.DisabledBT(v)
            end
        end
    end
end






