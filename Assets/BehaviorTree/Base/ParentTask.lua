require("Base/Task")
BT.ParentTask = {
    base = BT.Task,
}
local this = BT.ParentTask

this.__index = this
setmetatable(this,this.base)

function BT.ParentTask:New(name)
    local o = this.base:New(name)
    o.tChildTaskList = {}
    o.iCurChildIndex = 1
    o.eStatus = BT.ETaskStatus.Inactive
    setmetatable(o,this)
    return o
end

function BT.ParentTask:GetStatus()
    return self.eStatus
end

function BT.ParentTask:MaxChildCount()
    return 100
end

function BT.ParentTask:CheckChildCount()
    if #self.tChildTaskList == 0 then
        return false
    end
    return true
end

function BT.ParentTask:AddChild(task)
    if #self.tChildTaskList >= self:MaxChildCount() then
        LogMgr.Error(BT.ErrorRet.ChildCountMax.." ")
    end
    table.insert(self.tChildTaskList,task)
end

function BT.ParentTask:AddChildList(taskList)
    if #taskList + #self.tChildTaskList > self:MaxChildCount() then
        LogMgr.Error(BT.ErrorRet.ChildCountMax.." "..#taskList.." "..#self.tChildTaskList.." "..self:MaxChildCount())
    end
    for i = 1, #taskList do
        table.insert(self.tChildTaskList,taskList[i])
    end
end

--region runtime
function BT.ParentTask:GetCurChildIndex()
    return self.iCurChildIndex
end

function BT.ParentTask:CanExcute()
    if self.eStatus == BT.ETaskStatus.Success or self.eStatus == BT.ETaskStatus.Failure then
        return false
    end
    return true
end

function BT.ParentTask:OnChildStart(relativeChildIndex)

end

function BT.ParentTask:OnChildExcuted(status)
    return status
end
--endregion