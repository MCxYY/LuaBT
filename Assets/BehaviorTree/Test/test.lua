require("BTReq")
--require("Test/Lua1")
Test = {}
local this = Test

local bt5
function Test:Update()
    --if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Q) then
    --    local condition = bt5:FindTaskWithName("bool1")
    --    condition.bVal2 = true
    --end
    --if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.W) then
    --    local condition = bt5:FindTaskWithName("bool2")
    --    condition.bVal2 = true
    --end
    --if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.E) then
    --    local condition = bt5:FindTaskWithName("bool3")
    --    condition.bVal2 = true
    --end
    --if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.R) then
    --    bt5:DisabledBT()
    --end
    --if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.T) then
    --    bt5:EnabledBT()
    --end
    --if UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Y) then
    --    bt5:RestartBT()
    --end
end

function Test:Run()
    local btMgrObj = UnityEngine.GameObject("BTManager")
    btMgrObj:AddComponent(typeof(BehaviorTest))

    --bt1 = this:CreateBT1()
    --bt1:EnabledBT()

    --bt2 = this:CreateBT2()
    --bt2:EnabledBT()

    --bt3 = this:CreateBT3()
    --bt3:EnabledBT()

    --bt4 = this:CreateBT4()
    --bt4:EnabledBT()

    --bt5 = this:CreateBT5()
    --bt5:EnabledBT()

    local bt6 = this:CreateBT6()
    bt6:EnabledBT()
end

function Test:CreateBT1()
    local btree = BT.BTree:New(nil,nil)
    --1
    local sel1001 = BT.Selector:New()
    btree:AddRoot(sel1001)
    --2
    local seq2001 = BT.Sequence:New()
    seq2001:SetAbortType(BT.EAbortType.LowerPriority)
    local rep2001 = BT.Repeater:New()
    rep2001:SetExecutionCount(300)
    sel1001:AddChild(seq2001)
    sel1001:AddChild(rep2001)
    --3
    local boolCom3001 = BT.BoolComparison:New("bool",true,false)
    local log3001 = BT.Log:New(nil,"this is Log3001")
    seq2001:AddChild(boolCom3001)
    seq2001:AddChild(log3001)
    local seq3001 = BT.Sequence:New()
    rep2001:AddChild(seq3001)
    --4
    local log4001 = BT.Log:New(nil,"this is Log4001")
    local wait4001 = BT.Wait:New(nil,0.01)
    seq3001:AddChild(log4001)
    seq3001:AddChild(wait4001)

    return btree
end

function Test:CreateBT2()
    local btree = BT.BTree:New(nil,nil)
    --1
    local parallel1001 = BT.Parallel:New()
    btree:AddRoot(parallel1001)
    --2
    local sel2001 = BT.Selector:New()
    local rep2001 = BT.Repeater:New()
    local sel2002 = BT.Selector:New()
    local rep2002 = BT.Repeater:New()
    rep2001:SetExecutionCount(100)
    rep2002:SetExecutionCount(300)
    parallel1001:AddChild(sel2001)
    parallel1001:AddChild(rep2001)
    parallel1001:AddChild(sel2002)
    parallel1001:AddChild(rep2002)
    --3
    local boolCom3001 = BT.BoolComparison:New(nil,true,true)
    local log3001 = BT.Log:New(nil,"this is log3001")
    local seq3001 = BT.Sequence:New()
    local boolCom3002 = BT.BoolComparison:New(nil,true,true)
    local boolCom3003 = BT.BoolComparison:New(nil,true,true)
    local seq3002 = BT.Sequence:New()
    sel2001:AddChild(boolCom3001)
    sel2001:AddChild(log3001)
    rep2001:AddChild(seq3001)
    sel2002:AddChild(boolCom3002)
    sel2002:AddChild(boolCom3003)
    rep2002:AddChild(seq3002)
    --4
    local log4001 = BT.Log:New(nil,"this is log4001")
    local wait4001 = BT.Wait:New(nil,0.1)
    local log4002 = BT.Log:New(nil,"this is log4002")
    local wait4002 = BT.Wait:New(nil,0.1)
    seq3001:AddChild(log4001)
    seq3001:AddChild(wait4001)
    seq3002:AddChild(log4002)
    seq3002:AddChild(wait4002)

    return btree
end

