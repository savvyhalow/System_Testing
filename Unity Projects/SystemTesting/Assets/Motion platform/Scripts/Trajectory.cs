using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Text;
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System;

public class Trajectory : MonoBehaviour {

    [DllImport("C++WriteDLL")]
    public static extern void WriteToMotionFile(float surge, float lateral, float heave, float roll, float pitch, float yaw, bool absolute_mode, int traj_rate);

    /*
    [DllImport("C++WriteDLL")]
    public static extern void CallWriteTrajectoryThread();
    */

    //keep track of which mode the trajectory file is for
    enum dof_mode
    {
        absolute,
        relative,
        neither
    }

    enum dof_type
    {
        surge,
        lateral,
        heave,
        roll,
        pitch,
        yaw
    }

    //last dof data sent out
    dof_data the_dof_data;
    //dofs in the trajectory file
    float[][] trajectory_dofs;
    //differences between successive dofs in the trajectory file
    float[][] trajectory_dof_diff;
    //time in seconds since the start of the game
    float time_trajectory_started;
    //initialized to false. If true, trajectory has started. Trajectory set to true and started upon key press.
    bool trajectory_started;
    //initialized to false. If true, trajectory has finished.
    bool trajectory_finished;
    //how fast the dof commands will be sent out (dof commands per second)
    float trajectory_rate;
    //keeps track of which set of dofs to send out in trajectory_dof_diff
    int trajectory_index_last;
    //path to the trajectory file
    string trajectory_file_path;
    //rate that the trajectory file is made for (may be higher than trajectory_rate)
    float trajectory_file_rate;
    //the rate that the trajectory file is made for divided by the rate that the trajectory will run at
    int rate_ratio;

    //max that each dof should move by in relative mode(taken from original xbox controller values in moog code)
    float max_dof_relative_movement_surge = 0.00008f;
    float max_dof_relative_movement_lateral = 0.00008f;
    float max_dof_relative_movement_heave = 0.00004f;
    float max_dof_relative_movement_roll = 0.004f;
    float max_dof_relative_movement_pitch = 0.004f;
    float max_dof_relative_movement_yaw = 0.004f;

    //max that each dof should move by in absolute mode (taken from original MoogCom code checking max values). 
    //the min of each dof is the negative of the max with the exception of heave
    float max_dof_absolute_movement_surge = 0.25f;
    float max_dof_absolute_movement_lateral = 0.25f;
    float max_dof_absolute_movement_heave = 0.0f;
    float min_dof_absolute_movement_heave = -0.4572f;
    float max_dof_absolute_movement_roll = 28.9945f;
    float max_dof_absolute_movement_pitch = 32.9938f;
    float max_dof_absolute_movement_yaw = 28.9945f;

    //initialize dof values at 0
    float surge, lateral, heave, roll, pitch, yaw;

    //keep track of what mode the read trajectory file is in. 
    dof_mode traj_file_mode;

    class dof_data
    {
        public float surge, lateral, heave, roll, pitch, yaw;
    }

