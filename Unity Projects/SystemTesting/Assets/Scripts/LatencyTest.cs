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
    public int trial_Number;                                    // The number of the trial
    public int number_of_trials;
    public bool latency_number_running;                         // Bool for entering initials at begining of experiment, prevents accidental pausing at this phase    

    // Tracked Objects
    public GameObject hmd;                                      // The game object for the HMD
    private float current_velocity;                             // Current velocity of HMD
    public bool headset_is_moving = false;
    private Queue position_queue;                                        // Queue for keeping track of the HMD's yaw for velocity calculation     
    private Queue time_Queue;                                       // Time queue for velocity calculations  

    // Display physical update components
    public GameObject display_cube;
    public Material green;
    public Material white;
    public Material red;

    // Data Recording Components
    public StreamWriter file_writer;                                // Creates/writes to files
    DateTime start_Experiment_Time;                                 // Time stamps
    public float current_Seconds;
    string time;
    public float reported_latency;                                  // Unity's reported update latency

    // Switching between types of tracking
    public enum Tracking_System
    {
        optitrack_tracking, basestation_tracking
    };
    public Tracking_System t_system = Tracking_System.optitrack_tracking;     // Initiialize to OptiTrack as default



    // Use this for initialization
    void Start()
    {
        DateTime start_Experiment_Time = DateTime.Now;          // Begin experiment timer
        trial_Number = 1;                                       // Set trial start
        number_of_trials = 100;

        // Set type of tracking to be equivalent to gameobject used
        if (t_system == Tracking_System.optitrack_tracking)
        {
            hmd = GameObject.Find("OptiTrack");
        }
        else if (t_system == Tracking_System.basestation_tracking)
        {
            hmd = GameObject.Find("BaseStation");
        }
        else
        {
            Debug.Log("No tracking system found.");
        }

        position_queue = new Queue();                                                   // Initialize queues
        time_Queue = new Queue();

        display_cube = GameObject.Find("Display Cube");                                 // Initialize Cube
        if (display_cube == null) Debug.Log("Didn't find cube");
        display_cube.GetComponent<MeshRenderer>().material = green;                     // Make sure display starts green

        // Create file for reported latency
        var file_Name = t_system + "_Latency_Test_" + DateTime.Now.ToString("MM-dd-yy-hh-mm-ss-ffff") + ".txt";
        file_writer = File.CreateText(file_Name);
        file_writer.WriteLine("Time_of_Detected_Movement_World_Time ,Time_of_Detected_Movement_Experiment ,Trial_# ,Position_X ,Position_Y ,Position_Z ,Reported_Latency ");

        
    }




    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))       // To end test early, hit Escape key
        {
            file_writer.Close();
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


        // Position Queue for the HMD
        var current_position = hmd.transform.position;                  // Keep track of yaw angle, past 6 values, dequeues

        position_queue.Enqueue(current_position);                                                                   // Put current position into queue

        if (position_queue.Count > 6) position_queue.Dequeue();                                                     // Dequeue after 6 - only keep position from last 6 frames
        var position_array_float = position_queue.Cast<float>().ToArray();

        float position_diff = position_array_float[position_array_float.Length - 1] - position_array_float[0];      // Calculate the difference in position between first and last frame

        double stdev = 0;                                                   // Calculate the standard deviation between the last 6 frames
        double avg = position_array_float.Average();
        stdev = Math.Sqrt(position_array_float.Average(v => Math.Pow(v - avg, 2)));
        current_velocity = position_diff / time_Diff;                      // Use above values to calculate velocity

        //if (Math.Abs(current_velocity) > 1.0)                            // Can trigger coroutine from a velocity change
        if (trial_Number < number_of_trials && Math.Abs(stdev) > 1.0)                                         // Trigger coroutine based on change in standard deviation of the position
        {
            Debug.Log("Headset is moving");
            headset_is_moving = true;
            StartCoroutine(LatencyTester());         
        }
        else
        {
            Debug.Log("Headset is still");
            headset_is_moving = false;
        }   
    }


    private IEnumerator LatencyTester()
    {
        Debug.Log("Trial Number:  " + trial_Number);

        display_cube.GetComponent<MeshRenderer>().material = white;                         // Update Display to indicate movement

        var move_Time = DateTime.Now;                                                   // Grab time that movement is detected
        TimeSpan move_TimeSpan = move_Time - start_Experiment_Time;
        float move_time_milliseconds = move_TimeSpan.Milliseconds;
        /*
            var update_time = DateTime.Now;
            TimeSpan update_timeSpan = update_time - start_Experiment_Time;
            float update_time_milliseconds = update_timeSpan.Milliseconds;
            float reported_latency = update_time_milliseconds - move_time_milliseconds;     // Determine if unity detects any latency between movement detection and update
            */

        //     file_Writer.WriteLine("Time_of_Detected_Movement_World_Time ,Time_of_Detected_Movement_Experiment ,Trial_# ,Position_X ,Position_Y ,Position_Z ,Reported_Latency ");

        file_writer.WriteLine(DateTime.Now + "," + current_Seconds + "," + trial_Number + "," + reported_latency);
        trial_Number++;                                                                 // Increment and record data

        yield return new WaitForSeconds(1.0f);                                          // Wait for one second before updating
        display_cube.GetComponent<MeshRenderer>().material = red;                       // Update Display to red as long as it continues to move
        yield return new WaitForSeconds(1.0f);                                          // Wait before checking if headset is still

        while (headset_is_moving)                                                       // Don't start next loop until headset is still
        {
            yield return null;
        }

        display_cube.GetComponent<MeshRenderer>().material = green;                         // Indicate display is ready

        if (trial_Number > number_of_trials)                                                // End the latency test
        {
            file_writer.Close();
            Application.Quit();
        }
    }
}

