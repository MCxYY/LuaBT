using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;

public class LogMgr
{
    [Conditional("EnableLog")]
    public static void Normal(string str)
    {
        UnityEngine.Debug.Log(str);
    }

    [Conditional("EnableLog")]
    public static void Warning(string str)
    {
        UnityEngine.Debug.LogWarning(str);
    }

    [Conditional("EnableLog")]
    public static void Error(string str)
    {
        UnityEngine.Debug.LogError(str);
    }
}
