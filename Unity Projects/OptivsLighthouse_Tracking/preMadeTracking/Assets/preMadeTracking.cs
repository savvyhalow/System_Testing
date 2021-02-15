using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.VR;
using System.IO;
using System.Linq;


public class preMadeTracking : MonoBehaviour
{
    //Importing libraries
    [DllImport("VC_VoltUpdate")]

    //Establishing components
    private static extern int OutputVoltage(float voltage);
    string time;

    //Gameobjects for tracking in Unity objects
    public GameObject optitrack_Camera;
    public GameObject steamVR_Camera;

    private StreamWriter Optitrack_Data_Writer;
    private StreamWriter SteamVR_Data_Writer;
    private StreamWriter voltage_Writer;



    string[] head_velocities_string;
    float[] premade_voltages; //the voltages of the premade head velocities file
    float freq;
    float ideal_time_between_frames = 1.0f / 90.0f; //optimal time between frames is 1/90 (running at 90 Hz)
    float[] positionStep;
    float[] velocityStep;
    float[] sin;
    float[] sin2;
    float[] sin05;
    float[] sin5;
    int index;
    float[] ideal_voltages; //entire trajectory as voltages
    float[] head_velocity_List; //recorded opti velocity
    float[] error;
    float[] controlInput; //voltage sent after PID control update
    string text;
    float[] position;

    //Bool for making sure chair hasn't started
    private bool start_Chair = false;

    //multiply voltage by scaling factor to get velocity.
    float voltage_to_velocity_scaling_factor = 7.06f; //7.06

    // Grab time and velocity values
    // Queue for keeping track of yaw for head velocity calculation
    private Queue yaw_Queue;
    private Queue time_Queue;
    private float current_head_velocity;

    //Time stamps
    DateTime start_Experiment_Time;


    //Switching between pre-made velocity profiles versus live opti feed
    public enum Tracking_Type  
    {
        Optitrack_Tracking, Lighthouse_Tracking
    };



    public Tracking_Type selected_Tracking_Type = Tracking_Type.Optitrack_Tracking; // initializes using pre-recorded velocities

