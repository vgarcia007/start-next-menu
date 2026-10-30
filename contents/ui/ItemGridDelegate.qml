/*
    SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami

import "code/tools.js" as Tools

Item {
    id: item

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    enabled: !model.disabled

    property bool showLabel: true
    property bool listMode: false

    property int itemIndex: model.index
    property string favoriteId: model.favoriteId !== undefined ? model.favoriteId : ""
    property url url: model.url !== undefined ? model.url : ""
    property variant icon: model.decoration !== undefined ? model.decoration : ""
    property var m: model
    property bool hasActionList: ((model.favoriteId !== null)
        || (("hasActionList" in model) && (model.hasActionList === true)))

    Accessible.role: Accessible.MenuItem
    Accessible.name: model.display

    function openActionMenu(x, y) {
        var actionList = hasActionList ? model.actionList : [];
        Tools.fillActionMenu(i18n, actionMenu, actionList, GridView.view.model.favoritesModel, model.favoriteId);
        actionMenu.visualParent = item;
        actionMenu.open(x, y);
    }

    function actionTriggered(actionId, actionArgument) {
        var close = (Tools.triggerAction(GridView.view.model, model.index, actionId, actionArgument) === true);

        if (close) {
            root.toggle();
        }
    }

    Kirigami.Icon {
        id: icon

        y: item.showLabel && !item.listMode ? (2 * highlightItemSvg.margins.top) : undefined

        anchors.horizontalCenter: item.listMode ? undefined : parent.horizontalCenter
        anchors.left: item.listMode ? parent.left : undefined
        anchors.leftMargin: 10
        anchors.verticalCenter: item.listMode || !item.showLabel ? parent.verticalCenter : undefined

        width: iconSize
        height: width

        animated: false

        source: model.decoration
    }

    PlasmaComponents3.Label {
        id: label

        visible: item.showLabel

        anchors {
            top: item.listMode ? undefined : icon.bottom
            topMargin: item.listMode ? 0 : Kirigami.Units.smallSpacing
            verticalCenter: item.listMode ? parent.verticalCenter : undefined
            left: item.listMode ? icon.right : parent.left
            leftMargin: item.listMode ? 10 : highlightItemSvg.margins.left
            right: parent.right
            rightMargin: item.listMode ? 10 : highlightItemSvg.margins.right
        }

        horizontalAlignment: item.listMode ? Text.AlignLeft : Text.AlignHCenter

        maximumLineCount: item.listMode ? 1 : 2
        elide: item.listMode ? Text.ElideRight : Text.ElideMiddle
        wrapMode: item.listMode ? Text.NoWrap : Text.Wrap

        color: Kirigami.Theme.textColor

        font.pointSize: Kirigami.Theme.defaultFont.pointSize * (item.listMode ? 1 : .9)
        text: ("name" in model ? model.name : model.display)
        textFormat: Text.PlainText
    }

    PlasmaCore.ToolTipArea {
        id: toolTip

        property string text: model.display

        anchors.fill: parent
        active: root.visible && label.truncated
        mainItem: toolTipDelegate

        onContainsMouseChanged: item.GridView.view.itemContainsMouseChanged(containsMouse)
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Menu && hasActionList) {
            event.accepted = true;
            openActionMenu(item);
        } else if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
            event.accepted = true;

            if ("trigger" in GridView.view.model) {
                GridView.view.model.trigger(index, "", null);
                root.toggle();
            }

            itemGrid.itemActivated(index, "", null);
        }
    }
}