    // Use this for initialization
    void Start()
    {
        //initialize to neither for the mode the read trajectory file is in.
        traj_file_mode = dof_mode.neither;

        surge = lateral = heave = roll = pitch = yaw = 0.000f;

        //set interval in seconds at which physics and other fixed frame rate updates (like MonoBehaviour's FixedUpdate) are performed.
        //Note that the fixedDeltaTime interval is with respect to the in-game time affected by timeScale.
        Time.fixedDeltaTime = 0.01f;

        //set fps to the fps of the Vive
        Application.targetFrameRate = 90;

        //set time to pass as fast as realtime
        Time.timeScale = 1.0f;

        //initialize
        trajectory_index_last = -1;

        //trajectory does not start until the user presses space.
        trajectory_started = false;

        //trajectory is not finished until all dof value sets are used.
        trajectory_finished = false;

        //set the rate that the trajectory will run at
        trajectory_rate = 90.0f;

        //the rate that the trajectory file is made for
        //trajectory_file_rate = 2000.0f;
        trajectory_file_rate = 90.0f;


        //assign the path for the trajectory file
        trajectory_file_path = "Assets/Trajectory.txt";

        //make a new object to hold the dof values
        the_dof_data = new dof_data();

        //initialize
        time_trajectory_started = 0.0f;

        //initialize first index into the array of array of floats that will be used
        int line_index = 0;
        //initialize with initial assumption that the rates are the same betwwen the trajectory file and Unity
        rate_ratio = 1;

        

        //read in all of the lines with each line being a separate string
        var raw_data_strings = File.ReadAllLines(trajectory_file_path);

        /*
        foreach(var line in raw_dof_strings)
        {
            Debug.Log(line);
        }
        */

        //separate out the first line which should contain absolute/relative and an number representing the rate of the file
        string file_header = raw_data_strings[0];
        //split the string by whitespace and remove all blank entries
        string[] header_parts = file_header.Split(new char[0],StringSplitOptions.RemoveEmptyEntries);
        //header should only have 2 parts
        if(header_parts.Length != 2)
        {
            //print out the header and quit
            string total_header = "";
            foreach(string h_part in header_parts)
            {
                total_header += h_part + " ";
            }

            Debug.Log("Incorrect header format. Header=\""+total_header+"\"");
            Application.Quit();
        }

        //First part of the header should be the string "absolute" or "relative"
        if(String.Compare(header_parts[0], "absolute", true) == 0)
        {
            //trajectory file is in absolute mode
            Debug.Log("Absolute dof value mode.");
            traj_file_mode = dof_mode.absolute;
        }
        else if (String.Compare(header_parts[0], "relative", true) == 0)
        {
            //trajectory file is in relative mode
            Debug.Log("Relative dof value mode.");
            traj_file_mode = dof_mode.relative;
        }
        else
        {
            Debug.Log("Incorrect header format. First Header part=\"" + header_parts[0] + "\" but should be \"absolute\" or \"relative\" case insensitive.");
            Application.Quit();
        }

        {
            //the float value if the TrParse succeeds
            float result;
            //try to parse the string into a float
            if (float.TryParse(header_parts[1], out result))
            {
                //save the float
                Debug.Log(String.Format("Trajectory file rate = {0}Hz", result));
                trajectory_file_rate = result;
            }
            else
            {
                Debug.Log("Error: File rate string could not be parsed.");
                Application.Quit();
            }
        }


        //make new array to hold only the dof values
        string[] raw_dof_strings = new string[raw_data_strings.Length-1];
        //copy over all the dof strings besides the first one holding the header
        Array.Copy(raw_data_strings, 1, raw_dof_strings, 0, raw_data_strings.Length-1);

        //initialize the jagged array
        trajectory_dofs = new float[raw_dof_strings.Length][];
        for(int i = 0; i < trajectory_dofs.Length; i++)
        {
            trajectory_dofs[i] = new float[6];
        }

        //parse the dof strings one at a time and save them as floats
        foreach (string line in raw_dof_strings)
        {
            //split the string by whitespace and remove all blank entries
            string[] parts = line.Split(new char[0], StringSplitOptions.RemoveEmptyEntries);

            //take each string representation of the floats and turn them into floats
            for (int i = 0; i < parts.Length; i++)
            {
                //the float value if the TrParse succeeds
                float result;
                //try to parse the string into a float
                if (float.TryParse(parts[i], out result))
                {
                    //save the float
                    trajectory_dofs[line_index][i] = result;
                }
                else
                {
                    Debug.Log("Error: string could not be parsed.");
                    Application.Quit();
                }
            }
            //increment index so that the next set of floats is saved in the next array element of trajectory_dofs
            line_index++;
        }

        /*
        //write to console each line of dof values
        foreach(var line in trajectory_dofs)
        {
            string dofs = "";
            foreach(var dofvalue in line)
            {
                dofs += dofvalue + " ";
            }
            Debug.Log(dofs);
        }
        */

        //downsample if the rate of the trajectory file is greater than the update rate 
        //(90Hz for Vive. May fluctuate based on the load that the graphics are putting on the rendering engine)
        if(Mathf.Approximately(trajectory_file_rate, trajectory_rate))
        {
            rate_ratio = 1;
        }
        else
        {
            Debug.Log("Error: Trajectory file's rate of " + trajectory_file_rate + " is not the same as the required rate of the trajectory of " +
                 trajectory_rate + "Hz. Please use a trajectory file with a rate that equal to " + trajectory_rate + "Hz. Quitting.");
            Application.Quit();
        }

        /*
        //old code used for downsampling
        else if (trajectory_file_rate > trajectory_rate)
        {
            rate_ratio = Mathf.FloorToInt(trajectory_file_rate / trajectory_rate);

        }
        else if(trajectory_file_rate < trajectory_rate)
        {
            Debug.Log("Error: Trajectory file's rate of " + trajectory_file_rate + " is greater than the intended rate of the trajectory of " + 
                trajectory_rate + ". Please use a trajectory file with a rate that is greater than or equal to " + trajectory_rate + ". Quitting.");
            Application.Quit();
        }
        */


        //The new array to hold the differences between downsampled dof value sets' size
        int size_of_trajectory_dof_diff = Mathf.FloorToInt(trajectory_dofs.Length / rate_ratio);
        //initialize the jagged array. If the rate of the trajectory file is greater than the update rate, downsampling will occur. 
        trajectory_dof_diff = new float[size_of_trajectory_dof_diff - 1][];
        for (int i = 0; i < trajectory_dof_diff.Length; i++)
        {
            trajectory_dof_diff[i] = new float[6];
        }

        /*
        Debug.Log("trajectory_dof_diff " + trajectory_dof_diff[0][0]);
        var difference = trajectory_dofs[22][0] - trajectory_dofs[0][0];
        Debug.Log("traj dofs diff " + difference);
        */

        //Debug.Log("trajectory_dof_diff.Length="+ trajectory_dof_diff.Length);

        //Debug.Log("trajectory_dof_diff " + trajectory_dof_diff[1][0]);

        //calculate the differences between successive dof sets and save them
        for (int i = 0; i < trajectory_dof_diff.Length - 1; i++)
        {
            for(int j = 0; j < 6; j++)
            {
                //Debug.Log("i="+i+", j="+j);
                trajectory_dof_diff[i][j] = trajectory_dofs[(i+1)*rate_ratio][j] - trajectory_dofs[i*rate_ratio][j];
            }
        }

        /*
        foreach (var line in trajectory_dof_diff)
        {
            string dofs = "";
            foreach (var dofvalue in line)
            {
                dofs += dofvalue + " ";
            }
            Debug.Log(dofs);
        }
        */
    }