function Test:CreateBT3()
    local btree = BT.BTree:New(nil,nil)
    --1
    local sel1001 = BT.Selector:New()
    btree:AddRoot(sel1001)
    --2
    local sel2001 = BT.Selector:New()
    sel2001:SetAbortType(BT.EAbortType.LowerPriority)
    local seq2001 = BT.Sequence:New()
    sel1001:AddChildList{sel2001,seq2001}
    --3
    local seq3001 = BT.Sequence:New()
    seq3001:SetAbortType(BT.EAbortType.LowerPriority)
    local seq3002 = BT.Sequence:New()
    seq3002:SetAbortType(BT.EAbortType.LowerPriority)
    local rep3001 = BT.Repeater:New()
    rep3001:SetExecutionCount(300)
    sel2001:AddChildList{seq3001,seq3002}
    seq2001:AddChildList{rep3001}
    --4
    local bool4001 = BT.BoolComparison:New("bool1",true,false)
    local rep4001 = BT.Repeater:New()
    rep4001:SetExecutionCount(300)
    seq3001:AddChildList{bool4001,rep4001}
    local bool4002 = BT.BoolComparison:New("bool2",true,false)
    local rep4002 = BT.Repeater:New()
    rep4002:SetExecutionCount(300)
    seq3002:AddChildList{bool4002,rep4002}
    local seq4001 = BT.Sequence:New()
    rep3001:AddChildList{seq4001}


    --5
    local seq5001 = BT.Sequence:New()
    rep4001:AddChildList{seq5001}
    local seq5002 = BT.Sequence:New()
    rep4002:AddChildList{seq5002}
    local log5001 = BT.Log:New(nil,"this is Log5001")
    local wait5001 = BT.Wait:New(nil,0.1)
    seq4001:AddChildList{log5001,wait5001}

    --6
    local log6001 = BT.Log:New(nil,"this is Log6001")
    local wait6001 = BT.Wait:New(nil,0.1)
    seq5001:AddChildList{log6001,wait6001}
    local log6002 = BT.Log:New(nil,"this is Log6002")
    local wait6002 = BT.Wait:New(nil,0.1)
    seq5002:AddChildList{log6002,wait6002}

    return btree
end

function Test:CreateBT4()
    local btree = BT.BTree:New(nil,nil)
    --1
    local sel1001 = BT.Selector:New()
    sel1001:SetAbortType(BT.EAbortType.Self)
    btree:AddRoot(sel1001)
    --2
    local seq2001 = BT.Sequence:New()
    seq2001:SetAbortType(BT.EAbortType.LowerPriority)
    local rep2001 = BT.Repeater:New()
    rep2001:SetRepeatForever(true)
    sel1001:AddChildList{seq2001,rep2001}
    --3
    local seq3001 = BT.Sequence:New()
    seq3001:SetAbortType(BT.EAbortType.Both)
    local log3001 = BT.Log:New(nil,"this is Log3001")
    local log3002 = BT.Log:New(nil,"this is Log3002")
    seq2001:AddChildList{seq3001,log3001}
    rep2001:AddChildList{log3002}
    --
    local rep4001 = BT.Repeater:New()
    local rep4002 = BT.Repeater:New()
    rep4002:SetExecutionCount(100)
    seq3001:AddChildList{rep4001,rep4002}
    --5
    local invt5001 = BT.Inverter:New()
    rep4001:AddChildList{invt5001}
    local seq5001 = BT.Sequence:New()
    rep4002:AddChild(seq5001)
    --6
    local rep6001 = BT.Repeater:New()
    invt5001:AddChildList{rep6001}
    local log6001 = BT.Log:New(nil,"this is Log6001")
    local wait6001 = BT.Wait:New(nil,0.5)
    seq5001:AddChildList{log6001,wait6001}
    --7
    local invt7001 = BT.Inverter:New()
    rep6001:AddChildList{invt7001}
    --8
    local bool8001 = BT.BoolComparison:New("bool1",true,false)
    invt7001:AddChildList{bool8001}
    return btree
end

function Test:CreateBT5()
    local btree = BT.BTree:New(nil,nil)
    --1
    local sel1001 = BT.Selector:New()
    sel1001:SetAbortType(BT.EAbortType.Self)
    btree:AddRoot(sel1001)
    --2
    local parallel2001 = BT.Parallel:New()
    parallel2001:SetAbortType(BT.EAbortType.Self)
    local rep2001 = BT.Repeater:New()
    rep2001:SetExecutionCount(300)
    sel1001:AddChildList{parallel2001,rep2001}
    --3
    local bool3001 = BT.BoolComparison:New("bool1",true,false)
    local seq3001 = BT.Sequence:New()
    seq3001:SetAbortType(BT.EAbortType.Self)
    local sel3001 = BT.Selector:New()
    sel3001:SetAbortType(BT.EAbortType.Self)
    parallel2001:AddChildList{bool3001,seq3001,sel3001}
    local log3001 = BT.Log:New(nil,"this is Log3001")
    rep2001:AddChildList{log3001}
    --4
    local bool4001 = BT.BoolComparison:New("bool2",true,false)
    local log4001 = BT.Log:New(nil,"this is Log4001")
    seq3001:AddChildList{bool4001,log4001}
    local bool4002 = BT.BoolComparison:New("bool3",true,false)
    local rep4001 = BT.Repeater:New()
    rep4001:SetRepeatForever(true)
    sel3001:AddChildList{bool4002,rep4001}
    --5
    local log5001 = BT.Log:New(nil,"this is Log5001")
    rep4001:AddChildList{log5001}
    return btree
end

function Test:CreateBT6()
    local btree = BT.BTree:New(nil,nil)
    --1
    local parallel1001 = BT.Parallel:New()
    btree:AddRoot(parallel1001)
    --2
    local rep2001 = BT.Repeater:New()
    rep2001:SetRepeatForever(true)
    local rep2002 = BT.Repeater:New()
    rep2002:SetRepeatForever(true)
    parallel1001:AddChildList{rep2001,rep2002}
    --3
    local ts13001 = BT.TestShared1:New()
    rep2001:AddChild(ts13001)
    local ts23001 = BT.TestShared2:New()
    rep2002:AddChild(ts23001)

    return btree
end