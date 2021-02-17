# Python code for Latency Detection
  
  
import numpy as np 
import cv2 
import argparse
import imageio
import os
import pandas as pd
import sys
import matplotlib.pyplot as plt


print('Debug: Starting script')



# import latency video
def read_input_arguments(args):

    # video is recorded at 240 fps
    fps = 240
    # read the input arguments and store them to start and end time
    #start_time = tuple(args.start_time)
    #end_time = tuple(args.end_time)
    #print('Start Time:', start_time)
    #print('End Time:', end_time)

    #start_index = (start_time[0] * 60 + start_time[1]) * fps
    #end_index = (end_time[0] * 60 + end_time[1]) * fps
    #print('Start Frame idx = %d' % start_index)
    #print('End Frame idx= %d' % end_index)

    #data_path = args.data_path
    #print('reading video: ', data_path + 'test.mp4')

    print('Start read_input_arguments')

    video = cv2.VideoCapture(filename)

    duration = video.get(cv2.CAP_PROP_POS_MSEC)
    frame_count = video.get(cv2.CAP_PROP_FRAME_COUNT)

    start_time = 0
    end_time = 0 + duration

    #start_index = (start_time[0] * 60 + start_time[1]) * fps
    start_index = 0
    #end_index = (end_time[0] * 60 + end_time[1]) * fps
    end_index = duration
    print('Start Frame idx = %d' % start_index)
    print('End Frame idx= %d' % end_index)

    data_path = args.data_path
    print('reading video: ', data_path + 'test.mp4')

    #return start_index, end_index, data_path
    return duration, frame_count, start_index, end_index, data_path

print('Start parse')
# Set the input arguments to the function and their types
parser = argparse.ArgumentParser(description='Detects when the lens changes color')
parser.add_argument('start_time', type=int, nargs=2,
                    help='start time (min, sec) in the video', default=(0, 20))
parser.add_argument('end_time', type=int, nargs=2,
                    help='end time (min, sec) in the video', default=(0, 50))
parser.add_argument('-data_path', type=str, nargs=1,
                    help='path to the video', default='E:/GitHub/conflict-detection/System Testing/LatencyRecordings')

# Read the input arguments passed to the function and print them out
args = parser.parse_args()
print('Stop point 2')
start_index, end_index, data_path = read_input_arguments(args)

# Prepare the empty lists for storing marker positions and the timestamps
lens_x = []
lens_y = []
lens_size = []
lens_index = []

# Instantiate the video capture from opencv to read the eye video, total number of frames, frame width and height
cap = cv2.VideoCapture(data_path + 'test.mp4')

numberOfFrames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
print( 'Total Number of Frames: ', numberOfFrames )
frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
print('Frame Size :[', frame_height,frame_width, ']')


# Instantiate the video capture from imageio in order to read the eye video
vid = imageio.get_reader(data_path + 'test.mp4',  'ffmpeg')

scale = 0.5
size = (int(frame_width*scale), int(frame_height*scale))


myString = '-'


  # Loop through video looking for color change
