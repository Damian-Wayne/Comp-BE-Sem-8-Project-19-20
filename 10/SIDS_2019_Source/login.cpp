#include "login.h"
#include "ui_login.h"

#include <QDebug>
#include <QGraphicsScene>
#include <QGraphicsPixmapItem>
#include <QImage>
#include <QProcess>
#include <QMessageBox>
#include <QPixmap>
#include <dirent.h>
#include <ctime>
#include <QDebug>
#include <QSettings>
#include <QFileDialog>
#include <cstdlib>
#include <QFile>
#include <iostream>
#include "opencv2/opencv.hpp"
#include <QDir>
#include <sys/stat.h>
#include <fstream>
#include<QClipboard>

#include <clickablelabel.h>
#include <QInputDialog>
#include <QPainter>
#include <QMouseEvent>
#include <string>
#include <cstdio>
#include <QRadioButton>
#include <QCheckBox>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QTextEdit>
#include <QSettings>
#include <QScrollArea>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <opencv2/ml.hpp>
#include "opencv2/objdetect/objdetect.hpp"
#include <sstream>
#include <iostream>
#include <fstream>
#include <opencv2/dnn.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include "opencv2/imgproc/imgproc_c.h"
#include<QSqlError>



using namespace std;
using namespace cv;
using namespace cv::ml;
using namespace dnn;



//Video Detection
int top1,baseLine1,left1,height1,width1,right1,bottom1;
Size labelSize1;
bool paused = true;
bool paused_webcam = false;
int current_frame_skip = 1;
int wait_time = 1;

// Initialize the parameters
float confThreshold = 0.25; // Confidence threshold
float nmsThreshold = 0.4;  // Non-maximum suppression threshold
int inpWidth = 416;  // Width of network's input image
int inpHeight = 416; // Height of network's input image
vector<string> classes;
QString global_lab;

// Remove the bounding boxes with low confidence using non-maxima suppression
void postprocess(Mat& frame, const vector<Mat>& out);

// Draw the predicted bounding box
void drawPred(int classId, float conf, int left, int top, int right, int bottom, Mat& frame);

// Get the names of the output layers
vector<String> getOutputsNames(const Net& net);

//check if the input is a directory
bool is_dir(const char* path) {
    struct stat buf;
    stat(path, &buf);
    return S_ISDIR(buf.st_mode);
}

//for rounding up values.
int round_up(int numToRound, int multiple){
    if (multiple == 0) return numToRound;
    int remainder = numToRound % multiple;
    if (remainder == 0) return numToRound;
    return numToRound + multiple - remainder;
}
//end of video detection functions

void updatevalues(void);
// All the definitions and initializations first, mostly for the labelling module


ClickableLabel::ClickableLabel(QWidget* parent, Qt::WindowFlags f)
    : QLabel(parent) {

}

ClickableLabel::~ClickableLabel() {}

void ClickableLabel::mousePressEvent(QMouseEvent* event) {
    if (event->button() == Qt::RightButton)
       {
       qInfo() << "RIGHT MB" << event->button() << endl;
       }
    if
       (event->button() == Qt::LeftButton)
       {
       qInfo() << "LMB" << event->button();
       }

    this->xBegin = this->xEnd = event->x();
    this->yBegin = this->yEnd = event->y();
    if(this->xBegin)
    emit mouseClicked(event->button());
}

void ClickableLabel::mouseReleaseEvent(QMouseEvent* event) {
    this->xEnd = event->x();
    this->yEnd = event->y();
    if(this->xEnd <= this->xBegin+10) this->xEnd += 20;
    if(this->yEnd <= this->yBegin+10) this->yEnd += 20;
    emit mouseReleased();
}

void ClickableLabel::mouseMoveEvent(QMouseEvent* event) {
    this->x = event->x();
    this->y = event->y();
    emit mouseMoved();
}


