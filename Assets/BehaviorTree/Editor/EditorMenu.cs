using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Text;

public static class EditorMenu
{   
    private static readonly string BTReqName = "BTReq.lua" ;
    public static void GetFullName(DirectoryInfo dinfo, string path, StringBuilder sb, HashSet<string> dirFilter)
    {
        
        var files = dinfo.GetFiles();
        foreach (var item in files)
        {
            if (item.Extension == ".lua")
            {
                if (item.Name == BTReqName)
                {
                    continue;
                }
                sb.AppendFormat("require(\"{0}{1}{2}\")\n",
                    path,
                    string.IsNullOrEmpty(path) ? "" : "/",
                    item.Name.Split(new char[] { '.' })[0]
                    );
            }
        }

        var dirs = dinfo.GetDirectories();
        foreach (var dirItem in dirs)
        {
            if(dirFilter.Contains(dirItem.Name))
            {
                continue;
            }
            GetFullName(dirItem, string.IsNullOrEmpty(path) ? dirItem.Name : string.Format("{0}//{1}", path, dirItem.Name), sb, dirFilter);
        }
    }

    [MenuItem("Tools/CreateBtReqLua")]
    public static void CreateBtReqLua()
    {
        
        string btReqPath = Path.Combine(LuaConst.btDir, BTReqName);
        if (File.Exists(btReqPath))
        {
            File.Delete(btReqPath);
        }
        StringBuilder sb = new StringBuilder();
        sb.AppendLine("BT = {}");
        GetFullName(new DirectoryInfo(LuaConst.btDir), "", sb, new HashSet<string>() {
            "Test",
            "Editor"
        });
        using(FileStream fs = new FileStream(btReqPath, FileMode.Create))
        {
            using (StreamWriter sw = new StreamWriter(fs, Encoding.UTF8))
            {
                sw.Write(sb.ToString());
            }
        }
        AssetDatabase.Refresh();
    }
}
