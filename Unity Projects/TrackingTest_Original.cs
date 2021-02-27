using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.VR;
using System.IO;
using System.Linq;


public class TrackingTest : MonoBehaviour
{
    // Establishing Components
    // Chair Controllers
    [DllImport("VC_VoltUpdate")]                                   // Importing libraries                                                                     
    private static extern int OutputVoltage(float voltage);        // Voltages to be pushed to the rotating chair
    private bool start_Chair = false;                              //  Bool for making sure chair hasn't started
    float voltage_to_velocity_scaling_factor = 7.06f;              // multiply voltage by scaling factor to get velocity -  7.06
    float[] controlInput;                                          // voltage sent after control update

    // Position and Tracking Components
    string velocity_file;                                          // Premade Velocity file to be imported
    string[] premade_vel_string;                                   // The velocities of the premade velocities file
    float[] premade_voltages;                                      // The voltages of the premade velocities file

    float[] position;                                               // Check position over time ????
    float[] positionStep;                                           // Chair change in position
    float[] velocityStep;                                           // Chair change in velocity
    float[] sin;                                                    // Different sin waves to test
    float[] sin2;
    float[] sin05;
    float[] sin5;    

    float[] ideal_voltages;                                         // Entire trajectory as voltages
    float[] velocity_List;                                          // Previously recorded velocities to use
    float[] error;                                                  // Calculate Error for correction
    int index;                                                      // For keeping track of place in list
    float freq;                                                     // ????
    float ideal_time_between_frames = 1.0f / 90.0f;                 // optimal time between frames is 1/90 (running at 90 Hz)
    
    // Data Collection components
    string time;
    public GameObject optitrack_Rigidbody;                             //Gameobjects for tracking in Unity objects
    public GameObject steamVR_Camera;
    private StreamWriter Optitrack_Data_Writer;                    // Stream Writers for Optitrack and Steam VR objects
    private StreamWriter SteamVR_Data_Writer;
    private StreamWriter voltage_Writer;
       
    private Queue yaw_Queue;                                        // Queue for keeping track of optitrack yaw for velocity calculation     
    private Queue steamvr_yaw_Queue;                                 // Queue for keeping track of steamVR yaw for velocity calculation   
    private Queue time_Queue;                                       // Time queue for velocity calculations    
    DateTime start_Experiment_Time;                                 // Time stamps
    private float current_opti_velocity;                            // Current velocity of tracked object
    private float current_steamvr_velocity;


    public enum Tracking_Type                                       // Switching between types of tracking
    {   
        Optitrack_Rigidbody_Tracking, Lighthouse_Tracking, OpenVR_Tracking
    };
    public Tracking_Type selected_Tracking_Type = Tracking_Type.Optitrack_Rigidbody_Tracking;     // Initiialize to OptiTrack as default

    public enum Motion_Generator                                       // Switching between types of tracking
    {
        Motion_Platform, Rotating_Chair
    };
    public Motion_Generator selected_Machine = Motion_Generator.Motion_Platform;     // Initiialize to OptiTrack as default