    // Update is called once per frame
    void Update()
    {
        //space bar starts the trajectory
        if (Input.GetKeyDown(KeyCode.Space) && !trajectory_started)
        {
            time_trajectory_started = Time.time;
            trajectory_started = true;
            Debug.Log(String.Format("{0} Trajectory started", traj_file_mode == dof_mode.absolute ? "Absolute" : "Relative"));
        }

        if (trajectory_started && !trajectory_finished)
        {
            //time in seconds that the trajectory has been running
            float trajectory_runtime = Time.time - time_trajectory_started;

            //time in seconds that need to elapse until the next command should be sent
            float time_between_commands = 1.0f / trajectory_rate;

            //index into trajectory_dof_diff for which set of dof commands should be sent now
            int trajectory_index_now = Mathf.FloorToInt(trajectory_runtime / time_between_commands);

            //send out the next dof command if enough time has elapsed
            if (trajectory_index_now > trajectory_index_last)
            {
                //update the last index / set of dof commands used
                trajectory_index_last = trajectory_index_now;




                if (traj_file_mode == dof_mode.absolute)
                {
                    //if the index exceeds the maximum index for the trajectory_dof_diff array, all dof value sets have been used and the trajectory is finished
                    if (trajectory_index_now >= trajectory_dofs.Length)
                    {
                        trajectory_finished = true;
                        Debug.Log("Absolute Trajectory finished.");
                    }
                }
                else if (traj_file_mode == dof_mode.relative)
                {
                    //if the index exceeds the maximum index for the trajectory_dof_diff array, all dof value sets have been used and the trajectory is finished
                    if (trajectory_index_now >= trajectory_dof_diff.Length)
                    {
                        trajectory_finished = true;
                        Debug.Log("Relative Trajectory finished.");
                    }
                }
                else
                {
                    Debug.Log("Incorrect header format. The error should have been caught earlier in the Start function.");
                    Application.Quit();
                }


                //if trajectory is not finished
                if (!trajectory_finished)
                {
                    if (traj_file_mode == dof_mode.absolute)
                    {
                        //use the set of dof value differences that corresponds to the current time
                        surge = trajectory_dofs[trajectory_index_now][0];
                        lateral = trajectory_dofs[trajectory_index_now][1];
                        heave = trajectory_dofs[trajectory_index_now][2];
                        roll = trajectory_dofs[trajectory_index_now][3];
                        pitch = trajectory_dofs[trajectory_index_now][4];
                        yaw = trajectory_dofs[trajectory_index_now][5];

                        //check that the values for the dofs do not exceed the limits, set to the max allowable value if limits are exceeded
                        if (ExceedsAbsoluteDofLimits(surge, trajectory_index_now, dof_type.surge))
                        {
                            surge = max_dof_absolute_movement_surge * Mathf.Sign(surge);
                        }
                        if (ExceedsAbsoluteDofLimits(lateral, trajectory_index_now, dof_type.lateral))
                        {
                            lateral = max_dof_absolute_movement_lateral * Mathf.Sign(lateral);
                        }
                        if (ExceedsAbsoluteDofLimits(heave, trajectory_index_now, dof_type.heave))
                        {
                            //if heave is positive or zero (exceeds max limit of 0.0f)
                            if(Mathf.Approximately(Mathf.Sign(heave), 1.0f))
                            {
                                heave = max_dof_relative_movement_heave;
                            }
                            //heave exceeds min limit
                            else
                            {
                                heave = min_dof_absolute_movement_heave;
                            }
                        }
                        if (ExceedsAbsoluteDofLimits(roll, trajectory_index_now, dof_type.roll))
                        {
                            roll = max_dof_absolute_movement_roll * Mathf.Sign(roll); ;
                        }
                        if (ExceedsAbsoluteDofLimits(pitch, trajectory_index_now, dof_type.pitch))
                        {
                            pitch = max_dof_absolute_movement_pitch * Mathf.Sign(pitch); ;
                        }
                        if (ExceedsAbsoluteDofLimits(yaw, trajectory_index_now, dof_type.yaw))
                        {
                            yaw = max_dof_absolute_movement_yaw * Mathf.Sign(yaw); ;
                        }
                    }
                    else if (traj_file_mode == dof_mode.relative)
                    {
                        //use the set of dof value differences that corresponds to the current time
                        surge = trajectory_dof_diff[trajectory_index_now][0];
                        lateral = trajectory_dof_diff[trajectory_index_now][1];
                        heave = trajectory_dof_diff[trajectory_index_now][2];
                        roll = trajectory_dof_diff[trajectory_index_now][3];
                        pitch = trajectory_dof_diff[trajectory_index_now][4];
                        yaw = trajectory_dof_diff[trajectory_index_now][5];

                        //temporary fix because the downsampling + differences between successive dof values results in dof values as large as 0.104 when the max should be much much smaller.
                        surge /= 1300.0f;
                        lateral /= 1300.0f;
                        heave /= 1300.0f;
                        roll /= 1300.0f;
                        pitch /= 1300.0f;
                        yaw /= 1300.0f;

                        //check that the values for the dofs do not exceed the limits, set to the max allowable value if limits are exceeded
                        if (ExceedsRelativeDofLimits(surge, trajectory_index_now, dof_type.surge))
                        {
                            surge = max_dof_relative_movement_surge;
                        }
                        if (ExceedsRelativeDofLimits(lateral, trajectory_index_now, dof_type.lateral))
                        {
                            lateral = max_dof_relative_movement_lateral;
                        }
                        if (ExceedsRelativeDofLimits(heave, trajectory_index_now, dof_type.heave))
                        {
                            heave = max_dof_relative_movement_heave;
                        }
                        if (ExceedsRelativeDofLimits(roll, trajectory_index_now, dof_type.roll))
                        {
                            roll = max_dof_relative_movement_roll;
                        }
                        if (ExceedsRelativeDofLimits(pitch, trajectory_index_now, dof_type.pitch))
                        {
                            pitch = max_dof_relative_movement_pitch;
                        }
                        if (ExceedsRelativeDofLimits(yaw, trajectory_index_now, dof_type.yaw))
                        {
                            yaw = max_dof_relative_movement_yaw;
                        }
                    }
                    else
                    {
                        Debug.Log("Incorrect header format. The error should have been caught earlier in the Start function.");
                        Application.Quit();
                    }
                }

                //save the current dofs
                the_dof_data.surge = surge;
                the_dof_data.lateral = lateral;
                the_dof_data.heave = heave;
                the_dof_data.roll = roll;
                the_dof_data.pitch = pitch;
                the_dof_data.yaw = yaw;

                //call the function from the DLL (dynamic link library) to write the six dof values to the file named "move_to.txt"
                WriteToMotionFile(the_dof_data.surge, the_dof_data.lateral, the_dof_data.heave, the_dof_data.roll, the_dof_data.pitch, the_dof_data.yaw, traj_file_mode == dof_mode.absolute, (int)Math.Round(trajectory_file_rate));
            }
        }
        else
        {
            if (traj_file_mode == dof_mode.relative)
            {
                //if trajectory is finished or hasn't started, the 0.0f values for the dofs will be written to the file so that no further movement will occur.
                the_dof_data.surge = 0.000f;
                the_dof_data.lateral = 0.000f;
                the_dof_data.heave = 0.000f;
                the_dof_data.roll = 0.000f;
                the_dof_data.pitch = 0.000f;
                the_dof_data.yaw = 0.000f;

                //call the function from the DLL (dynamic link library) to write the six dof values to the file named "move_to.txt"
                WriteToMotionFile(the_dof_data.surge, the_dof_data.lateral, the_dof_data.heave, the_dof_data.roll, the_dof_data.pitch, the_dof_data.yaw, traj_file_mode == dof_mode.absolute, (int)Math.Round(trajectory_file_rate));
            }
            else if(traj_file_mode == dof_mode.absolute)
            {
                if(!trajectory_started)
                {

                    //if trajectory is finished or hasn't started, the default values for the engaged state will be used so that the platform doesn't move.
                    the_dof_data.surge = 0.000f;
                    the_dof_data.lateral = 0.000f;
                    the_dof_data.heave = min_dof_absolute_movement_heave/2.0f;
                    the_dof_data.roll = 0.000f;
                    the_dof_data.pitch = 0.000f;
                    the_dof_data.yaw = 0.000f;

                    //call the function from the DLL (dynamic link library) to write the six dof values to the file named "move_to.txt"
                    WriteToMotionFile(the_dof_data.surge, the_dof_data.lateral, the_dof_data.heave, the_dof_data.roll, the_dof_data.pitch, the_dof_data.yaw, traj_file_mode == dof_mode.absolute, (int)Math.Round(trajectory_file_rate));
                }
            }
            else
            {
                Debug.Log("Incorrect header format. The error should have been caught earlier in the Start function.");
                Application.Quit();
            }
        }
    }

    
    //constant frame rate independent update call
    private void FixedUpdate()
    {
        
    }

