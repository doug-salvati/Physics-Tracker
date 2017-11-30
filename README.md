# Physics Tracker
This is my [Honors](https://www.uml.edu/Honors/) Project for UMass Lowell fall 2017 semester.

Below is the proposal for this project.  Updates will be added during development, and this document will be reworked when it is finished.

## Updates

As the project is completed, this document will be updated to explain the use of this application.

**October 16**: See the [results](https://isenseproject.org/visualizations/1588) of the current program with its output data manually published to iSENSE!  The results were generated by running

```$ python tracker.py sample_videos/projectile.mov 5 75```

on a Mac machine, and clicking on the ball in the first frame.  The results are published to a video called output.mov and the data is sent to data.json.  Download the [script](https://raw.githubusercontent.com/doug-salvati/Physics-Tracker/master/tracker.py) to run on your own video.  It doesn't matter what color your subject is.  Usage:

```tracker.py [path to video] [sampling radius (px)] [tolerance (%)]```

where `sampling radius` is how big of an area to search when detecting the object's hue and `tolerance` indicates which percentage of light and dark variations of the hue are accepted.

**November 7**: The application has been successfully ported to the web with more functionality than ever.  It offers the ability to click and then measure the object to get a units calculation right in the browser, then it performs the upload and shows the values, as well as calculated velocity and acceleration in a table.  More features are planned for later in the lifecycle of this project.

You can even upload to an [iSENSE](https://isenseproject.org/) project!  Checkout the results from various people using this process [here](https://isenseproject.org/projects/3304).  The site is available at [bit.ly/physics-track](bit.ly/physics-track).

## Installation
If installing this app on your own server, please install the following dependencies. I have tested on Ubuntu 16.04 machines.
```
sudo apt update
sudo apt install rails
sudo apt install python
sudo apt install libopencv-dev python-opencv
Sudo apt install ffmpeg
sudo apt install x264
bundle install
rails server
```
# The Original Proposal

## Introduction

This project will produce a piece of software used to analyze two-dimensional motion of objects.  Friendly to students young and old, the software will consist of an interface allowing the user to upload or record a video and then identify an object in the video.  From there, computer vision will be used to track the object’s motion throughout the video.  The user will then be able to view the position, velocity, and acceleration of the object with respect to time, automatically calculated for them and placed in a table.  They will also be able to watch the video again, frame-by-frame, showing the data values at any particular time.  As a final step, the data can be uploaded to iSENSE, a web page used for storing and visualizing data.  This will enable students to effortlessly graph the data after they collect it.

This software will run on the web, with a mobile app developed subsequently.

As a second part to the project, the resulting application will be demonstrated to teachers and be tested with middle school students from Methuen, MA in collaboration with Fred Martin, and possibly more students of various ages in collaboration with the Physics Department.  The teachers will provide feedback about how the application was used in their classrooms over a period of two weeks.  So, in addition to the success of the application on its own, its use as a teaching tool will also be evaluated.

## Project Rationale/Justification

While software of this nature certainly exists, the purpose of this particular project is to produce software which is free, accessible, and child-friendly.  However, in many ways it will fulfill the needs of video experiments held in some first-year physics courses at UMass Lowell, so its use isn’t restricted to young children by any means.  Furthermore, the ability to record your own video rather than using one provided by an instructor will certainly make the learning experience more immersive.

Computer vision has limitations which means subjects of the videos will require clearly-defined edges or colors that contrast to be detected.  The goal of this project is not to develop better computer vision algorithms than those available today, but rather to focus on experience of using computer vision for educational purposes.  Therefore, the users will simply be instructed to use bright objects or bright lighting when they record their video.

## Materials

The computer vision will be achieved using the OpenCV library with the Python programming language.  An API to this code will be set up on a web server which will most likely be hosted on an Amazon Web Services virtual machine.  A web interface will be designed, and later an Android app which communicates with the server.  Finally, the iSENSE API will be used to send the data to iSENSE.

## Products

As mentioned, the software will run on a web server, and the final products will be both a web page and a mobile application which interact with the web server to perform the video analysis.  There will also be a write-up discussing two main topics.  First, the degree of success of the application itself, including how limited by lighting and colors the video analysis is, as well as how much the outputted values agree with what would be predicted by kinematics.  The discussion will also include reflections on showing the application to teachers and students.

## The Presentation

The presentation of this project will entail a live demo on a computer followed by a discussion of the results found from sharing the software with teachers and students.
