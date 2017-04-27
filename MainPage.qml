import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtGraphicalEffects 1.0

Rectangle {
    id: imagePage
    color: "#808080"
    objectName: "imagePage"

    function changeState(newState) {
        console.log("Current State:", state)
        console.log("New State:", newState)
        console.log("opacity of image:", foregroundImage.opacity)
        imagePage.state = newState
    }

    Timer {
        id: startOffTimer
        interval: 1000
        running: false
        onTriggered: {
            console.log("startoffTimer stopping")
            startOffTimer.stop()
            appWindow.setImageState("fadeIn")
        }
    }

    DropShadow {
        id: imageDropShadow
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        anchors.fill: foregroundImage
        samples: 17
        color: "#80000000"
        source: foregroundImage
        opacity: 0
    }

    Image {
        id: foregroundImage
        anchors.fill: parent
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        fillMode: Image.PreserveAspectFit
        opacity: 0
        source: mainWindow.currentImage
        autoTransform: true
    }

    states: [
        State {
            name: "Initialize"
            PropertyChanges {
                target: foregroundImage
                source: "qrc:/images/black.png"
            }
            PropertyChanges {
                target: foregroundImage
                opacity: 1
            }
            PropertyChanges {
                target: imageDropShadow
                opacity: 1
            }
            StateChangeScript {
                script: {
                    name: "InitializeScript"
                    console.log("InitializeScript")
                    appWindow.loadNextImage()
                    changeState("ImageOut")
                }
            }
        },

        State {
            name: "ImageOut"
            PropertyChanges {
                target: foregroundImage
                opacity: 0
            }
            PropertyChanges {
                target: imageDropShadow
                opacity: 0
            }
        },

        State {
            name: "ImageIn"
            PropertyChanges {
                target: foregroundImage
                opacity: 1
            }
            PropertyChanges {
                target: imageDropShadow
                opacity: 1
            }
        },
        State {
            name: "ImageDisplay"
            PropertyChanges {
                target: imageTimer
                running: true
            }
            PropertyChanges {
                target: foregroundImage
                opacity: 1
            }
            PropertyChanges {
                target: imageDropShadow
                opacity: 1
            }
            StateChangeScript {
                name: "ImageDisplayScript"
                script: {
                    console.log("ImageDisplayScript")
                    appWindow.loadNextImage()
                }
            }
        },
        State {
            name: "ImageReset"
            PropertyChanges {
                target: imageTimer
                running: false
            }
            PropertyChanges {
                target: newBackgroundImage
                source: mainWindow.nextImage
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "Initialize"
            ScriptAction {
                scriptName: "InitializeScript"
            }
        },
        Transition {
            from: "*"
            to: "ImageOut"
            ParallelAnimation {
                NumberAnimation {
                    target: foregroundImage
                    property: "opacity"
                    duration: appWindow.backgroundTransitionDuration/2
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: imageDropShadow
                    property: "opacity"
                    duration: appWindow.backgroundTransitionDuration/2
                    easing.type: Easing.InOutQuad
                }
            }

            onRunningChanged: {
                if((state=="ImageOut") && (!running)) {
                    mainWindow.currentImage = mainWindow.nextImage
                    changeState("ImageIn")
                }
            }
        },
        Transition {
            from: "*"
            to: "ImageIn"
            ParallelAnimation {
                NumberAnimation {
                    target: foregroundImage
                    property: "opacity"
                    duration: appWindow.backgroundTransitionDuration/2
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: imageDropShadow
                    property: "opacity"
                    duration: appWindow.backgroundTransitionDuration/2
                    easing.type: Easing.InOutQuad
                }
            }

            onRunningChanged: {
                if((state=="ImageIn") && (!running)) {
                    console.log("ImageChangeScript")
                    mainWindow.oldImage = mainWindow.currentImage
                    changeState("ImageDisplay")
                }
            }
        },
        Transition {
            from: "*"
            to: "ImageDisplay"
            ScriptAction{
                scriptName: "ImageDisplayScript"
            }
        },
        Transition {
            from: "*"
            to: "ImageReset"
            onRunningChanged: {
                console.log("ImageResetScript")
                changeState("ImageOut")
            }
        }
    ]

}