    void Start()
    {
        // get start time
        //Start Time
        start_Experiment_Time = DateTime.Now;

        // Initialize yaw Queue
        yaw_Queue = new Queue();
        time_Queue = new Queue();

        var fileName_Initial = "SteamVR_Object______" + selected_Tracking_Type + DateTime.Now.ToString("MM-dd-yyyy hh.mm.ss") + ".txt";
        SteamVR_Data_Writer = File.CreateText(fileName_Initial);
        SteamVR_Data_Writer.WriteLine("World Timestamp, Recording Timestamp, SteamVR GameObject Roll, SteamVR GameObject Pitch, SteamVR GameObject Yaw, Sent Trajectory Yaw");

        /*
        var fileName = "Optitrack_Object______" + selected_Tracking_Type + DateTime.Now.ToString("MM-dd-yyyy hh.mm.ss") + ".txt";
        Optitrack_Data_Writer = File.CreateText(fileName);
        Optitrack_Data_Writer.WriteLine("World Timestamp, Recording Timestamp, Optitrack GameObject Roll, Optitrack GameObject Pitch, Optitrack GameObject Yaw, Sent Trajectory Yaw");
        */
        var voltage = "Voltages_File______" + selected_Tracking_Type + DateTime.Now.ToString("MM-dd-yyyy hh.mm.ss") + ".txt";
        voltage_Writer = File.CreateText(voltage);
        voltage_Writer.WriteLine("World Timestamp, Recording Timestamp, Sent Voltage, Velocity");



        freq = -2 * (float)Math.PI;
        positionStep = new float[520];
        velocityStep = new float[600];
        sin = new float[100 + (int)(-freq * 2 / ideal_time_between_frames)];
        sin2 = new float[100 + (int)(-freq * 2 / ideal_time_between_frames)];
        sin05 = new float[100 + (int)(-freq * 2 / ideal_time_between_frames)];
        sin5 = new float[100 + (int)(-freq * 2 / ideal_time_between_frames)];
        text = File.ReadAllText(@"head_vel_profiles.txt");

        //create ideal trajectory values

        //create ideal velocity input/setpoint, to change depending on desired control
        //the below input represents the ideal velocity profile from NIcontroller.cs (4 head movements, 4 position steps, 4 velocity steps, 4 sins of varying frequencies)
        head_velocities_string = text.Split();
            premade_voltages = new float[head_velocities_string.Length - 1];

            for (int i = 0; i < premade_voltages.Length; i++)
            {
                premade_voltages[i] = float.Parse(head_velocities_string[i], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture) / voltage_to_velocity_scaling_factor;
            }

            for (int i = 100; i < positionStep.Length - 100; i++)
            {
                if ((i >= 100 && i < 120) || (i >= 200 && i < 220))
                {
                    positionStep[i] = 10.0f;
                }
                else if ((i >= 300 && i < 320) || (i >= 400 && i < 420))
                {
                    positionStep[i] = -10.0f;
                }
            }

            for (int i = 100; i < velocityStep.Length - 100; i++)
            {
                if (i < 200)
                {
                    velocityStep[i] = 5.0f;
                }
                else if (i >= 200 && i < 300)
                {
                    velocityStep[i] = 1.0f;
                }
                else if (i >= 300 && i < 400)
                {
                    velocityStep[i] = -5.0f;
                }
                else if (i >= 400 && i < 500)
                {
                    velocityStep[i] = -1.0f;
                }
            }

            for (int i = 0; i < sin.Length - 100; i++)
            {
                sin[i] = (float)Math.Sin(freq);
                freq = freq + ideal_time_between_frames;
            }
            freq = -2 * (float)Math.PI;

            for (int i = 0; i < sin2.Length - 100; i++)
            {
                sin2[i] = (float)Math.Sin(2 * freq);
                freq = freq + ideal_time_between_frames;
            }
            freq = -2 * (float)Math.PI;

            for (int i = 0; i < sin05.Length - 100; i++)
            {
                sin05[i] = (float)Math.Sin(0.5 * freq);
                freq = freq + ideal_time_between_frames;
            }
            freq = -2 * (float)Math.PI;

            for (int i = 0; i < sin5.Length - 100; i++)
            {
                sin5[i] = (float)Math.Sin(5 * freq);
                freq = freq + ideal_time_between_frames;
            }
            freq = -2 * (float)Math.PI;


            ideal_voltages = new float[premade_voltages.Length + positionStep.Length + velocityStep.Length + sin.Length + sin2.Length + sin05.Length + sin5.Length];

            for (index = 0; index < premade_voltages.Length; index++)
            {
                ideal_voltages[index] = premade_voltages[index];
            }

            for (index = 0; index < positionStep.Length; index++)
            {
                ideal_voltages[index + premade_voltages.Length] = positionStep[index];
            }

            for (index = 0; index < velocityStep.Length; index++)
            {
                ideal_voltages[index + premade_voltages.Length + positionStep.Length] = velocityStep[index];
            }

            for (index = 0; index < sin.Length; index++)
            {
                ideal_voltages[index + premade_voltages.Length + positionStep.Length + velocityStep.Length] = sin[index];
            }

            for (index = 0; index < sin2.Length; index++)
            {
                ideal_voltages[index + premade_voltages.Length + positionStep.Length + velocityStep.Length + sin.Length] = sin2[index];
            }

            for (index = 0; index < sin05.Length; index++)
            {
                ideal_voltages[index + premade_voltages.Length + positionStep.Length + velocityStep.Length + sin.Length + sin2.Length] = sin05[index];
            }

            for (index = 0; index < sin5.Length; index++)
            {
                ideal_voltages[index + premade_voltages.Length + positionStep.Length + velocityStep.Length + sin.Length + sin2.Length + sin05.Length] = sin5[index];
            }

            error = new float[ideal_voltages.Length];
            controlInput = new float[ideal_voltages.Length];
            head_velocity_List = new float[ideal_voltages.Length];
            position = new float[ideal_voltages.Length];
        index = 0;

    }