for count in range(start_index, end_index):
    
    print("Progress: {0:.1f}% {s}".format(count*100/numberOfFrames, s = myString), end="\r", flush=True)

    # Read the next frame from the video.
    raw_image = vid.get_data(count)
    raw_image = cv2.resize(raw_image, None, fx = scale, fy = scale)
    # Switch the color channels since opencv reads the frames under BGR and the imageio uses RGB format
    raw_image[:, :, [0, 2]] = raw_image[:, :, [2, 0]]
    
    #_, imageFrame = webcam.read() 
  
    # Convert the imageFrame in BGR(RGB color space) to  
    # HSV(hue-saturation-value) color space 
    hsvFrame = cv2.cvtColor(imageFrame, cv2.COLOR_BGR2HSV) 
  
    # Set range for red color and define mask 
    red_lower = np.array([136, 87, 111], np.uint8) 
    red_upper = np.array([180, 255, 255], np.uint8) 
    red_mask = cv2.inRange(hsvFrame, red_lower, red_upper) 
  
    # Set range for green color and define mask 
    green_lower = np.array([25, 52, 72], np.uint8) 
    green_upper = np.array([102, 255, 255], np.uint8) 
    green_mask = cv2.inRange(hsvFrame, green_lower, green_upper) 
  
    # Set range for blue color and define mask 
    blue_lower = np.array([94, 80, 2], np.uint8) 
    blue_upper = np.array([120, 255, 255], np.uint8) 
    blue_mask = cv2.inRange(hsvFrame, blue_lower, blue_upper) 
      
    # Morphological Transform, Dilation for each color 
    # and bitwise_and operator between imageFrame and mask determines 
    # to detect only that particular color 
    kernal = np.ones((5, 5), "uint8") 
      
    # For red color 
    red_mask = cv2.dilate(red_mask, kernal) 
    res_red = cv2.bitwise_and(imageFrame, imageFrame,  
                              mask = red_mask) 
      
    # For green color 
    green_mask = cv2.dilate(green_mask, kernal) 
    res_green = cv2.bitwise_and(imageFrame, imageFrame, 
                                mask = green_mask) 
      
    # For blue color 
    blue_mask = cv2.dilate(blue_mask, kernal) 
    res_blue = cv2.bitwise_and(imageFrame, imageFrame, 
                               mask = blue_mask) 

    # Perform image thresholding using a adaptive threshold window
    window_size = 11
    binary_image = cv2.adaptiveThreshold(gray,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,cv2.THRESH_BINARY,window_size,2)
    # Perform image erosion in order to remove the possible bright points inside the marker
    window_size = 3
    kernel = np.ones((window_size,window_size), int)
    binary_image = cv2.erode(binary_image, kernel, iterations = 1) # iterations = 2 for marker
    grey_3_channel = cv2.cvtColor(binary_image, cv2.COLOR_GRAY2BGR)

    # Detect blobs using opencv blob detector that we setup earlier in the code
    keypoints = detector.detect(binary_image) 


    # Check if there is any blobs detected or not, if yes then draw it using a red color
    number_of_blobs = len(keypoints) 



    if number_of_blobs > 0:

        # Draw blobs on our image as red circles 
        blank = np.zeros((1, 1))
        blobs = cv2.drawKeypoints(raw_image, keypoints, blank, (0, 0, 255), cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
        
        # Add text to image (Seems unncessary)
        #text = "# of Blobs: " + str(len(keypoints)) 
        #cv2.putText(blobs, text, (20, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 100, 255), 2) 
        for keypoint in keypoints:
            lens_x.append(keypoint.pt[0]*(1/scale))
            lens_y.append(keypoint.pt[1]*(1/scale))
            lens_size.append(keypoint.size)
            lens_index.append(count)
            #print("p = {:.1f} {:.1f} {:.1f} {}".format(keypoint.pt[0], keypoint.pt[1], keypoint.size, count))

        # Show blobs using opencv imshow method
        cv2.imshow('Frame',np.concatenate((blobs, grey_3_channel), axis=1))
        myString = '1'
        out.write(np.array(blobs))
        if cv2.waitKey(2) & 0xFF == ord('q'):
            break
        
    else:

        # If there is no blobs detected, just show the binary image and write it to the output video
        cv2.imshow('Frame',grey_3_channel)
        myString = '0'
        out.write(np.array(grey_3_channel))
        if cv2.waitKey(2) & 0xFF == ord('q'):
            break


    print('\nDone!')
# Close all the opencv image frame windows opened
cv2.destroyAllWindows()

# Release the video writer handler so that the output video is saved to disk
out.release()

my_dict={'lens_x':np.array(lens_x), 'lens_y':np.array(lens_y),
        'lens_size':np.array(lens_size), 'lens_index':np.array(lens_index)}
data_frame = pd.DataFrame(my_dict)
data_frame.to_csv('detected_color_changes.csv')
#print('Saved marker data into csv file!')
print('\n\nThe end!')