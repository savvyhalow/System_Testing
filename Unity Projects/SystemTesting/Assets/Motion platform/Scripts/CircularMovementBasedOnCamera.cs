using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//move in around a central pivot point in a circular path based on head yaw rotation. 
//rotating the head to the left results in a counter-clockwise movement while rotating the head to the right results in clockwise movement
//Note that this script must be attached to the GameObject with the main camera on it which is also a direct child of the GameObject with the Optitrack plugin scripts.
public class CircularMovementBasedOnCamera : MonoBehaviour {
    //distance (meters) that the central pivot point is from the player's camera
    public float distance_from_center = 1;
	
    // Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		//convert degrees to radians
		float angle_rad = Mathf.Deg2Rad * Camera.main.transform.localEulerAngles.y;
        //calculate the z position offset from the central pivot point
		float offset_z = -distance_from_center * Mathf.Cos (angle_rad);
        //calculate the x position offset from the central pivot point
        float offset_x = -distance_from_center * Mathf.Sin (angle_rad);

        //set the position of the camera to the calculated z and x offsets
		transform.localPosition = new Vector3 (offset_x, 0, offset_z);
	}
}
