require("Base/BTManager")
require("Base/Task")
require("Base/ParentTask")
require("Base/Composite")
require("Base/Conditional")
require("Base/Shared")
--region Reevaluate
BT.Reevaluate = {}
BT.Reevaluate.__index = BT.Reevaluate
function BT.Reevaluate:New(index, status, stackIndex, compositeIndex, abortType)
    local o = {}
    o.index = index or 0
    o.status = status or BT.ETaskStatus.Inactive
    o.stackIndex = stackIndex or 0
    o.compositeIndex = compositeIndex or 0
    o.abortType = abortType or BT.EAbortType.Both
    setmetatable(o,BT.Reevaluate)
    return o
end
--endregion

--region BTree
BT.BTree = {

}
local this = BT.BTree
BT.BTree.__index = this

function BT.BTree:New(gameObject, name)
    local o = {}
    setmetatable(o,this)
    --行为树绑定的unity对象及节点共享数据
    o.gameObject = gameObject
    o.transform = gameObject and gameObject.transform or nil
    o.sName = name and name or (gameObject and gameObject.name or Const.Empty)
    o.sharedData = BT.Shared:New()
    o.globalSharedData = BT.Mgr.globalSharedData
    --树的状态
    o.eStatus = BT.EBTreeStatus.None
    --行为树结构
    o.root = nil
    o.tTaskList = {}--val is Task
    o.tParentIndex = {}--val is int
    o.tChildrenIndex = {}--val is {int}
    o.tRelativeChildIndex = {1} --val is int
    o.tParentCompositeIndex = {} -- val is int
    o.tChildConditionalIndex = {} -- val is {int}

    --运行栈及评估条件
    o.tRunStack = {}--val is Stack<int>
    o.tConditionalReevaluate = {}--val is conditionalReevaluate
    o.tConditionalReevaluateDic = {} --val is dictionary<index, conditionalReevaluate>
    return o
end