    //Check if the values for the dofs exceed the limits in absolute mode. 
    private bool ExceedsAbsoluteDofLimits(float dof, int trajectory_index_now, dof_type type_of_dof)
    {
        //initialize to 0
        float max_dof = 0.0f;
        //set the max_dof based on the type of dof
        switch (type_of_dof)
        {
            case dof_type.surge:
                max_dof = max_dof_absolute_movement_surge;
                break;
            case dof_type.lateral:
                max_dof = max_dof_absolute_movement_lateral;
                break;
            case dof_type.heave:
                max_dof = max_dof_absolute_movement_heave;
                break;
            case dof_type.roll:
                max_dof = max_dof_absolute_movement_roll;
                break;
            case dof_type.pitch:
                max_dof = max_dof_absolute_movement_pitch;
                break;
            case dof_type.yaw:
                max_dof = max_dof_absolute_movement_yaw;
                break;
            default:
                Debug.Log("Error: dof_type input variable is not one of the 6 dof types.");
                Application.Quit();
                break;
        }

        //for all dofs besides heave, check that the value does not exceed the limits (-max_dof, max_dof)
        if(type_of_dof != dof_type.heave)
        {
            //If absolute of the dof value is greater than the limit, return true
            if (FloatGreaterThan(Mathf.Abs(dof), Mathf.Abs(max_dof)))
            {
                Debug.Log("Warning: Absolute of dof_type(" + type_of_dof + ") value of " + dof + " exceeds maximum allowed value of " + max_dof + " at index " + trajectory_index_now);
                return true;
            }
            else
                return false;
        }
        //for heave, check that that the value does not exceed the max or min limits (not centered around 0)
        else
        {
            //If absolute of the dof value is greater than the limit, return true
            if (FloatGreaterThan(dof, max_dof) || FloatLessThan(dof, min_dof_absolute_movement_heave))
            {
                Debug.Log("Warning: dof_type(" + type_of_dof + ") value of " + dof + " exceeds max allowed value of " 
                    + max_dof + " or min allowed value of "+ min_dof_absolute_movement_heave + " at index " + trajectory_index_now);
                return true;
            }
            else
                return false;
        }

    }

