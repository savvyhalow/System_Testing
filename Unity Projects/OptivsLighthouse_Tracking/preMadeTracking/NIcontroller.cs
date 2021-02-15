using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.VR;
using System.IO;
using System.Linq;


public class NIcontroller : MonoBehaviour
{
    //Importing libraries
    [DllImport("VC_VoltUpdate")]

    //Establishing components
    private static extern int OutputVoltage(float voltage);
    float volt;
    string time;
    public GameObject opti;
    public StreamWriter data;
    int counter;
    string[] head_velocities_string;
    float[] head_velocities;
    int mode; //variable to change in start() for test cases
    bool done;
    float freq;
    int flag;
    int counter2;
    bool complete;


    void Start()
    {
        volt = 0;
        var fileName = "Rotating_Chair_Data " + DateTime.Now.ToString("MM-dd-yyyy hh.mm.ss") + ".txt";
        data = File.CreateText(fileName);
        data.WriteLine("Voltage, Timestamp, X position, Y position, Z position, X rotation, Y rotation, Z rotation");
        counter = 0;
        done = false;
        freq = -2 * (float)Math.PI;
        mode = 1; //1 = typical head movement, 2 = position step, 3 = velocity step, 4 = sins
        flag = 0;
        counter2 = 0;
        complete = false;

        using (TextReader reader = File.OpenText("sample_test.txt"))
        {
            string text;
            while ((text = reader.ReadToEnd()) != null)
            {
                //split string by space and save in array
                head_velocities_string = text.Split();
                head_velocities = new float[head_velocities_string.Length];

                for (int i = 0; i < head_velocities_string.Length; i++)
                {
                    head_velocities[i] = float.Parse(head_velocities_string[i], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture);
                }
            }

        }
    }

    void Update()
    {
        if (mode == 1)
        { //typical head movement (four head turns, velocities from D:\Trials\VSS_2019_Data\10_Data\Scene-Fixed\Active 2\headvel, trials (rows) 61-64)
            if (counter2 <= 100)
            {
                volt = 0;
                counter2++; //zero padding
            }
            else
            {
                if (!done)
                {
                    volt = head_velocities[counter] / 7.06f;
                    if (counter == head_velocities.Length-1)
                    {
                        done = true;
                    }
                    counter++;
                }
                else
                {
                    volt = 0;
                    counter = 0;
                    counter2++;
                    if (counter2 == 200)
                    { //zero padding
                        mode = 2;
                        counter2 = 0;
                    }
                }
            }
        }
        else if (mode == 2)
        { //position steps (two to the right, two to the left, each with a 20 frame duration and 80 frame duration of stop in between. note: max voltage for chair is +-10V)
            if (counter2 <= 100)
            {
                volt = 0;
                counter2++;
            }
            else
            {
                counter++;
                if (counter < 20)
                {
                    volt = 10;
                }
                else if (counter >= 20 && counter < 100)
                {
                    volt = 0;
                }
                else if (counter >= 100 && counter < 120)
                {
                    volt = 10;
                }
                else if (counter >= 120 && counter < 200)
                {
                    volt = 0;
                }
                else if (counter >= 200 && counter < 220)
                {
                    volt = -10;
                }
                else if (counter >= 220 && counter < 300)
                {
                    volt = 0;
                }
                else if (counter >= 300 && counter < 320)
                {
                    volt = -10;
                }
                else
                {
                    volt = 0;
                    counter2++;
                    if (counter2 == 200)
                    {
                        mode = 3;
                        counter = 0;
                        counter2 = 0;
                    }
                }
            }
        }
        else if (mode == 3)
        {//velocity steps (starts at rest for 50 frames, V=+5 for 100 frames, +1 for 100 frames, -5 for 100 frames, and -1 for 100 frames)
            if (counter2 <= 100)
            {
                volt = 0;
                counter2++;
            }
            else
            {
                counter++;
                if (counter < 100)
                {
                    volt = 5;
                }
                else if (counter >= 100 && counter < 200)
                {
                    volt = 1;
                }
                else if (counter >= 200 && counter < 300)
                {
                    volt = -5;
                }
                else if (counter >= 300 && counter < 400)
                {
                    volt = -1;
                }
                else
                {
                    volt = 0;
                    counter2++;
                    if (counter2 == 200)
                    {
                        mode = 4;
                        counter2 = 0;
                    }

                }
            }
        }

        else if (mode == 4)
        {//sins (sin(x), sin(2x), sin(0.5x), and sin(5x) from x = -2pi to +2pi)
            if (counter2 <= 100)
            {
                volt = 0;
                counter2++;
            }
            else
            {
                if (flag == 0)
                {
                    volt = (float)Math.Sin(freq);
                }
                else if (flag == 1)
                {
                    volt = (float)Math.Sin(2 * freq);
                }
                else if (flag == 2)
                {
                    volt = (float)Math.Sin(0.5 * freq);
                }
                else if (flag == 3)
                {
                    volt = (float)Math.Sin(5 * freq);
                }
                else
                {
                    volt = 0;
                }

                freq = freq + 0.01f;
                if (freq >= 2 * (float)Math.PI)
                {
                    volt = 0;
                    counter2++;
                    if (counter2 == 200)
                    {
                        freq = -2 * (float)Math.PI;
                        counter2 = 0;
                        flag++;
                        if (flag == 4)
                        {
                            volt = 0;
                            complete = true;
                        }
                    }
                }
            }
        }

        if (!complete)
        {//moves chair, outputs data to text file
            OutputVoltage(volt);
            time = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss.fff");
            data.WriteLine(volt + ", " + time + ", " + opti.transform.localPosition.x + ", " + opti.transform.localPosition.y + ", " + opti.transform.localPosition.z + ", " + opti.transform.localRotation.eulerAngles.x + ", " + opti.transform.localRotation.eulerAngles.y + ", " + opti.transform.localRotation.eulerAngles.z);
        }
        else
        {
            OutputVoltage(volt);
        }
    }

    private void OnDestroy()
    {
        // Stop chair on escape
        OutputVoltage(0);
        data.Close();
    }
}