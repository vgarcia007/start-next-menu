import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

QQC2.AbstractButton {
    id: control
    property url iconSource
    property bool iconOnly: false

    implicitWidth: iconOnly ? implicitHeight : contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: Math.max(40, contentItem.implicitHeight + topPadding + bottomPadding)
    leftPadding: 10
    rightPadding: 10
    topPadding: 8
    bottomPadding: 8
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: text

    background: MenuHighlight {
        anchors.fill: parent
        highlighted: control.hovered
        keyboardFocus: control.visualFocus
        pressed: control.down
    }
    contentItem: RowLayout {
        spacing: 10
        Kirigami.Icon {
            visible: control.iconSource.toString() !== ""
            source: control.iconSource
            isMask: true
            color: Kirigami.Theme.textColor
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignCenter
        }
        PC3.Label {
            visible: !control.iconOnly
            text: control.text
            textFormat: Text.PlainText
            Layout.fillWidth: true
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: control.iconSource.toString() === "" ? Text.AlignHCenter : Text.AlignLeft
        }
    }
    QQC2.ToolTip.text: text
    QQC2.ToolTip.visible: iconOnly && hovered
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
}
