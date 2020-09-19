#-------------------------------------------------
#
# Project created by QtCreator 2019-09-13T20:40:26
#
#-------------------------------------------------

QT       += core gui sql

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = YOLO_Darknet

TEMPLATE = app
#SUBDIRS += labeling
# Use ordered build, from first subdir (project_a) to the last (project_b):
#CONFIG += ordered

LIBS += `pkg-config opencv4 --libs` -Llabeling
QMAKE_CXXFLAGS += -std=c++11 -ggdb `pkg-config --cflags --libs opencv4`

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0


SOURCES += \
        main.cpp \
    login.cpp


HEADERS += \
    clickablelabel.h \
    login.h


FORMS += \
    login.ui


RESOURCES += \
    resources.qrc
