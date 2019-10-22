Common = {}
function Common.TableFind(tab, val)
    for k,v in pairs(tab) do
        if v == val then
            return k
        end
    end
    return nil
end
function Common.TableRemove(tab, val)
    for k,v in pairs(tab) do
        if v == val then
            table.remove(tab, k)
            break
        end
    end
end

Const = {
    Empty = "none",
}

BT.EBTreeStatus = {
    None =  1,
    Pause = 2,
    Disabled = 3,
    Active = 4,
}

BT.ETaskStatus={
    Inactive = 1,
    Failure = 2,
    Success = 3,
    Running = 4
}
BT.ETaskType={
    UnKnow = 0,
    Composite = 1,--必须包含子节点
    Decorator = 2,--必须包含子节点
    Action = 3,--最终子节点
    Conditional = 4--最终子节点
}

BT.EAbortType = {
    None = 0,
    Self = 1,
    LowerPriority = 2,
    Both = 3,
}

BT.ErrorRet={
    ChildCountMin = "儿子个数过少",
    ChildCountMax = "儿子已满",
}
