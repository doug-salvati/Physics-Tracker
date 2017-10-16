# Douglas Salvati
# Honors Project
# Fall 2017

import cv2 as cv
import numpy as np
import sys

# Get arguments
if len(sys.argv) != 4:
    print("Usage: tracker.py [path to video] [sampling radius (px)] [tolerance (%)]")
    quit()
video_path = sys.argv[1]
sampling_radius = np.abs(int(sys.argv[2])) # px
tolerance = float(sys.argv[3]) / 100 # percent as fraction
if tolerance <= 0 or tolerance >= 1:
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
mask = np.zeros(img.shape[:2], np.uint8)
cv.circle(mask, (selected_x, selected_y), sampling_radius, (255,255,255), -1)
average_color = cv.mean(img, mask)
dark = np.array(np.append([channel * (1 - tolerance) for channel in average_color[:3]], 0))
light = np.array(np.append([(255 - channel) * (1 - tolerance) + channel for channel in average_color[:3]], 0))
dark = np.array([[dark]], dtype=np.uint8)
light = np.array([[light]], dtype=np.uint8)
dark = cv.cvtColor(dark, cv.COLOR_BGR2HSV)
light = cv.cvtColor(light, cv.COLOR_BGR2HSV)
dark = dark[0][0]
dark[0] -= 10
dark[1] = dark[2] = 50
light = light[0][0]
light[0] += 10
light[1] = light[2] = 255
#dark = np.array([110,50,50])
#light = np.array([130,255,255])
print(dark)
print(light)

# Loop over all frames
cap = cv.VideoCapture(video_path)
i = 0
frames = int(cap.get(cv.CAP_PROP_FRAME_COUNT))

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
    else:
        print("\nError occurred processing frame " + str(i) + ". Halting...")
        break

# Clean up
print("\nExporting...")
cap.release()
out.release()
