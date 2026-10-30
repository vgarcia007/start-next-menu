/*
 *  SPDX-FileCopyrightText: Philipp Freilinger
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami as Kirigami

// Tab button for the menu header. The active tab is marked by a
// highlighted underline, bold text and full label opacity.
QQC2.AbstractButton {
    id: control

    property bool tabActive: false

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: 40
    leftPadding: 12
    rightPadding: 12
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    Accessible.name: text
    Accessible.role: Accessible.PageTab

    background: Item {
        Rectangle {
            id: underline
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: control.leftPadding
            anchors.right: parent.right
            anchors.rightMargin: control.rightPadding
            height: 3
            radius: 1.5
            color: Kirigami.Theme.highlightColor
            opacity: control.tabActive ? 1.0 : (control.hovered ? 0.35 : 0.0)
            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    contentItem: PC3.Label {
        text: control.text
        textFormat: Text.PlainText
        font.bold: control.tabActive
        font.pointSize: Kirigami.Theme.defaultFont.pointSize
        color: Kirigami.Theme.textColor
        opacity: control.tabActive ? 1.0 : 0.6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
