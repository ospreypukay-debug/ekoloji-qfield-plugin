import QtQuick 2.14
import QtQuick.Controls 2.14
import QField 1.0

/**
 * Ekoloji Çizim Yardımcısı – QField 4.x Eklentisi
 * -------------------------------------------------
 * Tablet / stylus kullanımında çizgi uzama sorununu çözer.
 *
 * Ekranda sabit iki büyük buton gösterir:
 *   ✓  ONAYLA   → çizimi tamamlar (native ✓ yerine kullan)
 *   ↩  GERİ AL  → son noktayı siler
 *
 * Butonlar yalnızca aktif çizim (digitizing) sırasında görünür.
 * Konumları: sol alt köşe – native butonlarla çakışmaz.
 */
Item {
    id: root

    // QField tarafından enjekte edilir
    property var iface

    // ----------------------------------------------------------------
    // Çizim durumu takibi
    // ----------------------------------------------------------------
    property bool digitizingActive: false

    // iface hazır olduğunda bağlantıları kur
    onIfaceChanged: {
        if (!iface) return

        // Çizim başladığında butonları göster
        if (iface.digitizingSession !== undefined) {
            digitizingActive = Qt.binding(function() {
                return iface.digitizingSession !== null &&
                       iface.digitizingSession !== undefined
            })
        }
    }

    // Yedek: Connections ile sinyal dinle
    Connections {
        target: iface
        ignoreUnknownSignals: true

        function onDigitizingSessionStarted()  { root.digitizingActive = true  }
        function onDigitizingSessionStopped()  { root.digitizingActive = false }
        function onDigitizingSessionFinished() { root.digitizingActive = false }
    }
// ----------------------------------------------------------------
    // 🎨 RENK DEĞİŞTİR butonu – Diğer butonların yanına ekle
    // ----------------------------------------------------------------
    Rectangle {
        id: btnRenkDegistir
        visible: root.digitizingActivevisible: true
        width:  80
        height: 80
        radius: 40
        anchors.left:   btnOnayla.right
        anchors.bottom: btnOnayla.bottom
        anchors.leftMargin: 12

        color: colorArea.pressed ? "#1976D2" : "#2196F3"
        border.color: "#0D47A1"
        border.width: 2

        Column {
            anchors.centerIn: parent
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "🎨"
                font.pixelSize: 28
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "RENK"
                font.pixelSize: 10
                font.bold: true
                color: "white"
            }
        }

        MouseArea {
            id: colorArea
            anchors.fill: parent
            onClicked: {
                // QField çizim katmanının stilini geçici olarak değiştirir
                if (iface && iface.activeLayer) {
                    // Örnek: Çizgiyi fosforlu sarı veya kırmızı yapar
                    iface.activeLayer.renderer().symbol().setColor(Qt.rgba(1, 0, 0, 1)) // Kırmızı
                    iface.activeLayer.triggerRepaint()
                }
            }
        }
    }
    // ----------------------------------------------------------------
    // ✓ ONAYLA butonu – sol alt, büyük ve parmak/stylus dostu
    // ----------------------------------------------------------------
    Rectangle {
        id: btnOnayla
        visible: root.digitizingActive
        opacity: visible ? 1.0 : 0.0

        width:  100
        height: 100
        radius: 50

        anchors.left:   parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin:   24
        anchors.bottomMargin: 120   // QField'ın alt toolbar'ından yukarıda

        // Yeşil dolgu + hafif gölge
        color: confirmArea.pressed ? "#388E3C" : "#4CAF50"
        layer.enabled: true
        layer.effect: null          // gölge Qt5'te DropShadow gerektirir, sade bırakıyoruz

        // Kenarlık
        border.color: "#2E7D32"
        border.width: 3

        Behavior on opacity { NumberAnimation { duration: 150 } }

        // İkon + yazı
        Column {
            anchors.centerIn: parent
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "✓"
                font.pixelSize: 38
                font.bold: true
                color: "white"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "ONAYLA"
                font.pixelSize: 11
                font.bold: true
                color: "white"
            }
        }

        MouseArea {
            id: confirmArea
            anchors.fill: parent
            onClicked: {
                // QField 4.x API – birden fazla yol deniyoruz
                if (iface && iface.digitizingSession &&
                    typeof iface.digitizingSession.confirm === "function") {
                    iface.digitizingSession.confirm()
                    return
                }
                if (iface && typeof iface.digitizingConfirm === "function") {
                    iface.digitizingConfirm()
                    return
                }
                if (iface && typeof iface.commitCurrentFeature === "function") {
                    iface.commitCurrentFeature()
                    return
                }
                // Son çare: native ✓ butonunu bul ve tıkla
                _nativeButonuTikla("ConfirmButton", iface)
            }
        }
    }

    // ----------------------------------------------------------------
    // ↩ GERİ AL butonu – onay butonunun hemen üstünde
    // ----------------------------------------------------------------
    Rectangle {
        id: btnGeriAl
        visible: root.digitizingActive
        opacity: visible ? 1.0 : 0.0

        width:  80
        height: 80
        radius: 40

        anchors.left:         btnOnayla.left
        anchors.bottom:       btnOnayla.top
        anchors.bottomMargin: 12

        color: undoArea.pressed ? "#E65100" : "#FF9800"
        border.color: "#BF360C"
        border.width: 2

        Behavior on opacity { NumberAnimation { duration: 150 } }

        Column {
            anchors.centerIn: parent
            spacing: 1

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "↩"
                font.pixelSize: 28
                font.bold: true
                color: "white"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "GERİ"
                font.pixelSize: 10
                font.bold: true
                color: "white"
            }
        }

        MouseArea {
            id: undoArea
            anchors.fill: parent
            onClicked: {
                if (iface && iface.digitizingSession &&
                    typeof iface.digitizingSession.removeLastVertex === "function") {
                    iface.digitizingSession.removeLastVertex()
                    return
                }
                if (iface && typeof iface.removeLastVertex === "function") {
                    iface.removeLastVertex()
                    return
                }
                _nativeButonuTikla("UndoButton", iface)
            }
        }
    }

    // ----------------------------------------------------------------
    // Yardımcı: native QField butonunu objectName ile bul ve tıkla
    // ----------------------------------------------------------------
    function _nativeButonuTikla(objectName, ifaceObj) {
        if (!ifaceObj) return
        var win = null
        if (typeof ifaceObj.mainWindow === "function") {
            win = ifaceObj.mainWindow()
        } else if (ifaceObj.mainWindow !== undefined) {
            win = ifaceObj.mainWindow
        }
        if (!win) return

        var found = _araItem(win, objectName)
        if (found && typeof found.clicked === "function") {
            found.clicked()
        }
    }

    function _araItem(kök, hedefİsim) {
        if (!kök) return null
        if (kök.objectName === hedefİsim) return kök
        for (var i = 0; i < kök.children.length; i++) {
            var sonuç = _araItem(kök.children[i], hedefİsim)
            if (sonuç) return sonuç
        }
        return null
    }
}