Login::Login(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::Login)
{
    ui->setupUi(this);
    ui->horizontalSliderRatio->setValue(80);
    ui->graphicsView->setScene(new QGraphicsScene(this));
    ui->graphicsView->scene()->addItem(&pixmap1);
    ui->graphicsView_2->setScene(new QGraphicsScene(this));
    ui->graphicsView_2->scene()->addItem(&pixmap2);

    ui->graphicsView_3->setScene(new QGraphicsScene(this));
    ui->graphicsView_3->scene()->addItem(&pixmap3);

    ui->graphicsView_4->setScene(new QGraphicsScene(this));
    ui->graphicsView_4->scene()->addItem(&pixmap4);

    QPixmap pix(":/resources/images/fcrit.png");
    int w = ui->logo_coll->width();
    int h = ui->logo_coll->height();
    ui->logo_coll->setPixmap(pix.scaled(w,h,Qt::KeepAspectRatio));
    QPixmap pix1(":/resources/images/tifr.png");
    int w1 = ui->logo_t->width();
    int h1 = ui->logo_t->height();
    ui->logo_t->setPixmap(pix1.scaled(w1,h1,Qt::KeepAspectRatio));

    connect(ui->labelImage, SIGNAL(mouseMoved()), this, SLOT(mouse_moved()));
    connect(ui->labelImage, SIGNAL(mouseClicked(int)), this, SLOT(mouse_pressed(int)));
    connect(ui->labelImage, SIGNAL(mouseReleased()), this, SLOT(mouse_released()));
    ui->scrollArea->setWidget(ui->labelImage);

    //setting the inital threshold for the Video Detection
    ui->Conf_Slider->setValue(confThreshold * 100);
    ui->label_conf->setText(QString::number(confThreshold));

    QString path = "users.db";
    db = QSqlDatabase::addDatabase("QSQLITE");//not dbConnection
    db.setDatabaseName(path);
    if(db.open())
        ui->labelDbStatus->setText("Connected");
    else
        ui->labelDbStatus->setText("Not connected");
    QSqlQuery query;
    query.exec("create table user "
              "(id varchar(20) primary key, "
              " password varchar(20),"
               "last_labelled_file varchar(50) DEFAULT '-',"
               "last_split_file varchar(50) DEFAULT '-',"
               "last_tr_darknet_directory varchar(50) DEFAULT '-',"
               "last_tr_validation_directory varchar(50) DEFAULT '-',"
               "last_tr_training_directory varchar(50) DEFAULT '-',"
               "last_tr_weight_file varchar(50) DEFAULT '-',"
               "last_tr_cfg_file varchar(50) DEFAULT '-',"
               "last_tr_new_trained_weights varchar(50) DEFAULT '-',"
               "last_te_weight_file varchar(50) DEFAULT '-',"
               "last_te_image_file varchar(50) DEFAULT '-',"
               "last_te_data_file varchar(50) DEFAULT '-',"
               "last_te_cfg_file varchar(50) DEFAULT '-',"
               "last_te_darknet_directory varchar(50) DEFAULT '-',"
               "last_te_video_file varchar(50) DEFAULT '-',"
               "last_names_file varchar(50) DEFAULT '-') ;");
}

Login::~Login()
{
    delete ui;
}

// ************************************************************************************************************************************
// **************************************************** LOGIN MODULE ******************************************************************
// ************************************************************************************************************************************
// This module is responsible for helping users register on the application as well as log onto.
// The functionalities of this module are
// 1. Registration
// 2. Login
// 3. Exiting



//checking login credentials of user
void Login::on_pushButtonLogin_clicked()
{
    QString un, pass;
    un = ui->lineEditUsername->text();
    pass = ui->lineEditPassword->text();
    QSqlQuery qry;
    if(qry.exec("SELECT * FROM user WHERE id='" + un +"' AND password='" + pass + "'"))
    {
        int count=0;
        while(qry.next())
            count++;
        if(count == 1)
        {
            QMessageBox m1;
            m1.setText("Logged in successully");
            m1.exec();
            ui->lineEditUsername->setText("");
            ui->lineEditPassword->setText("");
            ui->label_dummy->setText(un);
            ui->label_dummy->hide();
            //ui->labelMessage->setText("Logged in");
            //this->close();
//            MainWindow *m = new MainWindow(this);
//            m->show();
            ui->stackedWidget->setCurrentIndex(1);
            ui->pushButton_trainingdarknet->setVisible(false);
            ui->pushButton_labelimages->setVisible(false);
            ui->pushButtonSplitImages->setVisible(false);
            ui->pushButton_testing_darknet->setVisible(false);

        }
        else {
            QMessageBox m1;
            m1.setText("Log in failed");
            m1.exec();
        }
             //ui->labelMessage->setText("not logged in");
    }
    else {
        QMessageBox m1;
        m1.setText("Log in failed");
        m1.exec();
    }
         //ui->labelMessage->setText("not logged in");
     //ui->labelMessage->setText("not logged in");
}


