using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Text;
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.InteropServices;


public class xbox_controller_move_platform : MonoBehaviour {
    //Import function from the DLL
    [DllImport("C++WriteDLL")]
    public static extern void WriteToMotionFile(float surge, float lateral, float heave, float roll, float pitch, float yaw, bool absolute_mode, int traj_rate);

    [DllImport("C++WriteDLL")]
    public static extern void InitializeMotionFileCounter();

    //dof data
    dof_data the_data;
    
    /*
    //max that each dof should move by (taken from original xbox controller values in moog code)
    float max_dof_movement_surge = 0.00008f;
    float max_dof_movement_lateral = 0.00008f;
    float max_dof_movement_heave = 0.00004f;
    float max_dof_movement_roll = 0.004f;
    float max_dof_movement_pitch = 0.004f;
    float max_dof_movement_yaw = 0.004f;
    */
    
    //max that each dof should move by. grabbed from the previous motion platform C code for using XBOX controller input diretly through the console
    float max_dof_movement_surge = 0.00008f;
    float max_dof_movement_lateral = 0.00008f;
    float max_dof_movement_heave = 0.00004f;
    float max_dof_movement_roll = 0.004f;
    float max_dof_movement_pitch = 0.004f;
    float max_dof_movement_yaw = 0.004f;
    
    //If true, dofs are limited to the max predetermined values. If false, unexpected results/faults may occur since no limits are placed.
    bool limit_dof_commands = false;

    //class to save dof values into
    public class dof_data
    {
        public float surge, lateral, heave, roll, pitch, yaw;
    }

	// Use this for initialization
	void Start () {
        the_data = new dof_data();

        //initialize command_id counter to 0. counter is used to indicate the nth command that Unity has written to the file. 
        InitializeMotionFileCounter();
    }

    // Update is called once per frame
    void Update()
    {

        //initialize dof values at 0
        float surge, lateral, heave, roll, pitch, yaw;
        surge = lateral = heave = roll = pitch = yaw = 0.000f;

        //range -1...1 for joystick input of left and right joysticks
        var lx1 = Input.GetAxis("L_XAxis_1");
        var ly1 = Input.GetAxis("L_YAxis_1");
        var rx1 = Input.GetAxis("R_XAxis_1");
        var ry1 = Input.GetAxis("R_YAxis_1");
        //true while button is held down
        var lb1 = Input.GetButton("LB_1");

        /*
        //make inputs discrete
        int lx_processed = ProcessStickInput(lx1);
        int ly_processed = ProcessStickInput(ly1);
        int rx_processed = ProcessStickInput(rx1);
        int ry_processed = ProcessStickInput(ry1);
        */

        float lx_processed = lx1;
        float ly_processed = ly1;
        float rx_processed = rx1;
        float ry_processed = ry1;

        //process controller inputs
        if (lb1) //holding left bumper lets right joystick control heave(y) and yaw(x)
        {
            heave = ry_processed;
            yaw = rx_processed;
        }
        else // not holding left bumper lets right joystick control surge(y) and lateral(x)
        {
            surge = ry_processed;
            lateral = rx_processed;
        }
        //left joystick controls the roll(x) and pitch (y)
        roll = lx_processed;
        pitch = ly_processed;

        //multiply the amount of joystick input by the max movement for each dof
        the_data.surge = surge * max_dof_movement_surge;
        the_data.lateral = -lateral * max_dof_movement_lateral;
        the_data.heave = heave * max_dof_movement_heave;
        the_data.roll = -roll * max_dof_movement_roll;
        the_data.pitch = -pitch * max_dof_movement_pitch;
        the_data.yaw = yaw * max_dof_movement_yaw;

        //deprecated. can be turned on to limit dof values sent out from being too large.
        if (limit_dof_commands)
        {
            //check that the values for the dofs do not exceed the limits, set to the max allowable value if limits are exceeded
            if (Mathf.Abs(the_data.surge) > max_dof_movement_surge)
            {
                Debug.Log("Warning: surge value of " + surge + " exceeds maximum allowed value of " + max_dof_movement_surge);
                the_data.surge = max_dof_movement_surge;
            }
            if (Mathf.Abs(the_data.lateral) > max_dof_movement_lateral)
            {
                Debug.Log("Warning: lateral valued of " + lateral + " exceeds maximum allowed value of " + max_dof_movement_lateral);
                the_data.lateral = max_dof_movement_lateral;
            }
            if (Mathf.Abs(the_data.heave) > max_dof_movement_heave)
            {
                Debug.Log("Warning: heave value of " + heave + " exceeds maximum allowed value of " + max_dof_movement_heave);
                the_data.heave = max_dof_movement_heave;
            }
            if (Mathf.Abs(the_data.roll) > max_dof_movement_roll)
            {
                Debug.Log("Warning: roll value of " + roll + " exceeds maximum allowed value of " + max_dof_movement_roll);
                the_data.roll = max_dof_movement_roll;
            }
            if (Mathf.Abs(the_data.pitch) > max_dof_movement_pitch)
            {
                Debug.Log("Warning: pitch value of " + pitch + " exceeds maximum allowed value of " + max_dof_movement_pitch);
                the_data.pitch = max_dof_movement_pitch;
            }
            if (Mathf.Abs(the_data.yaw) > max_dof_movement_yaw)
            {
                Debug.Log("Warning: yaw value of " + yaw + " exceeds maximum allowed value of " + max_dof_movement_yaw);
                the_data.yaw = max_dof_movement_yaw;
            }
        }

        //Debug.Log("surge=" + the_data.surge + ", lateral=" + the_data.lateral + ", heave=" + the_data.heave + ", roll=" + the_data.roll + ", pitch=" + the_data.pitch + ", yaw=" + the_data.yaw);

        //call the function from the DLL (dynamic link library) to write the six dof values to the file named "move_to.txt"
        WriteToMotionFile(the_data.surge, the_data.lateral, the_data.heave, the_data.roll, the_data.pitch, the_data.yaw, false, 90);
    }

    /*
    //Make the float input discrete by return 1 if positive, -1 if negative, and 0 if 0
    int ProcessStickInput(float input)
    {
        //floating point comparison are fine because the axis give 0 in the deadzone and +-(0.3 to 1) otherwise.
        //we never deal with values close to zero
        if (input == 0.0f)
            return 0;
        else if (input > 0)
            return 1;
        else
            return -1;
    }
    */

}
