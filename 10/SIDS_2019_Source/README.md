# Project Source Code

This directory contains the source code files for the project. Built in C++ and it consists of the following components:  
* `images` directory : This directory contains the image files required by the application.
* `SIDS_2019_Source.pro` : This is a Qt project file. Project files contain all the information required by qmake to build an application, library, or plugin.
* `SIDS_2019_Source.pro.user` : Qt Creator stores user-specific project settings in a .pro.user file. This file is different for different machines.
* `clickablelabel.h` : This is a header file that declares the variables and methods for the clickable part of the labeling module.
* `login.cpp` : This has the main source code of the application which is run everytime the application is executed. It contains all the functions and is the application.
* `login.h` : The header file declaring the variables and methods used in the source login.cpp file.
* `login.ui` : Qt Designer stores forms in .ui files. These files use an XML format to represent form elements and their characteristics.
* `main.cpp` : It's purpose is to start off the application.
* `resources.qrc` : The resources associated with an application are specified in a .qrc file, an XML-based file format that lists files on the disk and optionally assigns them a resource name that the application must use to access the resource.  

The Modulewise line numbers in the source code are as follows :
1. Login Module : Line 213-325
2. Homepage Module : Line 327-444
3. Dataset Split Module : Line 446-767
4. Testing/Detection Module : Line 769-1798
5. Training Module : Line 1800-2756
6. Labeling Module : Line 2759-3974
7. Profile Module : Line 3981-4233  


The Source code contains details about all the functions, but a brief list of major functions implemented in the login.cpp file are as follows:  

1. bool is_dir(const char* path) : Check if input is a directory.
2. int round_up(int numToRound, int multiple) : For rounding up values.
3. void Login::on_pushButtonLogin_clicked() : Check login credentials of the user
4. void Login::on_pushButtonRegister_clicked() : Register new users into the database
5. int issubstring(string s1, string s2) : Check if s1 is substring of s2
6. void Login::on_horizontalSliderRatio_valueChanged(int value) : Update value of training and validation split.
7. bool isImageFiles(string fname) : Check if input file is an image.
8. void Login::on_testing_select_images_clicked() : Select image directory to be split
9. void Login::on_pushButtonSave_clicked() : Split the dataset into training and validation
10. void Login::on_Detect_button_clicked() : For image detection
11. void Login::on_pushButtonTestingStartVideo_clicked() : For video detection
12. void postprocess(Mat& frame, const vector<Mat>& outs) : Helper for video detection
13. void drawPred(int classId, float conf, int left, int top, int right, int bottom, Mat& frame) : Draw predicted boxes
14. void Login::on_pushButtonWebCam_clicked() : Detection on webcam
15. void Login::generateImagesFile(string folder, string fileName) : Generate images list file for YOLO training.
16. void Login::generateTrainingDataFile() : Generate training.data file for YOLO training
17. void Login::generateCfgFile() : For generating CFG file required for YOLO training.
18. void Login::on_pushButtonStartTraining_clicked() : Start training
19. void Login::on_pushButton_6_clicked() : For the user to see generated files
20. void Login::on_pushButtonStopTraining_clicked() : Stop training
21. void Login::refreshClasses() : Refresh classes on the image
22. void getActualCoordinates(int actualWidth, int actualHeight, int w, int h, int xBegin, int xEnd, int yBegin, int yEnd, int cord[]) : Get co-ordinates not in YOLO format
23. void Login::deleteBoxFn() : Deleting a labelled box
24. void Login::editBoxClassFn() : Editing label name of a box
25. QString Login::saveTxtFileForImage(int imageNo) : Save .txt file for annotated image
26. void Login::drawRectAroundPixmap(int xBegin, int yBegin, int xEnd, int yEnd, QString className, bool reset, bool resetFromImage) : Draw the bounding box
27. void Login::on_pushButtonNextImage_clicked() : Go to next image
28. void Login::on_pushButtonPreviousImage_clicked() : Go to previous image
29. void Login::on_pushButtonSetImage_clicked() : Helper function to set image on pixmap
30. void Login::mouse_pressed(int btn) : Pressing Mouse on labeling image
31. void Login::mouse_released() : Releasing mouse on labeling image
32. void Login::on_pushButtonEditClassesDotTxt_clicked() : On editing class name
33. void Login::on_pushButton_9_clicked() : Editing class name
34. void Login::on_pushButton_8_clicked() : Add a new class
35. void Login::on_Viewtxtlabeling_clicked() : View .txt file generated in YOLO format
36. void Login::on_pushButtonZoomIn_clicked() : Zoom in on labeling image.
37. void Login::on_pushButtonZoomOut_clicked() : Zoom out of labeling image
38. void Login::on_pushButtonResetZoom_clicked() : Reset Zoom
39. void Login::on_pushButton_10_clicked() : View the progress on labeling dataset
40. void Login::updatevalues() : Update directory paths used by user in last session


