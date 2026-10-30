import QtQuick
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.Highlight {
    property bool highlighted: false
    property bool keyboardFocus: false

    hovered: true
    opacity: highlighted || keyboardFocus || pressed ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.OutCubic
        }
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 4
        color: "transparent"
        border.width: parent.keyboardFocus ? 1 : 0
        border.color: Kirigami.Theme.highlightColor
    }
}
