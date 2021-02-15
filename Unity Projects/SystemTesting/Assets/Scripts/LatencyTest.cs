using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.VR;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading;
using NaturalPoint;
using NaturalPoint.NatNetLib;



public class LatencyTest : MonoBehaviour
{
    //Components used in Trial conditions
    public int trial_Number;                         // The number of the trial
    public int number_of_trials;
    public bool latency_number_running;              // Bool for entering initials at begining of experiment, prevents accidental pausing at this phase    

    // Tracked Objects
    public GameObject optitrack_Rigidbody;                      // The game object for keeping track of velocity
    public GameObject steamVR_Camera;                           // The game object for using the raycaster
    public OptitrackStreamingClient StreamingClient;            // Access to the streaming client script to grab position of the rigid body
    private float current_opti_velocity;                        // Current velocity of tracked objects
    private float current_steamvr_velocity;
    public bool headset_is_moving = false;

    // Display physical update components
    public GameObject display_cube;
    public Material green;
    public Material white;
    public Material red;

    // Data Recording Components
    public StreamWriter file1_Writer;                               // Creates/writes to files
    public StreamWriter file2_Writer;

    private Queue yaw_Queue;                                        // Queue for keeping track of optitrack yaw for velocity calculation     
    private Queue steamvr_yaw_Queue;                                // Queue for keeping track of steamVR yaw for velocity calculation   
    private Queue time_Queue;                                       // Time queue for velocity calculations    

    DateTime start_Experiment_Time;                                 // Time stamps
    public float current_Seconds;
    string time;
    public float reported_latency;                                  // Unity's reported update latency

    // Switching between types of tracking
    public enum Tracking_Type
    {
        Optitrack_Rigidbody_Tracking, Lighthouse_Tracking, OpenVR_Tracking
    };
    public Tracking_Type selected_Tracking_Type = Tracking_Type.Optitrack_Rigidbody_Tracking;     // Initiialize to OptiTrack as default


