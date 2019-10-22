using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

public class LuaMgr : MonoBehaviour
{
    public static LuaMgr instance;
    public LuaState luastate;

    private void Awake()
    {
        instance = this;
        luastate = new LuaState();
        luastate.AddSearchPath(LuaConst.btDir);
        luastate.Start();
        LuaBinder.Bind(luastate);
        
        luastate.Require("Test/Test");
        luastate.Call("Test.Run", false);
    }

    private void Start()
    {
        //Input.GetKeyDown(KeyCode.Q)
    }

    public void Update()
    {
        luastate.Call("Test.Update", false);
    }
    

    private void OnDestroy()
    {
        luastate.Dispose();
    }
}
