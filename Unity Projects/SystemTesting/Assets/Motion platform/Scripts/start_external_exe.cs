using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Diagnostics;

public class start_external_exe : MonoBehaviour {

    //The application to start
    private Process process1;

	// Use this for initialization
	void Start () {
        //Initialize the process
		process1 = new Process();

        //Set the path to be the current Unity directory
        var path = Application.dataPath;
        
        //Attach the exe file name to the end of the path
        process1.StartInfo.FileName = path + "/MoogDynamicCtrl.exe";

        //Print out the path
        //UnityEngine.Debug.Log(path);

        //Enable below to hide the cmd line window for the application that start up. Shouldn't be used since the window needs input and also shows errors.
        //process1.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;

        //start up the exe
        process1.Start();
	}
	
	// Update is called once per frame
	void Update () {
        
	}

    //When the attached GameObject is destroyed
    private void OnDestroy()
    {
        //If the process was not running
        if(process1 == null)
        {
            UnityEngine.Debug.Log("Process was closed before Unity shut it down, or the process was never started.");
        }
        //The process was running
        else
        {
            //If the process has not exited, terminate.
            if(!process1.HasExited)
                process1.Kill();
        }
    }
}