Trouble shooting:

If VIVE HMD is not displaying without lighthouses:
- Check for a file in the SteamVR program folder titled ".VRSettings" Opening the file will show default settings for the VIVE headset that gets regularly updated when SteamVR is updated. Look for a variable titled, "forcefadeonbadTracking" and make sure it is set to false.

To prevent motion smoothing with VIVE headset:
Check for a file in the SteamVR program folder titled ".VRSettings" Opening the file will show default settings for the VIVE headset that gets regularly updated when SteamVR is updated. Look for a variable titled, "motionsmoothing" and make sure it is set to false.

Optitrack troubleshooting:

- Make sure the rigidbody ID on the Optitrack host PC matches the rigidbody ID in the Unity program. Be sure that all ID numbers match the corresponding object they are meant to track.

- Check that the appropriate IP addresses are set up to allow communication. The current set up (at time of writing, 2/5/2020) has the optitrack host PC set to 10.1.10.1
The IP addresses of all PC's using optitrack must have common local settings for ip addresses, such that each address is 10.1.10.x 

Notes for MatLab scripts:

(will update this section later)