    void Start()
    {
        start_Experiment_Time = DateTime.Now;           // Start Time
        yaw_Queue = new Queue();                        // Initialize yaw Queue
        time_Queue = new Queue();


        // Begin File writers for each tracked object and voltages sent
        var fileName_Initial = selected_Tracking_Type + "SteamVR_Object___" +  DateTime.Now.ToString("MM-dd-yyyy hh.mm.ss") + ".txt";
        SteamVR_Data_Writer = File.CreateText(fileName_Initial);
        SteamVR_Data_Writer.WriteLine("World Timestamp, Recording Timestamp, SteamVR GameObject Roll, SteamVR GameObject Pitch, SteamVR GameObject Yaw, Sent Voltage,  Current Velocity, Expected Velocity");

        if (selected_Tracking_Type != Tracking_Type.Lighthouse_Tracking)
        {
            var fileName = selected_Tracking_Type + "Optitrack_GameObject_" + DateTime.Now.ToString("MM-dd-yyyy hh.mm.ss") + ".txt";
            Optitrack_Data_Writer = File.CreateText(fileName);
            Optitrack_Data_Writer.WriteLine("World Timestamp, Recording Timestamp, Optitrack GameObject Roll, Optitrack GameObject Pitch, Optitrack GameObject Yaw, Sent Voltage, Current Velocity, Expected Velocity");
        }

        var voltage = selected_Tracking_Type + "Voltages_File_" + DateTime.Now.ToString("MM-dd-yyyy hh.mm.ss") + ".txt";
        voltage_Writer = File.CreateText(voltage);
        voltage_Writer.WriteLine("World Timestamp, Recording Timestamp, Sent Voltage, Velocity");



        freq = -2 * (float)Math.PI;                                             // Initialize the sine wave and position steps
        positionStep = new float[520];
        velocityStep = new float[600];
        sin = new float[100 + (int)(-freq * 2 / ideal_time_between_frames)];
        sin2 = new float[100 + (int)(-freq * 2 / ideal_time_between_frames)];
        sin05 = new float[100 + (int)(-freq * 2 / ideal_time_between_frames)];
        sin5 = new float[100 + (int)(-freq * 2 / ideal_time_between_frames)];
        velocity_file = File.ReadAllText(@"velocity.txt");

        //create trajectory with ideal velocity input/setpoint, to change depending on desired control and error updates
        //the below input represents the ideal velocity profile from NIcontroller.cs (4 movements, 4 position steps, 4 velocity steps, 4 sins of varying frequencies)
        premade_vel_string = velocity_file.Split();
        premade_voltages = new float[premade_vel_string.Length - 1];

            for (int i = 0; i < premade_voltages.Length; i++)
            {
                premade_voltages[i] = float.Parse(premade_vel_string[i], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture) / voltage_to_velocity_scaling_factor;
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
            velocity_List = new float[ideal_voltages.Length];
            position = new float[ideal_voltages.Length];
            index = 0;

    }

    void Update()
    {
        //Time Queues for calculating velocity, error, and time between frames
        time = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss.fff");                                          // get current world time as string
        var current_update_Time = DateTime.Now;                                                           // Record in game time and convert to seconds
        TimeSpan current_TimeSpan = current_update_Time - start_Experiment_Time;
        float current_Millisecond = current_TimeSpan.Milliseconds;
        float current_Seconds = ((current_TimeSpan.Minutes * 60 * 1000) + (current_TimeSpan.Seconds * 1000) + current_Millisecond) / 1000;

        time_Queue.Enqueue(current_Seconds);                                                                // Track time of the frames
        if (time_Queue.Count > 6) time_Queue.Dequeue();
        var time_array_float = time_Queue.Cast<float>().ToArray();
        float time_Diff = time_array_float[time_array_float.Length - 1] - time_array_float[0];

        float time_between_last_2_frames;                                                                   // Also keep track of time between frames for error
        if (time_array_float.Length > 1)
            time_between_last_2_frames = time_array_float[time_array_float.Length - 1] - time_array_float[time_array_float.Length - 2];
        else
            time_between_last_2_frames = 0.0f;

        // Yaw Queue for the GameObjects
        var yaw_used_in_steamvr_Queue = steamVR_Camera.transform.localEulerAngles.y;                   // Keep track of yaw angle, past 6 values, dequeues
        while (yaw_used_in_steamvr_Queue < -180) yaw_used_in_steamvr_Queue += 360;
        while (yaw_used_in_steamvr_Queue > 180) yaw_used_in_steamvr_Queue -= 360;
        steamvr_yaw_Queue.Enqueue(yaw_used_in_steamvr_Queue);
        if (steamvr_yaw_Queue.Count > 6) steamvr_yaw_Queue.Dequeue();
        var steamvr_yaw_array_float = steamvr_yaw_Queue.Cast<float>().ToArray();
        float steamvr_yaw_diff = steamvr_yaw_array_float[steamvr_yaw_array_float.Length - 1] - steamvr_yaw_array_float[0];
            
        current_steamvr_velocity = steamvr_yaw_diff / time_Diff;                                       // Use above values to calculate velocity

        if (selected_Tracking_Type != Tracking_Type.Lighthouse_Tracking)                               // Repeat for OptiTrack GameObject if present
        {
            var yaw_used_in_Queue = optitrack_Rigidbody.transform.localEulerAngles.y;                         
            while (yaw_used_in_Queue < -180) yaw_used_in_Queue += 360;
            while (yaw_used_in_Queue > 180) yaw_used_in_Queue -= 360;
            yaw_Queue.Enqueue(yaw_used_in_Queue);
            if (yaw_Queue.Count > 6) yaw_Queue.Dequeue();
            var yaw_array_float = yaw_Queue.Cast<float>().ToArray();
            float yaw_diff = yaw_array_float[yaw_array_float.Length - 1] - yaw_array_float[0];


            current_opti_velocity = yaw_diff / time_Diff;
        }
        //**********************************        
                                                       

               

        if (Input.GetKeyDown(KeyCode.Escape))           // If necessary, end experiment early by hitting Escape
        {
            OutputVoltage(0);
            if (selected_Tracking_Type != Tracking_Type.Lighthouse_Tracking)
            {
                Optitrack_Data_Writer.Close();
            }
            SteamVR_Data_Writer.Close();
            voltage_Writer.Close();
            Application.Quit();
        }
                

        if (Input.GetKeyDown(KeyCode.Space))                    // Press Spacebar to start sending voltages
        {
            start_Chair = true;
        }


        if (start_Chair)
        {            
            if (index < ideal_voltages.Length)                  // until you run out of values...
            {                
                OutputVoltage(ideal_voltages[index]);           // send voltage based on predetermined values
                index++;                                        // Move to next value
                velocity_List[index] = current_opti_velocity;       

                // Record all data - time, rotations, velocity for each gameobject, and position along the voltages list
                SteamVR_Data_Writer.WriteLine(time + "," 
                    + current_Seconds + "," 
                    + steamVR_Camera.transform.eulerAngles.z + "," 
                    + steamVR_Camera.transform.eulerAngles.x + "," 
                    + steamVR_Camera.transform.eulerAngles.y + ", " 
                    + ideal_voltages[index] + ", " 
                    + ideal_voltages[index] * voltage_to_velocity_scaling_factor + "," 
                    + velocity_List[index] + "," 
                    + current_steamvr_velocity);
                if (selected_Tracking_Type != Tracking_Type.Lighthouse_Tracking)
                {
                    Optitrack_Data_Writer.WriteLine(time + "," 
                        + current_Seconds + "," 
                        + optitrack_Rigidbody.transform.eulerAngles.z + "," 
                        + optitrack_Rigidbody.transform.eulerAngles.x + "," 
                        + optitrack_Rigidbody.transform.eulerAngles.y + ", " 
                        + ideal_voltages[index] + ", " 
                        + ideal_voltages[index] * voltage_to_velocity_scaling_factor + "," 
                        + velocity_List[index] + "," 
                        + current_opti_velocity);
                }
                voltage_Writer.WriteLine(time + "," 
                    + current_Seconds + "," 
                    + ideal_voltages[index] + "," 
                    + ideal_voltages[index] * voltage_to_velocity_scaling_factor);

            }
            else
            {                
                OutputVoltage(0);                                                   // once out of values, end experiment
                if (selected_Tracking_Type != Tracking_Type.Lighthouse_Tracking)
                {
                    Optitrack_Data_Writer.Close();
                }
                SteamVR_Data_Writer.Close();
                voltage_Writer.Close();
                Application.Quit();
            }
        }
    }

    private void OnDestroy()
    {       
        OutputVoltage(0);                                                       // Stop chair on escape
        if (selected_Tracking_Type != Tracking_Type.Lighthouse_Tracking)
        {
            Optitrack_Data_Writer.Close();
        }
        SteamVR_Data_Writer.Close();
        voltage_Writer.Close();
    }
}