//Register new users into the database
void Login::on_pushButtonRegister_clicked()
{
    QString un, pass;
    un = ui->lineEditUsername->text();
    pass = ui->lineEditPassword->text();
    if(un.size() == 0 || pass.size() == 0) {

        QMessageBox m1;
        m1.setText("Registration Failed");
        m1.exec();
        return;
    }
    QSqlQuery qry;
    if(qry.exec("INSERT INTO user(id,password) VALUES('"+un+"', '"+pass+"')"))
    {
        QMessageBox m1;
        m1.setText("Registered successully");
        m1.exec();
        ui->lineEditUsername->setText("");
        ui->lineEditPassword->setText("");

        //ui->labelMessage->setText("Registered");
    }
    else {
        QMessageBox m1;
        m1.setText("User Already Exists");
        m1.exec();
    }
        //ui->labelMessage->setText("Not registered Successfully");
}

//exiting the application from login/register page
void Login::on_pushButton_2_clicked()
{
    this->close();
}

//creating the help section for new users to understand the system
void Login::on_pushButton_clicked()
{
    QMessageBox help;
    help.setText("This Application is meant for providing an end to end system for custom training of Objects for darknet. "
                 "\n\n1. labelling the images in the dataset."
                 "\n\n2. Providing the split ratio for Training and Validation"
                 "\n\n3. Training using Darknet"
                 "\n\n4. Testing using Darknet");
    help.exec();
}

// **************************************************************************************************************************************************
// *************************************************************** LOGIN END ************************************************************************
// **************************************************************************************************************************************************

// **************************************************************************************************************************************************
// *************************************************************** HOMEPAGE MODULE ******************************************************************
// **************************************************************************************************************************************************
// This section is the homepage for the YOLO Darknet application. This is the navigation path where users can start using the application.
// Only functionality of this section is to provide routing to proper stacked widget

// This is the help section wherein user is informed the correct steps to use this application.
void Login::on_pushButton_helpmain_clicked()
{
    QMessageBox help ;

    help.setText("The main menu consists of two main portions, training and testing, the\n"
                 "user can decide on what they want to do and click the corresponding button.\n"
                 "Doing so will then reveal a dropdown menu that shows further options. Those\n"
                 "option will take the user to the respective page where the chosen task is\n"
                 "performed from. The training part consists of the Labeling module, the\n"
                 "dataset split module and the training module. The testing part consists of\n"
                 "image/video detection.\n"
                 "Also, the user can view their profile from this page, the profile page consists\n"
                 "of all the selected directories by the user and also provides an option to copy\n"
                 "the paths to the clipboard. Additionally there are options to log out or\n"
                 "directly quit the application from this page.\n"
                 "The steps in order to utilize this application are as follow :-  \n\n"
                 " 1. Click on label Images and provide a directory where all of your images are located. "
                 "Instruction on how to utilize labelling software will be given in the application.\n\n"
                 "2. After labelling we need to provide the split ratio for the training and the validation modules.\n\n"
                 " Usually 80:20 is the appropriate split.\n3. After providing the split ratio, user can then move onto the training module.\n\n"
                 "Detailed explanation is provided in the application help section of training. \n4. After Training is completed,"
                 "the user can then move onto testing their new trained model.\n\n");
    help.exec();
}

// Navigate to Labelling Module
void Login::on_pushButton_labelimages_clicked()
{
    cout << "clicked";

    ui->scrollArea->setWidget(ui->labelImage);
    ui->stackedWidget->setCurrentIndex(5);
    ui->stackedWidget_2->setCurrentIndex(1);

}

// Navigate to Dataset splitting Module
void Login::on_pushButtonSplitImages_clicked()
{
    ui->stackedWidget->setCurrentIndex(2);
}

// Navigate to Training Module
void Login::on_pushButton_trainingdarknet_clicked()
{
    ui->stackedWidget->setCurrentIndex(4);
}

// Navigate to Testing Module
void Login::on_pushButton_testing_darknet_clicked()
{
    ui->graphicsView->setScene(new QGraphicsScene(this));
    ui->graphicsView->scene()->addItem(&pixmap1);
    ui->graphicsView_2->setScene(new QGraphicsScene(this));
    ui->graphicsView_2->scene()->addItem(&pixmap2);
    ui->stackedWidget->setCurrentIndex(3);

}

// Navigate to Login/register page by logging out
void Login::on_pushButton_logout_clicked()
{
    ui->stackedWidget->setCurrentIndex(0);
}

