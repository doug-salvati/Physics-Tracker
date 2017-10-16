# Douglas Salvati
# Honors Project
# Fall 2017

import cv2 as cv
import numpy as np
import sys
import json

# Get arguments
if len(sys.argv) != 4:
    print("Usage: tracker.py [path to video] [sampling radius (px)] [tolerance (%)]")
    quit()
video_path = sys.argv[1]
sampling_radius = np.abs(int(sys.argv[2])) # px
tolerance = float(sys.argv[3]) / 100 # percent as fraction
if tolerance < 0 or tolerance > 1:
    print("Tolerance can't be " + str(tolerance * 100) + "%.")
    print("Tolerance must be between 0 and 100%.")
    quit()

# Variables & functions
selected_x = -1
selected_y = -1
def select_point(event,x,y,flags,param):
    if event == cv.EVENT_LBUTTONUP:
        global selected_x
        global selected_y
        selected_x = x
        selected_y = y

# Read the video
cap = cv.VideoCapture(video_path)
if not cap.isOpened():
    print("Problem with input file, please check path.")
    quit()
fourcc = cv.VideoWriter_fourcc(*'avc1')
fps = 20
size = (int(cap.get(cv.CAP_PROP_FRAME_WIDTH)),
        int(cap.get(cv.CAP_PROP_FRAME_HEIGHT)))
fps = cap.get(cv.CAP_PROP_FPS)
frames = int(cap.get(cv.CAP_PROP_FRAME_COUNT))
out = cv.VideoWriter('output.mov', fourcc, fps, size)

# Display first frame, wait for click
ret, img = cap.read()
if ret == True:
    cv.namedWindow('ObjectSelection')
    cv.imshow('ObjectSelection', img)
    cv.setMouseCallback('ObjectSelection', select_point)
while(selected_x < 0 and selected_y < 0):
    k = cv.waitKey(10)
    if k == 27:
        break
cv.destroyWindow('ObjectSelection')
cv.waitKey(1)
cap.release()

# Get color bounds
# Average colors
mask = np.zeros(img.shape[:2], np.uint8)
cv.circle(mask, (selected_x, selected_y), sampling_radius, (255,255,255), -1)
average_color = cv.mean(img, mask)
# Convert to HSV and get hue, we need it later
hue = cv.cvtColor(np.array([[average_color]], dtype=np.uint8), cv.COLOR_BGR2HSV)[0][0][0]
# All we care about is the hue, sat and val will be fixed to wide range
sv_low = int(255 - (tolerance * 255))
dark = np.array([hue - 10, sv_low, sv_low])
light = np.array([hue + 10, 255, 255])

# Loop over all frames
cap = cv.VideoCapture(video_path)
i = 0
data = []

for i in range(1, frames + 1):
    # Read a frame
    ret, img = cap.read()
    if ret == True:
        # Print progress
        progress = int(float(i) / float(frames) * 100)
        sys.stdout.write("\rProcessing frame " + str(i) + "/" + str(frames) + " (" + str(progress) +  "%)")
        sys.stdout.flush()

        # Convert to HSV color
        hsv = cv.cvtColor(img, cv.COLOR_BGR2HSV)
            
        # Threshold
        mask = cv.inRange(hsv, dark, light)

        # Border
        _, contours, _ = cv.findContours(mask, cv.RETR_TREE, cv.CHAIN_APPROX_SIMPLE)
        areas = map(cv.contourArea, contours)
        if len(areas) == 0:
            print("\nLost track of object... try raising tolerance.")
            quit()
        contour = contours[areas.index(max(areas))]
        cv.drawContours(img, contour, -1, (0, 255, 0), 10)

        # Get bounding box of contour
        x, y, w, h = cv.boundingRect(contour)
        bounded_mask = mask[y:y+h, x:x+h]
        
        # Calculate centroid
        moments = cv.moments(bounded_mask)
        centroid_x = int(moments['m10']/moments['m00']) + x
        centroid_y = int(moments['m01']/moments['m00']) + y
        cv.circle(img,(centroid_x, centroid_y),10,(0,0,255),2)

        # Save frame
        out.write(img)
        
        # Print coordinates
        t = i / fps
        data_pt = {"t":t,"x":centroid_x,"y":centroid_y}
        data.append(data_pt)

    else:
        print("\nError occurred processing frame " + str(i) + ". Halting...")
        break

# Clean up & export
print("\nExporting...")
cap.release()
out.release()
with open('data.json', 'w') as outfile:
    json.dump(data, outfile)