    //Check if the values for the dofs exceed the limits in relative mode. 
    private bool ExceedsRelativeDofLimits(float dof, int trajectory_index_now, dof_type type_of_dof)
    {
        //initialize to 0
        float max_dof = 0.0f;
        switch (type_of_dof)
        {
            case dof_type.surge:
                max_dof = max_dof_relative_movement_surge;
                break;
            case dof_type.lateral:
                max_dof = max_dof_relative_movement_lateral;
                break;
            case dof_type.heave:
                max_dof = max_dof_relative_movement_heave;
                break;
            case dof_type.roll:
                max_dof = max_dof_relative_movement_roll;
                break;
            case dof_type.pitch:
                max_dof = max_dof_relative_movement_pitch;
                break;
            case dof_type.yaw:
                max_dof = max_dof_relative_movement_yaw;
                break;
            default:
                Debug.Log("Error: dof_type input variable is not one of the 6 dof types.");
                Application.Quit();
                break;
        }

        //If absolute of the dof value is greater than the limit, return true
        if (FloatGreaterThan(Mathf.Abs(dof), Mathf.Abs(max_dof)))
        {
            Debug.Log("Warning: Absolute of dof_type(" + type_of_dof + ") value of " + dof + " exceeds maximum allowed value of " + max_dof + " at index " + trajectory_index_now);
            return true;
        }
        else
            return false;
    }

    //true if first float is greater than the second
    private bool FloatGreaterThan(float dof, float max_dof)
    {
        if (dof > max_dof && !Mathf.Approximately(dof, max_dof))
        {
            return true;
        }
        else
            return false;
    }

    //true if first float is less than the second
    private bool FloatLessThan(float dof, float min_dof)
    {
        if (dof < min_dof && !Mathf.Approximately(dof, min_dof))
        {
            return true;
        }
        else
            return false;
    }
}
