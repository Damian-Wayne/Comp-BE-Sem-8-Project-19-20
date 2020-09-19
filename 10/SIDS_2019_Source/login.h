#ifndef LOGIN_H
#define LOGIN_H

#include <QMainWindow>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QDebug>
#include <QFileInfo>
#include <QDialog>
#include <QGraphicsScene>
#include <QGraphicsPixmapItem>
#include <QImage>
#include "opencv2/opencv.hpp"
#include <string>
#include <QProcess>
#include <vector>
#include <QButtonGroup>
using namespace std;

namespace Ui {
class Login;
}

class Login : public QMainWindow
{
    Q_OBJECT

public:
    explicit Login(QWidget *parent = 0);
    ~Login();

private slots:

    // Login
    void on_pushButtonLogin_clicked();

    void on_pushButtonRegister_clicked();

    void on_pushButton_2_clicked();

    void on_pushButton_clicked();

    // Main Menu
    void on_pushButton_helpmain_clicked();

    void on_pushButton_labelimages_clicked();

    void on_pushButtonSplitImages_clicked();

    void on_pushButton_trainingdarknet_clicked();

    void on_pushButton_testing_darknet_clicked();

    void on_pushButton_logout_clicked();

    // Testing, Training & Split
    void on_testing_select_images_clicked();

    void on_testing_help_3_clicked();

    void on_testing_back_clicked();

    void on_pushButtonSave_clicked();

    void on_horizontalSlider_valueChanged(int value);

    void on_horizontalSliderRatio_valueChanged(int value);

    void on_Weight_button_clicked();

    void on_image_button_clicked();

    void on_cfg_button_clicked();



    void on_pushButton_3_clicked();

    void on_Detect_button_clicked();



    void on_testing_help_2_clicked();

    void on_pushButtonTrainingDirectory_clicked();

    void on_pushButtonValidationDirectory_clicked();

    void on_pushButtonDarknetDirectory_clicked();

    void on_pushButtonWeightFile_clicked();

    void on_pushButtonCfgFile_clicked();

    void on_pushButtonGenerateAllTrainingFiles_clicked();

    void on_pushButtonStartTraining_clicked();

    void on_pushButton_4_clicked();

    void on_pushButton_5_clicked();

    void on_pushButton_6_clicked();

    void on_pushButtonStopTraining_clicked();

    void app_train_txt_event();

    void app_train_cfg_event();

    void app_train_names_event();

    void app_train_test_event();

    void app_train_train_event();

    void trainingProcessDataReceived();

    void trainingProcessErrorReceived();

    void on_pushButton_7_clicked();

    // Labeling

    void refreshClasses();

    void deleteBoxFn();

    void editBoxClassFn();

    void mouse_moved();

    void mouse_pressed(int btn);

    void mouse_released();

    void on_labelling_back_clicked();

    void on_pushButtonInstructions_clicked();

    void on_pushButton_9_clicked();

    void on_pushButtonSelectDirectory_clicked();

    void on_pushButtonNextImage_clicked();

    void on_pushButtonPreviousImage_clicked();

    void on_pushButtonSetImage_clicked();

    void on_pushButtonEditClassesDotTxt_clicked();

    void on_lineEditSearchClasses_textChanged(const QString &arg1);

    void on_pushButton_8_clicked();

    void on_Viewtxtlabeling_clicked();

    void on_pushButtonZoomIn_clicked();

    void on_pushButtonZoomOut_clicked();

    void on_pushButtonResetZoom_clicked();

    void on_pushButton_10_clicked();

    void on_pushButton_11_clicked();

    void on_txt_view_back_clicked();



    void on_pushButton_12_clicked();

    void on_pushButtonTestingStartVideo_clicked();

    void on_pushButtonTestingSelectVideo_clicked();

    void on_pushButton_13_clicked();

    void on_pushButton_14_clicked();

    void on_pushButton_16_clicked();

    void updatevalues();

    void on_pushButton_15_clicked();

    void on_pushButtonStopTraining_2_clicked();


    void on_pushButton_17_clicked();

    void on_pushButton_19_clicked();

    void on_pushButton_names_clicked();

    void on_pushButton_20_clicked();

    void on_pushButton_21_clicked();

    void on_pushButton_22_clicked();

    void on_pushButton_23_clicked();

    void on_pushButton_24_clicked();

    void on_pushButton_25_clicked();

    void on_pushButton_26_clicked();

    void on_pushButton_27_clicked();

    void on_pushButton_28_clicked();

    void on_pushButton_29_clicked();

    void on_pushButton_30_clicked();

    void on_pushButton_31_clicked();

    void on_pushButton_32_clicked();

    void on_pushButton_33_clicked();

    void on_pushButton_34_clicked();

    void on_pushButton_35_clicked();

    void on_pushButtonWebCam_clicked();


    void on_pushButton_36_clicked();

    void on_pushButton_38_clicked();

    void on_pushButton_37_clicked();

    void on_pushButtonWebCam_2_clicked();

    void on_pushButton_40_clicked();

    void searchCameras();

    void on_horizontalSlider_sliderMoved(int position);

    void on_Conf_Slider_sliderMoved(int position);

    void on_Conf_Slider_Webcam_sliderMoved(int position);

private:
    Ui::Login *ui;
    QSqlDatabase db;

    vector<string> files;
    vector<string> classNames;
    QGraphicsPixmapItem pixmap1;
    QGraphicsPixmapItem pixmap2;
    QGraphicsPixmapItem pixmap3;
    QGraphicsPixmapItem pixmap4;
      cv::VideoCapture video;
    QProcess *trainingProcess;
    QButtonGroup *selectClassButtonGroup, *selectCameraButtonGroup;
    int currentImagePosition = -1, classCount = -1;
    bool changed, deleteBox = false, editBoxClass = false;
    QPixmap latestPixmap;
    QString initialClassName;
    float zoomLevel = 1;
    void copyClassesFile();
    void generateImagesFile(string folder, string fileName);
    void generateTrainingDataFile();
    void generateCfgFile();
    QString saveTxtFileForImage(int imageNo);
    void drawRectAroundPixmap(int xBegin, int yBegin, int xEnd, int yEnd, QString className, bool reset, bool resetFromImage);
    bool trainingFilesGenerated = false;
    int cameraIndex = 0;
};

#endif // LOGIN_H