void Login::on_pushButton_14_clicked()
{
    ui->stackedWidget->setCurrentIndex(6);
    updatevalues();
}

//enable the buttons when the user clicks on the training in main menu
void Login::on_pushButton_12_clicked()
{
    if(ui->pushButton_trainingdarknet->isVisible()) {
        ui->pushButton_trainingdarknet->setVisible(false);
    }
    if(ui->pushButton_labelimages->isVisible()) {
        ui->pushButton_labelimages->setVisible(false);
    }
    if(ui->pushButtonSplitImages->isVisible()) {
        ui->pushButtonSplitImages->setVisible(false);
    }
    else {
        ui->pushButton_trainingdarknet->setVisible(true);
        ui->pushButton_labelimages->setVisible(true);
        ui->pushButtonSplitImages->setVisible(true);
    }
    ui->pushButton_testing_darknet->setVisible(false);

}




//enable the buttons when the user clicks on the training in main menu
void Login::on_pushButton_13_clicked()
{
    ui->pushButton_trainingdarknet->setVisible(false);
    ui->pushButton_labelimages->setVisible(false);
    ui->pushButtonSplitImages->setVisible(false);
    if(ui->pushButton_testing_darknet->isVisible())
        ui->pushButton_testing_darknet->setVisible(false);
    else
        ui->pushButton_testing_darknet->setVisible(true);

}

// ********************************************************************************************************************************************
// ********************************************************** HOMEPAGE END ********************************************************************
// ********************************************************************************************************************************************

// ********************************************************** DATASET SPLIT MODULE **************************************************************
// **********************************************************************************************************************************************
// **********************************************************************************************************************************************

// In order to take the burden off the users for understanding the difference between the training and validation dataset
// This module is responsible for taking as input the labelled image directory and based on the split ratio, create two
// folders i.e. training and validation required for training in darknet

// Placeholder function. somehow you have to keep it (Qt)
void Login::on_horizontalSlider_valueChanged(int value)
{

}


// This is a helper function which is used to check if a particular string S1 is substring of String S2. It returns the index of the starting of the
// string S1 in string S2 else it returns -1.

int issubstring(string s1, string s2)
{
    int M = s1.length();
    int N = s2.length();
    for (int i = 0; i <= N - M; i++) {
        int j;
    for (j = 0; j < M; j++)
            if (s2[i + j] != s1[j])
                break;

        if (j == M)
            return i;
    }

    return -1;
}

// Updates the values of the training and the testing split in terms of %.
void Login::on_horizontalSliderRatio_valueChanged(int value)
{
    //qInfo() << "CHanged";
    int train = ui->horizontalSliderRatio->value();
    int validation = 100 - train;
    ui->labelTrainingPercentage->setText(QString::number(train));
    ui->labelValidationPercentage->setText(QString::number(validation));
}

// This function is used to check if an input file is a image file. Returns true if it is else returns False
bool isImageFiles(string fname)
{
    string extensions[6] = {"jpg", "jpeg", "png", "JPG", "JPEG", "PNG"};
    for(int i = 0; i < 6; i++)
    {
        string extension = extensions[i];
        if (fname.find(extension, (fname.length() - extension.length())) != std::string::npos)
            return true;
    }
    return false;
}


// onclick function used to select the image directory to be split
void Login::on_testing_select_images_clicked()
{
    QSettings MySettings;
    const QString DEFAULT_DIR_KEY("/home");
    this->files.clear();


    QString directory = QFileDialog::getExistingDirectory(this, "Select Images Path", MySettings.value(DEFAULT_DIR_KEY).toString());

    ui->labelImagesDirectory->setText(directory);
    QString temp = ui->labelImagesDirectory->text();
    string checker = temp.toUtf8().constData();
    if(checker=="") {
        QMessageBox::information(this,tr("Message"),tr("No images in selected directory"));
        return;
    }
    ui->labelImagesDirectory->setAlignment(Qt::AlignRight);
    DIR *dir;
    struct dirent *ent;
    if ((dir = opendir (directory.toStdString().c_str())) != NULL)
    {
        QDir CurrentDir;
        MySettings.setValue(DEFAULT_DIR_KEY,CurrentDir.absoluteFilePath(directory));
        while ((ent = readdir (dir)) != NULL)
            if(ent->d_type == DT_REG && isImageFiles(ent->d_name))
                this->files.push_back(ent->d_name);
        closedir (dir);
    }
    else {
        qInfo() << "Error in opening directory";
        return;
    }

    if(this->files.size() == 0) {
        QMessageBox::information(this,tr("Message"),tr("No images in selected directory"));
        ui->labelImagesDirectory->setText("");
        return;
    }

    //update in the database
    QSqlQuery query;

    if(query.exec("update user set last_split_file = '"+directory+"' where id = '"+ui->label_dummy->text()+"';"));
    else
        qInfo()<<"error in last_labelled_file";

    //end of update


    ui->pushButtonSave->setStyleSheet("background-color: rgb(238, 238, 236);"
                                           "border-style:solid;"
                                           "border-color: rgb(0,0,255);"
                                           "border-width:5px;"
                                           "font: 14pt \"DejaVu Sans\";");
}

