using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using UnityEngine.UI;
public class BehaviorTest : MonoBehaviour
{
    private void Awake()
    {
        LuaMgr.instance.luastate.Require("Base/BTManager");
        //Image image = GameObject.Find("Canvas/Image").GetComponent<Image>();
        //Debug.Log("+=========" + image.material.color);
        //image.material.name.color
    }
    // Update is called once per frame
    void Update()
    {
        LuaMgr.instance.luastate.Call("BT.Mgr.Update", false);
    }
}
