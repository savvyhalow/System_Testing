using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Text;
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System;

public class TriggerExternalTrajectory : MonoBehaviour {

    [DllImport("C++WriteDLL")]
    public static extern void WriteToMotionFile(float surge, float lateral, float heave, float roll, float pitch, float yaw, bool absolute_mode, int traj_rate);

    [DllImport("C++WriteDLL")]
    public static extern void WriteToTriggerFile(bool trigger_trajectory);

    [DllImport("C++WriteDLL")]
    public static extern void InitializeMotionFileCounter();

    private DateTime start_time;

    // Use this for initialization
    void Start () {
        //initialize command_id counter to 0. counter is used to indicate the nth command that Unity has written to the file. 
        InitializeMotionFileCounter();

        //set the move_by file to relative mode with dofs as 0 so that the motion platform doesn't move.
        WriteToMotionFile(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, false, 2000);

        start_time = DateTime.Now;
    }
	
	// Update is called once per frame
	void Update () {
        //space bar starts the trajectory
        if (Input.GetKeyDown(KeyCode.Space))
        {
            //set the value in the file to 1
            WriteToTriggerFile(true);

            DateTime current_time = DateTime.Now;

            string filepath = "Assets/Trajectory_Trigger_Time " + start_time.ToString("d MMM yyyy h_mm_ss_fff t") + ".txt";

            StreamWriter writer = new StreamWriter(filepath, true);

            //string formatted_time = string.Format("{0}/{1}/{2} {3}:{4}:{5}:{6}", current_time.Month, current_time.Day, current_time.Year, current_time.Hour, current_time.Minute, current_time.Second, current_time.Millisecond);

            string formatted_time = current_time.ToString("d MMM yyyy h:mm:ss.fff t");

            //Debug.Log(formatted_time);

            writer.WriteLine(formatted_time);

            writer.Close();



            //Debug.Log("Trigger file set to 1.");

            //reset to the value in the file back to 0 after 1 second
            StartCoroutine(ResetTrajectoryStartFile());
        }

    }

    //set the value in the file back to 0
    IEnumerator ResetTrajectoryStartFile()
    {
        //wait for 1 second
        yield return new WaitForSecondsRealtime(1);

        //reset to the value in the file back to 0
        WriteToTriggerFile(false);
        //Debug.Log("Trigger file set to 0.");

    }

}