// used to provide the user with the help section for utilising this module
void Login::on_testing_help_3_clicked()
{
    QMessageBox help;
    help.setText("1. In this section, the user needs to select the ratio of the images that they\n"
                 "want to use for training and validation.\n"
                 "2. The Default split is usually 80:20 but it’s upto the user if he/she wants\n"
                 "to manipulate this. (S)he can do it using the slider provided.\n"
                 "3. After clicking on the split button, two folders will be created in the folder\n"
                 "where the files were labelled.\n"
                 "4. The names of these folders are ’training’ and ’validation’. The validation\n"
                 "dataset is selected on a random basis.\n");
    help.exec();
}

// used to move back to the main menu
void Login::on_testing_back_clicked()
{
    ui->labelImagesDirectory->setText("-");
    ui->traning_label->setText("");
    ui->validation_label->setText("");
    ui->label_28->setText("");
    ui->label_29->setText("");
    ui->pushButtonSave->setStyleSheet("background-color: rgb(172, 171, 171);"
                                           "border-style:solid;"
                                           "border-color: rgb(0,0,0);"
                                           "border-width:5px;"
                                           "font: 14pt \"DejaVu Sans\";");
    ui->stackedWidget->setCurrentIndex(1);
}

// where the splitting magic happens. Sorry! well visit the function, comments will guide you to the magic trick
void Login::on_pushButtonSave_clicked()
{
    //Checking if the user has provided any image directory
    if(ui->labelImagesDirectory->text() == "-" || ui->labelImagesDirectory->text().isEmpty())
    {
        QMessageBox selectDir;
        selectDir.setText("Please select a directory before splitting ");
        selectDir.exec();
        return;
    }
    QString directory = ui->labelImagesDirectory->text();
    DIR *dir;
    struct dirent *ent;
    vector<string> files_txt;
    vector<string> files_temp;
    QSettings MySettings;
    const QString DEFAULT_DIR_KEY("/home");

    //navigating through the images in the folder and storing them in a folder
    if ((dir = opendir (directory.toStdString().c_str())) != NULL)
    {
        QDir CurrentDir;
        MySettings.setValue(DEFAULT_DIR_KEY,CurrentDir.absoluteFilePath(directory));
        while ((ent = readdir (dir)) != NULL)
            if(ent->d_type == DT_REG && isImageFiles(ent->d_name))
            {
                files_temp.push_back(ent->d_name);
             }
            else
            {
                int ifTextFile = issubstring(".txt",ent->d_name);
                if(ifTextFile!=-1)
                {
                    //qInfo()<<ent->d_name;
                    files_txt.push_back(ent->d_name);
                }
            }

        closedir (dir);
    }
    else
        qInfo() << "Error in opening directory";

        vector<string> files_1;

        for(int i1 = 0; i1<files_temp.size();i1++)
        {
            int flag=0;
            //qInfo()<<QString::fromStdString(files_temp[i1].substr(0,files_temp[i1].size()-4));

            for(int i2=0;i2<files_txt.size();i2++)
            {
                //qInfo()<<QString::fromStdString(files_txt[i2].substr(0,files_txt[i2].size()-4));

                if(files_txt[i2].substr(0,files_txt[i2].size()-4)==files_temp[i1].substr(0,files_temp[i1].size()-4))
                {
                    flag=1;
                    //qInfo()<<files_temp[i1];
                    files_1.push_back(files_temp[i1]);
                 }
            }
        }

        //calculating the number of training and testing images using the split ratio provided

        qInfo() << "Number of images:" << files_1.size();
        int no_of_validation = ui->labelValidationPercentage->text().toInt() * files_1.size()/100.0;
        qInfo() <<no_of_validation;
        int no_of_training = files_1.size() - no_of_validation;
        qInfo() << no_of_training;
        srand(time(NULL));
        vector<string> validation,training;
        for(int i = 0; i<no_of_validation;i++)
        {
            int ran = rand() % files_1.size();
            validation.push_back(files_1[ran]);
        }
        /*
        for (auto i = validation.begin(); i != validation.end(); ++i)
                qInfo() <<QString::fromStdString(*i);
        */

        //set differencing the total images to the validation images selected so that we get training images.
        set_difference(files_1.begin(),files_1.end(),validation.begin(),validation.end(),inserter(training,training.begin()));

        /*
        qInfo()<<"training set";

        for (auto i = training.begin(); i != training.end(); ++i)
                qInfo()<< QString::fromStdString(*i);
        */

        //deleting any previously existing training and validation folder if any
        if(!QDir(ui->labelImagesDirectory->text() + "/training").exists())
        {
            QDir().mkdir(ui->labelImagesDirectory->text() + "/training");
        }
        else
        {
            QString command = "rm -r " + ui->labelImagesDirectory->text() + "/training";
            int result = system(command.toStdString().c_str());
            //qInfo()<<result<<command;
            command = "rm -r " + ui->labelImagesDirectory->text() + "/validation";
            result = system(command.toStdString().c_str());
            //qInfo()<<result<<command;

            QDir().mkdir(ui->labelImagesDirectory->text() + "/training");
        }


        if(!QDir(ui->labelImagesDirectory->text() + "/validation").exists())
        {
            QDir().mkdir(ui->labelImagesDirectory->text() + "/validation");
        }

        //copying the training images from the image directory to the training folder
        for(int i = 0;i<training.size();i++)
        {
            QString filename = QString::fromStdString(training[i]);
            QString copy_from = ui->labelImagesDirectory->text()+ "/" + filename;
            QString copy_to = ui->labelImagesDirectory->text()+ "/training/" + filename;
            //qInfo()<<copy_from<<copy_to;
            QFile::copy(copy_from,copy_to);

            QString txt_filename = QString::fromStdString(training[i].substr(0,training[i].size()-4)) + ".txt";
             copy_from = ui->labelImagesDirectory->text()+ "/" + txt_filename;
             copy_to = ui->labelImagesDirectory->text()+ "/training/" + txt_filename;
            QFile::copy(copy_from,copy_to);

        }

        //copying the testing image from the image directory to the validation folder
        for(int i = 0;i<validation.size();i++)
        {
            QString filename = QString::fromStdString(validation[i]);
            QString copy_from = ui->labelImagesDirectory->text() + "/" + filename ;
            QString copy_to = ui->labelImagesDirectory->text() + "/validation/" + filename;
            //qInfo()<<copy_from<<copy_to;
            QFile::copy(copy_from,copy_to);

            QString txt_filename = QString::fromStdString(validation[i].substr(0,validation[i].size()-4)) + ".txt";
            copy_from = ui->labelImagesDirectory->text()+ "/" + txt_filename;
            copy_to = ui->labelImagesDirectory->text()+ "/validation/" + txt_filename;
            QFile::copy(copy_from,copy_to);

        }
        //seeing some bugs with the copy function(weird and redundant we know!) beause of which deleting the redundant files in training.

        for(int i = 0 ; i< validation.size();i++)
        {
            QString filename = QString::fromStdString(validation[i]);
            QString del_img = ui->labelImagesDirectory->text() + "/training/" + filename;\
            QString sub_file = QString::fromStdString(validation[i].substr(0,validation[i].size()-4));
            QString del_txt = ui->labelImagesDirectory->text() + "/training/" + sub_file + ".txt";
            QFile::remove(del_img);
            QFile::remove(del_txt);
        }


        //copying the classes.txt from the image directory to the training and validation folder
        QFile::copy(ui->labelImagesDirectory->text() + "/classes.txt",ui->labelImagesDirectory->text() + "/training/classes.txt");
        QFile::copy(ui->labelImagesDirectory->text() + "/classes.txt",ui->labelImagesDirectory->text() + "/validation/classes.txt");
        ui->label_28->setText(QString::number(no_of_training));
        ui->label_29->setText(QString::number(no_of_validation));
        ui->traning_label->setText(ui->labelImagesDirectory->text() + "/training");
        ui->validation_label->setText(ui->labelImagesDirectory->text() + "/validation");


}


// *************************************************************************************************************************************************
// ************************************************ DATASET SPLIT MODULE END ***********************************************************************
// *************************************************************************************************************************************************