    void Update()
    {

        // Grab time and velocity values
        // For recording in game camera position

        var current_update_Time = DateTime.Now;
        TimeSpan current_TimeSpan = current_update_Time - start_Experiment_Time;
        float current_Millisecond = current_TimeSpan.Milliseconds;
        float current_Seconds = ((current_TimeSpan.Minutes * 60 * 1000) + (current_TimeSpan.Seconds * 1000) + current_Millisecond) / 1000;
        //Debug.Log("Current Seconds  " + current_Seconds);


        // Keep track of yaw angle, past 6 values, dequeues
        //var yaw_used_in_Queue = steamVR_Camera.transform.localEulerAngles.y;  //When tracking with SteamVR
        var yaw_used_in_Queue = optitrack_Camera.transform.localEulerAngles.y;    //When tracking with Optitrack
        while (yaw_used_in_Queue < -180) yaw_used_in_Queue += 360;
        while (yaw_used_in_Queue > 180) yaw_used_in_Queue -= 360;
        yaw_Queue.Enqueue(yaw_used_in_Queue);

        if (yaw_Queue.Count > 6) yaw_Queue.Dequeue();


        var yaw_array_float = yaw_Queue.Cast<float>().ToArray();
        float yaw_diff = yaw_array_float[yaw_array_float.Length - 1] - yaw_array_float[0];
        //Debug.Log("yaw_diff:  " + yaw_diff);

        //**********************************


        // Track time of the frames

        time_Queue.Enqueue(current_Seconds);
        if (time_Queue.Count > 6) time_Queue.Dequeue();
        var time_array_float = time_Queue.Cast<float>().ToArray();

        float time_Diff = time_array_float[time_array_float.Length - 1] - time_array_float[0];
        //Debug.Log("time_Diff:  " + time_Diff);

        current_head_velocity = yaw_diff / time_Diff;
        //Debug.Log("Current head velocity:  " + current_head_velocity);


        float time_between_last_2_frames;
        if (time_array_float.Length > 1)
            time_between_last_2_frames = time_array_float[time_array_float.Length - 1] - time_array_float[time_array_float.Length - 2];
        else
            time_between_last_2_frames = 0.0f;

        //get current time as string
        time = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss.fff");
        SteamVR_Data_Writer.WriteLine(time + "," + current_Seconds + "," + steamVR_Camera.transform.eulerAngles.z + "," + steamVR_Camera.transform.eulerAngles.x + "," + steamVR_Camera.transform.eulerAngles.y);
      //  Optitrack_Data_Writer.WriteLine(time + "," + current_Seconds + "," + optitrack_Camera.transform.eulerAngles.z + "," + optitrack_Camera.transform.eulerAngles.x + "," + optitrack_Camera.transform.eulerAngles.y);


        /*
        if (selected_Tracking_Type == Tracking_Type.Optitrack_Tracking)
        {
            Optitrack_Data_Writer.WriteLine(time + "," + current_Seconds + "," + steamVR_Camera.transform.eulerAngles.y);

        }
        else if (selected_Tracking_Type == Tracking_Type.Lighthouse_Tracking)
        {
            SteamVR_Data_Writer.WriteLine(time + "," + current_Seconds + "," + optitrack_Camera.transform.eulerAngles.y);
        }
        */

        // Press Spacebar to start sending voltages
        if (Input.GetKeyDown(KeyCode.Space))
        {
            start_Chair = true;
        }

        if (start_Chair)
        {

            // until you run out of values...
            if (index < ideal_voltages.Length)
            {
                //send voltage based on predetermined values
                OutputVoltage(ideal_voltages[index]);
                index++;


                //get current velocity
                head_velocity_List[index] = current_head_velocity;
                voltage_Writer.WriteLine(time + "," + current_Seconds + "," + ideal_voltages[index] + "," + ideal_voltages[index] * voltage_to_velocity_scaling_factor);
                //SteamVR_Data_Writer.WriteLine(time + ", " + ideal_voltages[index] + ", " + ideal_voltages[index] + "," + ideal_voltages[index] * voltage_to_velocity_scaling_factor + "," + head_velocity_List[index]);

            }
            else
            {
                //once out of values, end
                OutputVoltage(0);
                //Optitrack_Data_Writer.Close();
                //Optitrack_Data_Writer.Close();
                SteamVR_Data_Writer.Close();
                voltage_Writer.Close();
                Application.Quit();
            }

        }

    }

    private void OnDestroy()
    {
        // Stop chair on escape
        OutputVoltage(0);
        Optitrack_Data_Writer.Close();
    }
}