--先序遍历，root的index为1、父亲index为0
function BT.BTree:Init(task, parentIndex, compositeIndex)
    task:Init(self)
    task:OnAwake()
    local curIndex = #self.tTaskList + 1
    table.insert(self.tTaskList,task) --赋值task的index
    table.insert(self.tParentIndex,parentIndex) --可以找到其父亲的index
    table.insert(self.tParentCompositeIndex,compositeIndex) --可以找到是Composite类型且离自己最近的祖先的index，用于中断评估

    if task:CheckType(BT.ParentTask) then
        if task:CheckChildCount() == false then
            LogMgr.Error(BT.ErrorRet.ChildCountMin.." index = "..curIndex.." count = "..#task.tChildTaskList)
            return
        end
        self.tChildrenIndex[curIndex] = {}
        self.tChildConditionalIndex[curIndex] = {}
        for i = 1, #task.tChildTaskList do
            table.insert(self.tRelativeChildIndex,i) --该task在其父亲中处于第几个
            table.insert(self.tChildrenIndex[curIndex],#self.tTaskList + 1) --可以找到其所有儿子的index
            if task:CheckType(BT.Composite) then
                self:Init(task.tChildTaskList[i], curIndex, curIndex)
            else
                self:Init(task.tChildTaskList[i], curIndex, compositeIndex)
            end
        end
    else
        if task:CheckType(BT.Conditional) then
            --可以找到是Conditional类型且离自己最近的子孙的index，用于中断评估
            table.insert(self.tChildConditionalIndex[self.tParentCompositeIndex[curIndex]],curIndex)
        end
    end
end

function BT.BTree:EnabledBT()
    if self.root == nil then
        LogMgr.Error("Error,root is nil")
        return
    end
    if self.eStatus == BT.EBTreeStatus.None then
        table.insert(BT.Mgr.treeList,self)
        self:Init(self.root,0,0)
    elseif self.eStatus ~= BT.EBTreeStatus.Disabled then
        return
    end
    self.eStatus = BT.EBTreeStatus.Active
    table.insert(self.tRunStack, Stack:New())
    self:PushTask(1,1)
end

function BT.BTree:DisabledBT()
    if self.eStatus == BT.EBTreeStatus.Disabled then
        return
    end
    self.eStatus = BT.EBTreeStatus.Disabled

    --清空运行栈
    for stackIndex = #self.tRunStack, 1, -1 do
        repeat
            if self.tRunStack[stackIndex] == Const.Empty then
                break
            end
            while self.tRunStack[stackIndex] ~= Const.Empty do
                self:PopTask(stackIndex,BT.ETaskStatus.Inactive)
            end
        until(true)
    end
    self.tRunStack = {}

    --删除reevalute
    self.tConditionalReevaluate = {}
    self.tConditionalReevaluateDic = {}

    LogMgr.Normal("bt is disabled")
end

function BT.BTree:PauseBT()
    if self.eStatus == BT.EBTreeStatus.Active then
        self.eStatus = BT.EBTreeStatus.Pause
        for i = 1, #self.tTaskList do
            self.tTaskList[i]:OnPause(true)
        end
    end
end

function BT.BTree:UnPauseBT()
    if self.eStatus == BT.EBTreeStatus.Pause then
        self.eStatus = BT.EBTreeStatus.Active
        for i = 1, #self.tTaskList do
            self.tTaskList[i]:OnPause(false)
        end
    end
end

function BT.BTree:RestartBT()
    self:DisabledBT()
    self:EnabledBT()
end

function BT.BTree:AddRoot(task)
    self.root = task
end

function BT.BTree:FindTaskWithName(name)
    for i = 1, #self.tTaskList do
        if self.tTaskList[i].sName == name then
            return self.tTaskList[i]
        end
    end
    return nil
end

function BT.BTree:FindTasksWithName(name)
    local tab = {}
    for i = 1, #self.tTaskList do
        if self.tTaskList[i].sName == name then
            table.insert(tab,self.tTaskList[i])
        end
    end
    return tab
end
------------------runtime---------------
function BT.BTree:Update()
    --进入评估阶段，中断修改运行栈
    self:ConditionalReevaluate()
    local status
    if #self.tRunStack == 0 then
        return BT.ETaskStatus.Inactive
    end
    --遍历执行所有栈
    for i = #self.tRunStack,1,-1 do
        repeat
            if self.tRunStack[i] == Const.Empty then
                table.remove(self.tRunStack,i)
                break
            end
            status = BT.ETaskStatus.Inactive
            while status ~= BT.ETaskStatus.Running do
                if self.tRunStack[i] ~= Const.Empty then
                    status = self:RunTask(self.tRunStack[i]:Peek(),i)
                else
                    break
                end
            end
        until(true)
    end
    return BT.ETaskStatus.Running
end

function BT.BTree:ConditionalReevaluate()
    for i = 1, #self.tConditionalReevaluate do
        repeat
            local reevalute = self.tConditionalReevaluate[i]
            if reevalute == nil or reevalute.compositeIndex == 0 then
                break
            end
            local status = self.tTaskList[reevalute.index]:OnUpdate()
            if status == reevalute.status then
                break
            end
            --打断
            local bBreak = false
            for stackIndex = 1, #self.tRunStack do
                repeat
                    if self.tRunStack[stackIndex] == Const.Empty then
                        break
                    end
                    local runIndex = self.tRunStack[stackIndex]:Peek()
                    local lcaIndex = self:LCA(reevalute.compositeIndex,runIndex)
                    --只有在reevaluate打断链上的运行节点才能被打断
                    if not self:IsParent(reevalute.compositeIndex,lcaIndex) then
                        break
                    end
                    --如果运行节点和reevaluate的conditional处于同一个并行节点的不同分支上，不能被打断
                    if stackIndex ~= reevalute.stackIndex and self.tTaskList[self:LCA(reevalute.index,runIndex)]:CanExcuteParallel() then
                        break
                    end

                    if reevalute.abortType == BT.EAbortType.LowerPriority and self.tParentCompositeIndex[reevalute.index] == self.tParentCompositeIndex[runIndex] then
                        break
                    end

                    --更改运行栈
                    while true do
                        if self.tRunStack[stackIndex] == Const.Empty or self.tRunStack[stackIndex]:Empty() then
                            break
                        end
                        runIndex = self.tRunStack[stackIndex]:Peek()
                        if runIndex == lcaIndex then
                            self.tTaskList[lcaIndex]:OnConditionalAbort()
                            break
                        end
                        self:PopTask(stackIndex,BT.ETaskStatus.Inactive)
                    end
                    bBreak = true
                until(true)
            end

            if not bBreak then
                break
            end
            --删除同一个中断链且优先级较低的reevalute
            for j = #self.tConditionalReevaluate, i,-1 do
                local nextReevalute = self.tConditionalReevaluate[j]
                if self:IsParent(reevalute.compositeIndex,nextReevalute.index) then
                    self.tConditionalReevaluateDic[nextReevalute.index] = nil
                    table.remove(self.tConditionalReevaluate,j)
                end
            end

        until(true)

    end

end

function BT.BTree:PushTask(taskIndex, stackIndex)
    local task = self.tTaskList[taskIndex]
    local stack = self.tRunStack[stackIndex]
    if stack == nil then
        return
    end

    if stack:Empty() == false and stack:Peek() == taskIndex then
        return
    end
    stack:Push(taskIndex)

    task:OnStart()

end

function BT.BTree:PopTask(stackIndex, status)
    local stack = self.tRunStack[stackIndex]
    if stack == nil then
        return
    end
    local taskIndex = stack:Pop()
    local task = self.tTaskList[taskIndex]


    if self.tParentIndex[taskIndex] ~= 0 then
        local parentTask = self.tTaskList[self.tParentIndex[taskIndex]]
        if parentTask:CanExcuteParallel() then
            parentTask:OnChildExcuted(status,self.tRelativeChildIndex[taskIndex])
        else
            parentTask:OnChildExcuted(status)
        end
    end

    --pop children stack
    for i = 1, #self.tRunStack do
        if i ~= stackIndex and self.tRunStack[i] ~= Const.Empty then
            while self.tRunStack[i] ~= Const.Empty and self:IsParent(taskIndex,self.tRunStack[i]:Peek()) do
                self:PopTask(i,BT.ETaskStatus.Inactive)
            end
        end
    end

    --reevaluate
    local parentCompositeIndex = self.tParentCompositeIndex[taskIndex]
    local parentComposite = self.tTaskList[parentCompositeIndex]

    if task:CheckType(BT.Conditional) then
        if  parentComposite ~= nil and parentComposite.abortType ~= BT.EAbortType.None then
            if self.tConditionalReevaluateDic[taskIndex]  == nil then
                local reevaluate = BT.Reevaluate:New(taskIndex, status, stackIndex, parentComposite.abortType == BT.EAbortType.LowerPriority and 0 or parentCompositeIndex, parentComposite.abortType)
                table.insert(self.tConditionalReevaluate,reevaluate)
                self.tConditionalReevaluateDic[taskIndex] = reevaluate
            end
        end
    elseif task:CheckType(BT.Composite) then

        repeat
            if parentComposite == nil then
                --for i=#self.tConditionalReevaluate,1,-1 do
                --    if self.tConditionalReevaluate[i].stackIndex == stackIndex then
                --        table.remove(self.tConditionalReevaluate,i)
                --    end
                --end
                break
            end
            --LowerPriority延迟指向
            if task.abortType == BT.EAbortType.LowerPriority then
                for i = 1, #self.tChildConditionalIndex[taskIndex] do
                    local reevalute = self.tConditionalReevaluateDic[self.tChildConditionalIndex[taskIndex][i]]
                    if reevalute ~= nil then
                        reevalute.compositeIndex = taskIndex
                    end
                end
            end

            --指向自己的reevalute重新指向自己的父亲
            local lam_BothOrOther = function(tab,abortType)
                if tab.abortType == abortType or tab.abortType == BT.EAbortType.Both then
                    return true
                end
                return false
            end

            for i = 1, #self.tConditionalReevaluate do
                local reevalute = self.tConditionalReevaluate[i]
                if reevalute.compositeIndex == taskIndex then
                    if lam_BothOrOther(task,BT.EAbortType.Self) and lam_BothOrOther(parentComposite,BT.EAbortType.Self) and lam_BothOrOther(reevalute,BT.EAbortType.Self) or
                            lam_BothOrOther(task,BT.EAbortType.LowerPriority) and lam_BothOrOther(reevalute,BT.EAbortType.LowerPriority)
                    then
                        reevalute.compositeIndex = parentCompositeIndex
                        if reevalute.abortType == BT.EAbortType.Both then
                            if task.abortType == BT.EAbortType.Self or parentComposite.abortType == BT.EAbortType.Self then
                                reevalute.abortType = BT.EAbortType.Self
                            elseif task.abortType == BT.EAbortType.LowerPriority or parentComposite.abortType == BT.EAbortType.LowerPriority then
                                reevalute.abortType = BT.EAbortType.LowerPriority
                            end
                        end
                    end
                end
            end

            --删除目前还指向自己的节点
            for i = #self.tConditionalReevaluate,1,-1  do
                local reevalute = self.tConditionalReevaluate[i]
                if reevalute.compositeIndex == taskIndex then
                    self.tConditionalReevaluateDic[reevalute.index] = nil
                    table.remove(self.tConditionalReevaluate,i)
                end
            end
        until(true)

    end
    if stack:Empty() then
        self.tRunStack[stackIndex] = Const.Empty
    end
    task:OnEnd()
end

function BT.BTree:RunTask(taskIndex, stackIndex)
    local task = self.tTaskList[taskIndex]
    if self.tRunStack[stackIndex] == nil then
        return BT.ETaskStatus.Inactive
    end
    self:PushTask(taskIndex,stackIndex)

    local status = BT.ETaskStatus.Inactive

    if task:CheckType(BT.ParentTask) then
        status = self:RunParentTask(taskIndex,stackIndex)
    else
        status = task:OnUpdate()
    end

    if status ~= BT.ETaskStatus.Running then
        self:PopTask(stackIndex, status)
    end
    return status
end

function BT.BTree:RunParentTask(taskIndex, stackIndex)
    local task = self.tTaskList[taskIndex]
    local curRelChildIndex = -1
    local preRelChildIndex = -1
    while task:CanExcute() do
        curRelChildIndex = task:GetCurChildIndex()
        if curRelChildIndex == preRelChildIndex then
            return BT.ETaskStatus.Running
        end
        local childIndex = self.tChildrenIndex[taskIndex][curRelChildIndex]
        if childIndex == nil then
            break
        end
        --这个主要是为并行节点服务的
        --其他类型的节点都是儿子执行完毕主动通知父亲然后curChildIndex指向下个儿子
        --但是并行节点是所有儿子一开始都同时执行
        task:OnChildStart(curRelChildIndex)
        if task:CanExcuteParallel() then
            --并行节点创建新的分支
            local newStack = Stack:New()
            table.insert(self.tRunStack, newStack)
            newStack:Push(childIndex)
            self:RunTask(childIndex, #self.tRunStack)
        else
            self:RunTask(childIndex, stackIndex)
        end
        preRelChildIndex = curRelChildIndex
    end
    return task:GetStatus()
end

--endregion


--region treeSolve
function BT.BTree:IsParent(parentTaskIndex, childTaskIndex)
    while childTaskIndex ~= 0 do
        if childTaskIndex == parentTaskIndex then
            return true
        end
        childTaskIndex = self.tParentIndex[childTaskIndex]
    end
end

function BT.BTree:LCA(taskIndex1, taskIndex2)
    if taskIndex1 == nil or taskIndex2 == nil then
        return nil
    end
    local set = Set.New()
    while taskIndex1 ~= 0 do
        set:Insert(taskIndex1)
        taskIndex1 = self.tParentIndex[taskIndex1]
    end
    while taskIndex2 ~= 0 do
        if set:Contain(taskIndex2) then
            return taskIndex2
        end
        taskIndex2 = self.tParentIndex[taskIndex2]
    end
    return nil
end
--