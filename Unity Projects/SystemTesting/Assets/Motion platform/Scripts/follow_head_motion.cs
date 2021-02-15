using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Text;
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.InteropServices;
using System;

public class follow_head_motion : MonoBehaviour {
    [DllImport("C++WriteDLL")]
    public static extern void WriteToMotionFile(float surge, float lateral, float heave, float roll, float pitch, float yaw, bool absolute_mode, int traj_rate);

    [DllImport("C++WriteDLL")]
    public static extern void InitializeMotionFileCounter();

    //the transform of the optitrack object whose position/orientation are set by the optitrack plugin
    public Transform opti_obj_transform;

    //if true, only movements that are beyond a predetermined threshold are considered to be actual movements rather than tracking fluctuations
    public bool filter_tracking_fluctuations = true;

    //the max yaw value that the motion platform will move to in both directions
    private float motion_platform_roll_max = 28.9945f;
    private float motion_platform_pitch_max = 32.9938f;
    private float motion_platform_yaw_max = 28.9945f;

    //the heave value of the platform directly after engaging the platform
    private float engaged_heave_value = -0.2286f;

    //the rate that the command written to the file should be read at
    private int file_rate = 90;

    //the last yaw that was written to the file that is read by the motion platform code
    private float last_roll_written = 0.0f;
    //the last yaw that was written to the file that is read by the motion platform code
    private float last_pitch_written = 0.0f;
    //the last yaw that was written to the file that is read by the motion platform code
    private float last_yaw_written = 0.0f;

    //the standard deviation of yaw for a stationary rigidbody
    public float roll_fluctuation_threshold = 0.030f;
    //the standard deviation of yaw for a stationary rigidbody
    public float pitch_fluctuation_threshold = 0.030f;
    //the standard deviation of yaw for a stationary rigidbody
    public float yaw_fluctuation_threshold = 0.030f;


    //if true, the first command has been written and filtering fluctuations can be used
    private bool first_command_written = false;

    //the hmd's yaw from the transform of the optitrack object whose position/orientation are set by the optitrack plugin
    private float HMD_x;
    private float HMD_y;
    private float HMD_z;
    private float HMD_roll;
    private float HMD_pitch;
    private float HMD_yaw;

    // Use this for initialization
    void Start () {
        //initialize command_id counter to 0. counter is used to indicate the nth command that Unity has written to the file. 
        InitializeMotionFileCounter();

        //initialize positions
        HMD_x = opti_obj_transform.localPosition.x;
        HMD_y = opti_obj_transform.localPosition.y;
        HMD_z = opti_obj_transform.localPosition.z;

        //initialize by getting the current roll
        HMD_roll = opti_obj_transform.localEulerAngles.z;
        //initialize by getting the current pitch
        HMD_pitch = opti_obj_transform.localEulerAngles.x;
        //initialize by getting the current yaw
        HMD_yaw = opti_obj_transform.localEulerAngles.y;
    }
	
