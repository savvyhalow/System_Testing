-------PID CONTROLLER/ROTATING CHAIR---------

1. Record initial data set:

-run PIDcontroller.cs through Unity (2018.2.8f1), making sure that condition 1 is running (outputVoltage(ideal[index]) is
(condition 2 (outputVoltage(controlInput[index]) runs later)

-setup notes: ensure steamVR is running, IP addresses are correct on Unity, correct Motive cameras are on,
power to chair is on, Optitrack is calibrated

-to run PIDcontroller.cs, from Unity go to File-->Build and Run (clicking 'play' causes Unity to crash).

-can record data with a pre-made ideal velocity input (defined in start()) using
a stable rigid body attached to the chair, or can record data with a setpoint input (defined in start())
by moving the rigid body (e.g. attached to person's head sitting on chair)

(alternatively can run NIcontroller.cs to record the chair's position data, since PIDcontroller.cs records velocity data.
 To do this, add the NIcontroller.cs script to the 'Assets' folder, and make sure it is the script attached to the
'RotatingChair' object. Note that the velocity data from PIDcontroller.cs yields a better transfer function,
so that is the script to use for PID control.)

* to run pre-made velocity profile using PID make sure movement input type in insepctor is set to
"predetermined". Manual/live feed will NOT move the chair

2. Find transfer function:
-run tf_PID.m, changing the name of the text file to be imported from the newly recorded data

(to look at data from NIcontroller.cs, run plot_data_NIcontroller. This isn't used to find transfer function.)


3. Find/tune PID values:
-run PID_test.m to simulate a PID controlled output, changing kp, ki, and kd values from tf_PID.m output,
and changing y(n) equation coefficient values from tf_PID.m output


4. Implement PID controller:

-return to PIDcontroller.cs, commenting line 208 and uncommenting line 207, so that now the PID
controlled input is sent to the chair, rather than the ideal input/setpoint.
-run through Unity, making sure to go to File-->Build and Run

-run plot_data_new.m to look at newly recorded data, making sure to change the name of the text file
to be imported.