import QtQuick 2.14
import QtQuick.Controls 2.14

Item {
    id: root
    width: 150
    height: 100
    visible: true // Her zaman görünür olması için true yapıldı

    // İsim Etiketi (Tıklayınca görünür, sonra kaybolur)
    Rectangle {
        id: infoLabel
        visible: false
        width: 140
        height: 40
        color: "#333333"
        radius: 8
        anchors.bottom: userButton.top
        anchors.bottomMargin: 10
        anchors.horizontalCenter: userButton.horizontalCenter

        Text {
            anchors.centerIn: parent
            text: "Yakup Şaşmaz"
            color: "white"
            font.bold: true
            font.pixelSize: 14
        }
    }

    // Kullanıcı Butonu
    Rectangle {
        id: userButton
        width: 120
        height: 50
        radius: 25
        color: mouseArea.pressed ? "#e0e0e0" : "#ffffff"
        border.color: "#2196F3"
        border.width: 3
        anchors.centerIn: parent

        Text {
            anchors.centerIn: parent
            text: "Kullanıcı"
            color: "#2196F3"
            font.bold: true
            font.pixelSize: 16
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                infoLabel.visible = true
                hideTimer.restart()
            }
        }
    }

    // 3 saniye sonra ismi gizleyen zamanlayıcı
    Timer {
        id: hideTimer
        interval: 3000
        onTriggered: infoLabel.visible = false
    }
}