	// Update is called once per frame
	void Update () {
        //get positions
        HMD_x = opti_obj_transform.localPosition.x;
        HMD_y = opti_obj_transform.localPosition.y;
        HMD_z = opti_obj_transform.localPosition.z;

        //get by getting the current roll
        HMD_roll = opti_obj_transform.localEulerAngles.z;
        //get by getting the current pitch
        HMD_pitch = opti_obj_transform.localEulerAngles.x;
        //get by getting the current yaw
        HMD_yaw = opti_obj_transform.localEulerAngles.y;

        //HMD_yaw = (float)Math.Round(HMD_yaw, 1);
        //HMD_yaw = (float)Math.Round(HMD_yaw * 2.0f, MidpointRounding.AwayFromZero) / 2;

        //convert the yaw to negative rather than being <= 360 if the yaw is within the motion platform movement range
        if (HMD_yaw >= (360.0f - motion_platform_yaw_max) && HMD_yaw <= 360.0f)
        {
            float old_yaw = HMD_yaw;
            HMD_yaw -= 360.0f;

            //Debug.Log("HMD_yaw=" + old_yaw + ". Converted to " + HMD_yaw);

        }

        if (HMD_roll >= (360.0f - motion_platform_roll_max) && HMD_roll <= 360.0f)
        {
            float old_roll = HMD_roll;
            HMD_roll -= 360.0f;

            //Debug.Log("HMD_yaw=" + old_yaw + ". Converted to " + HMD_yaw);

        }

        if (HMD_pitch >= (360.0f - motion_platform_pitch_max) && HMD_pitch <= 360.0f)
        {
            float old_pitch = HMD_pitch;
            HMD_pitch -= 360.0f;

            //Debug.Log("HMD_yaw=" + old_yaw + ". Converted to " + HMD_yaw);

        }

        //if filtering fluctuations is turned on and a command has already been written to the file, filter out fluctuations
        if (filter_tracking_fluctuations && first_command_written)
        {
            //If the current yaw varies from the last written yaw by at least the threshold, a real movement occurred
            //and the yaw should be written to the file.
            if(Mathf.Abs(HMD_roll - last_roll_written) > roll_fluctuation_threshold)
            {
                WriteToFile();
            }

            if (Mathf.Abs(HMD_pitch - last_pitch_written) > pitch_fluctuation_threshold)
            {
                WriteToFile();
            }

            if (Mathf.Abs(HMD_yaw - last_yaw_written) > yaw_fluctuation_threshold)
            {
                WriteToFile();
            }
        }
        /*
         * If filtering fluctuations is off, write to the file every Update. 
         * If filtering fluctuations is on and the first command has yet to be written to the file, directly write the yaw to the file once.
         * In each Update afterwards, the fluctuations will be filtered.
        */
        else
        {
            WriteToFile();
        }
    }

    //writes the current hmd's yaw to the file 
    void WriteToFile()
    {
        //if the yaw is within the motion platform's movement range, move to that yaw
        if ((HMD_yaw >= 0.0f && HMD_yaw <= motion_platform_yaw_max) || (HMD_yaw < 0.0f && HMD_yaw >= -motion_platform_yaw_max))
        {
            //write yaw to file while not moving the other dof values from the engaged state values
            WriteToMotionFile(0.0f, 0.0f, engaged_heave_value, 0.0f, 0.0f, HMD_yaw, true, file_rate);

            //save the roll that was just written
            last_roll_written = HMD_roll;
            //save the pitch that was just written
            last_pitch_written = HMD_pitch;
            //save the yaw that was just written
            last_yaw_written = HMD_yaw;

            //the first command has been written
            first_command_written = true;

            //print to the console when a yaw is written to the file
            Debug.Log("Wrote to file: HMD_yaw=" + HMD_yaw);
        }

        //if the yaw is within the motion platform's movement range, move to that yaw
        if ((HMD_yaw >= 0.0f && HMD_yaw <= motion_platform_yaw_max) || (HMD_yaw < 0.0f && HMD_yaw >= -motion_platform_yaw_max))
        {
            //write yaw to file while not moving the other dof values from the engaged state values
            WriteToMotionFile(0.0f, 0.0f, engaged_heave_value, 0.0f, 0.0f, HMD_yaw, true, file_rate);

            //save the roll that was just written
            last_roll_written = HMD_roll;
            //save the pitch that was just written
            last_pitch_written = HMD_pitch;
            //save the yaw that was just written
            last_yaw_written = HMD_yaw;

            //the first command has been written
            first_command_written = true;

            //print to the console when a yaw is written to the file
            Debug.Log("Wrote to file: HMD_yaw=" + HMD_yaw);
        }

        //if the yaw is within the motion platform's movement range, move to that yaw
        if ((HMD_yaw >= 0.0f && HMD_yaw <= motion_platform_yaw_max) || (HMD_yaw < 0.0f && HMD_yaw >= -motion_platform_yaw_max))
        {
            //write yaw to file while not moving the other dof values from the engaged state values
            WriteToMotionFile(0.0f, 0.0f, engaged_heave_value, 0.0f, 0.0f, HMD_yaw, true, file_rate);

            //save the roll that was just written
            last_roll_written = HMD_roll;
            //save the pitch that was just written
            last_pitch_written = HMD_pitch;
            //save the yaw that was just written
            last_yaw_written = HMD_yaw;

            //the first command has been written
            first_command_written = true;

            //print to the console when a yaw is written to the file
            Debug.Log("Wrote to file: HMD_yaw=" + HMD_yaw);
        }
    }
}