    // Use this for initialization
    void Start()
    {
        DateTime start_Experiment_Time = DateTime.Now;          // Begin experiment timer
        trial_Number = 1;                                       // Set trial start
        number_of_trials = 100;

        yaw_Queue = new Queue();                                // Initialize queues
        steamvr_yaw_Queue = new Queue();
        time_Queue = new Queue();

        display_cube = GameObject.Find("Display Cube");         // Initialize Cube
        if (display_cube == null) Debug.Log("Didn't find cube");

        // Write Files for Reported Latency
        var file1_Name = selected_Tracking_Type + "_Latency_Test_" + DateTime.Now.ToString("MM-dd-yy-hh-mm-ss-ffff") + ".txt";
        file1_Writer = File.CreateText(file1_Name);
        file1_Writer.WriteLine("World Time ,Experiment Time ,Trial# ,Reported Latency");
        
        var file2_Name = selected_Tracking_Type + "_Tracking_Data" + DateTime.Now.ToString("MM-dd-yy-hh-mm-ss-ffff") + ".txt";
        file2_Writer = File.CreateText(file2_Name);
        file2_Writer.WriteLine("World Time ,Experiment Time ,Trial# , SteamVR X ,SteamVR Y ,SteamVR Z , SteamVR Velocity, OptiTrack Rigidbody X,OptiTrack Rigidbody Y,OptiTrack Rigidbody Z, OptiTrack Rigidbody Velocity");

        StartCoroutine(LatencyTester());
    }




    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))       // To end test early, hit Escape key
        {
            file1_Writer.Close();
            Application.Quit();
        }

        //Time Queues for calculating velocity, error, and time between frames
        time = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss.fff");                                          // get current world time as string
        var current_update_Time = DateTime.Now;                                                           // Record in game time and convert to seconds
        TimeSpan current_TimeSpan = current_update_Time - start_Experiment_Time;
        float current_Millisecond = current_TimeSpan.Milliseconds;
        current_Seconds = ((current_TimeSpan.Minutes * 60 * 1000) + (current_TimeSpan.Seconds * 1000) + current_Millisecond) / 1000;

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

        current_steamvr_velocity = steamvr_yaw_diff / time_Diff;                                             // Use above values to calculate velocity
        if (Math.Abs(current_steamvr_velocity) > 1.0)
        {
            Debug.Log("Headset is moving");
            headset_is_moving = true;

        }
        else
        {
            Debug.Log("Headset is still");
            headset_is_moving = false;
        }


        if (selected_Tracking_Type != Tracking_Type.Lighthouse_Tracking)
        {
            var yaw_used_in_Queue = optitrack_Rigidbody.transform.localEulerAngles.y;                         // Repeat for OptiTrack GameObject
            while (yaw_used_in_Queue < -180) yaw_used_in_Queue += 360;
            while (yaw_used_in_Queue > 180) yaw_used_in_Queue -= 360;
            yaw_Queue.Enqueue(yaw_used_in_Queue);
            if (yaw_Queue.Count > 6) yaw_Queue.Dequeue();
            var yaw_array_float = yaw_Queue.Cast<float>().ToArray();
            float yaw_diff = yaw_array_float[yaw_array_float.Length - 1] - yaw_array_float[0];

            current_opti_velocity = yaw_diff / time_Diff;
            if (Math.Abs(current_opti_velocity) > 1.0)
            {
                Debug.Log("Headset is moving");
                headset_is_moving = true;
            }
            else
            {
                Debug.Log("Headset is still");
                headset_is_moving = false;
            }

            file2_Writer.WriteLine(DateTime.Now + ","
                + current_Seconds + ","
                + trial_Number + ","
                + steamVR_Camera.transform.localEulerAngles.x + ","
                + steamVR_Camera.transform.localEulerAngles.y + ","
                + steamVR_Camera.transform.localEulerAngles.z + ","
                + current_steamvr_velocity + ","
                + optitrack_Rigidbody.transform.localEulerAngles.x + ","
                + optitrack_Rigidbody.transform.localEulerAngles.y + ","
                + optitrack_Rigidbody.transform.localEulerAngles.z + ","
                + current_opti_velocity);
        }
        else
        {
            file2_Writer.WriteLine(DateTime.Now + ","
            + current_Seconds + ","
            + trial_Number + ","
            + steamVR_Camera.transform.localEulerAngles.x + ","
            + steamVR_Camera.transform.localEulerAngles.y + ","
            + steamVR_Camera.transform.localEulerAngles.z + ","
            + current_steamvr_velocity);
        }
        //**********************************        

    }

    private IEnumerator LatencyTester()
    {
        while (trial_Number < number_of_trials)                                              // Continue until desired number of trials is achieved
        {
            Debug.Log("Trial Number:  " + trial_Number);
            display_cube.GetComponent<MeshRenderer>().material = green;

            while (!headset_is_moving)                                                      // Look for movement, do notchange display until we notice a change in velocity   
            {
                yield return null;
            }

            var move_Time = DateTime.Now;                                                   // Grab time that movement is detected
            TimeSpan move_TimeSpan = move_Time - start_Experiment_Time;
            float move_time_milliseconds = move_TimeSpan.Milliseconds;

            display_cube.GetComponent<MeshRenderer>().material = white;                     // Update Display tp indicate movement

            var update_time = DateTime.Now;
            TimeSpan update_timeSpan = update_time - start_Experiment_Time;
            float update_time_milliseconds = update_timeSpan.Milliseconds;
            float reported_latency = update_time_milliseconds - move_time_milliseconds;     // Determine if unity detects any latency between movement detection and update

            file1_Writer.WriteLine(DateTime.Now + "," + current_Seconds + "," + trial_Number + "," + reported_latency);
            trial_Number++;                                                                 // Increment and record data

            yield return new WaitForSeconds(1.0f);                                          // Wait for one second before updating

            display_cube.GetComponent<MeshRenderer>().material = red;                       // Update Display to red as long as it continues to move
            yield return new WaitForSeconds(1.0f);                                          // Wait before checking if headset is still

            while (headset_is_moving)                                                       // Don't start next loop until headset is still
            {
                yield return null;
            }

            display_cube.GetComponent<MeshRenderer>().material = green;                     // Indicate display is ready

        }
        file1_Writer.Close();
        Application.Quit();
    }
}

