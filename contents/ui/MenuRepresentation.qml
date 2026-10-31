/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.components 3.0 as PC3

import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.coreaddons 1.0 as KCoreAddons // kuser
//import org.kde.plasma.private.shell 2.0
import org.kde.plasma.private.sessions as Sessions
//import org.kde.kwindowsystem 1.0
import org.kde.kquickcontrolsaddons 2.0
//import org.kde.plasma.private.quicklaunch 1.0
import QtQuick.Controls 2.15
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import Qt5Compat.GraphicalEffects

Item {
    id: main
    property int sizeImage: Kirigami.Units.iconSizes.large * 2
    property int menuPos: Plasmoid.configuration.displayPosition

    onVisibleChanged: {
        root.visible = !root.visible
    }

    PlasmaExtras.Menu {
        id: contextMenu

        PlasmaExtras.MenuItem {
            action: Plasmoid.internalAction("configure")
        }
    }

    SoInfo {
        id: soInfo
        visible: false
    }


    Plasmoid.status: root.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    PlasmaCore.Dialog {
        id: root

        objectName: "popupWindow"
        flags: Qt.WindowStaysOnTopHint
        //flags: Qt.Dialog | Qt.FramelessWindowHint
        location: PlasmaCore.Types.Floating
        hideOnWindowDeactivate: true

        property int iconSize: Kirigami.Units.iconSizes.large
        property int cellSizeHeight: iconSize
                                     + Kirigami.Units.gridUnit * 2
                                     + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                                                     highlightItemSvg.margins.left + highlightItemSvg.margins.right))
        property int cellSizeWidth: cellSizeHeight

        property bool searching: (searchField.text != "")

        // which tab is active: 0 = Favorites, 1 = All apps
        property int activeTab: 1

        // true while the favorites grid is the one that is shown
        property bool showFavorites: activeTab === 0

        onVisibleChanged: {
            if (visible) {
                // Every time the menu opens: clear the search and start on the Favorites tab
                searchField.text = ""
                root.activeTab = 0
                var pos = popupPosition(width, height);
                x = pos.x;
                y = pos.y;
                reset();
                animation1.start()
                Qt.callLater(function() {
                    if (root.visible) {
                        searchField.forceActiveFocus()
                    }
                })
            }else{
                rootItem.opacity = 0
            }
        }

        onHeightChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        onWidthChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        function toggle(){
            main.visible =  !main.visible
        }


        function reset() {
            //searchField.text = "";

            if (searching)
                runnerGrid.tryActivate(0,0)
            else if (showFavorites)
                globalFavoritesGrid.tryActivate(0,0)
            else
                mainColumn.visibleGrid.tryActivate(0,0)
        }

        function popupPosition(width, height) {
            var screenAvail = kicker.availableScreenRect;
            var screen = kicker.screenGeometry;
            var panelH = kicker.height
            var panelW = kicker.width
            var horizMidPoint = screen.x + (screen.width / 2);
            var vertMidPoint = screen.y + (screen.height / 2);
            var appletTopLeft = parent.mapToGlobal(0, 0);

            function calculatePosition(x, y) {
                return Qt.point(x, y);
            }

            if (menuPos === 0) {
                switch (plasmoid.location) {
                    case PlasmaCore.Types.BottomEdge:
                        var x = appletTopLeft.x < screen.width - width ? appletTopLeft.x : screen.width - width - 8;
                        var y = appletTopLeft.y - height - Kirigami.Units.gridUnit
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.TopEdge:
                        x = appletTopLeft.x < screen.width - width ? appletTopLeft.x + panelW - Kirigami.Units.gridUnit / 3 : screen.width - width;
                        y = appletTopLeft.y + kicker.height + Kirigami.Units.gridUnit
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.LeftEdge:
                        x = appletTopLeft.x + panelW + Kirigami.Units.gridUnit / 2;
                        y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : appletTopLeft.y - height + iconUser.height / 2;
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.RightEdge:
                        x = appletTopLeft.x - width - Kirigami.Units.gridUnit / 2;
                        y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : screen.height - height - Kirigami.Units.gridUnit / 5;
                        return calculatePosition(x, y);

                    default:
                        return;
                }
            } else if (menuPos === 2) {
                x = horizMidPoint - width / 2;
                y = screen.height - height - panelH - Kirigami.Units.gridUnit / 2;
                return calculatePosition(x, y);
            } else if (menuPos === 1) {
                x = horizMidPoint - width / 2;
                y = vertMidPoint - height / 2;
                return calculatePosition(x, y);
            }
        }


        FocusScope {
            id: rootItem
            Layout.minimumWidth:  Kirigami.Units.gridUnit*30
            Layout.maximumWidth:  Layout.minimumWidth
            Layout.minimumHeight: (root.cellSizeHeight *  Plasmoid.configuration.numberRows) + searchField.implicitHeight + (Plasmoid.configuration.viewUser ? main.sizeImage*0.5 : Kirigami.Units.gridUnit * 1.5 ) +  Kirigami.Units.gridUnit * 6.2
            Layout.maximumHeight: (root.cellSizeHeight *  Plasmoid.configuration.numberRows) + searchField.implicitHeight + (Plasmoid.configuration.viewUser ? main.sizeImage*0.5 : Kirigami.Units.gridUnit * 1.5 ) +  Kirigami.Units.gridUnit * 6.2
            focus: true

            property alias activeTab: root.activeTab

            KCoreAddons.KUser {   id: kuser  }



            OpacityAnimator { id: animation1; target: rootItem; from: 0; to: 1; easing.type: Easing.InOutQuad;  }

            Sessions.SessionManagement {
                id: sm
            }

            P5Support.DataSource {
                id: executable
                engine: "executable"
                connectedSources: []
                onNewData: {
                    var exitCode = data["exit code"]
                    var exitStatus = data["exit status"]
                    var stdout = data["stdout"]
                    var stderr = data["stderr"]
                    exited(sourceName, exitCode, exitStatus, stdout, stderr)
                    disconnectSource(sourceName)
                }
                function exec(cmd) {
                    if (cmd) {
                        connectSource(cmd)
                    }
                }
                signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
            }

            PlasmaExtras.Highlight  {
                id: delegateHighlight
                visible: false
                z: -1 // otherwise it shows ontop of the icon/label and tints them slightly
            }

            KSvg.FrameSvgItem {
                id : headingSvg
                width: parent.height + backgroundSvg.margins.bottom + backgroundSvg.margins.top
                //height:  root.cellSizeHeight * Plasmoid.configuration.numberRows  + Kirigami.Units.gridUnit * 2 + backgroundSvg.margins.bottom - 1 //<>+ paginationBar.height
                height: parent.width*.4 + backgroundSvg.margins.left
                y:  - backgroundSvg.margins.top
                x: parent.width + backgroundSvg.margins.left
                imagePath: "widgets/plasmoidheading"
                prefix: "header"
                opacity: 0.6
                transform: Rotation {
                    angle: 90
                    origin.x: width / 2
                    origin.y: height / 2
                }
            }




            RowLayout {
                id: rowSearchField
                width: parent.width*.4
                anchors{
                    top: parent.top
                    topMargin: Kirigami.Units.gridUnit*1
                    left: parent.left
                    leftMargin: (parent.width*.6 - width)/2
                    margins: Kirigami.Units.smallSpacing
                }


                PC3.TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: i18n("Type here to search ...")
                    topPadding: 10
                    bottomPadding: 10
                    leftPadding: ((parent.width - width)/2) + Kirigami.Units.iconSizes.small*2
                    text: ""
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    onTextChanged: {
                        runnerModel.query = text;
                        // while typing, search results replace the list views
                        if (text !== "") {
                            rootItem.activeTab = 1
                        }
                    }

                    Keys.onPressed: (event)=> {
                                        if (event.key === Qt.Key_Escape) {
                                            event.accepted = true;
                                            if(root.searching){
                                                searchField.clear()
                                            } else {
                                                root.toggle()
                                            }
                                        }

                                        if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                                            event.accepted = true;
                                            if (root.searching)
                                                runnerGrid.tryActivate(0,0)
                                            else if (root.showFavorites)
                                                globalFavoritesGrid.tryActivate(0,0)
                                            else
                                                mainColumn.visibleGrid.tryActivate(0,0)
                                        }
                                    }

                    function backspace() {
                        if (!root.visible) {
                            return;
                        }
                        focus = true;
                        text = text.slice(0, -1);
                    }

                    function appendText(newText) {
                        if (!root.visible) {
                            return;
                        }
                        focus = true;
                        text = text + newText;
                    }
                    Kirigami.Icon {
                        source: Qt.resolvedUrl("icons/search-outline.svg")
                        isMask: true
                        color: Kirigami.Theme.textColor
                        anchors {
                            left: searchField.left
                            verticalCenter: searchField.verticalCenter
                            leftMargin: Kirigami.Units.smallSpacing * 2

                        }
                        height: Kirigami.Units.iconSizes.small
                        width: height
                    }

                }

                Item {
                    Layout.fillWidth: true
                }


            }

            Row {
                id: tabBar
                height: Math.max(tabsFavorites.implicitHeight, tabsAllApps.implicitHeight)
                anchors.left: parent.left
                anchors.top: rowSearchField.bottom
                anchors.topMargin: Kirigami.Units.smallSpacing
                anchors.leftMargin: parent.width - headingSvg.height - width - 16

                MenuTab {
                    id: tabsFavorites
                    tabActive: rootItem.activeTab === 0
                    text: i18n("Favorites")
                    onClicked: {
                        rootItem.activeTab = 0
                        if (root.searching) {
                            searchField.clear()
                        }
                    }
                }
                MenuTab {
                    id: tabsAllApps
                    tabActive: rootItem.activeTab === 1
                    text: i18n("All apps")
                    onClicked: {
                        rootItem.activeTab = 1
                        if (root.searching) {
                            searchField.clear()
                        }
                    }
                }
            }

            ItemGridView {
                id: globalFavoritesGrid
                visible: root.showFavorites && !root.searching
                anchors {
                    top: rowSearchField.bottom
                    topMargin: Kirigami.Units.gridUnit * 3
                    bottom: parent.bottom
                    bottomMargin: Kirigami.Units.smallSpacing * 2
                }

                dragEnabled: true
                dropEnabled: true
                width: rootItem.width*.6
                focus: true
                cellWidth:   96
                cellHeight:  root.cellSizeHeight
                iconSize:    32
                onKeyNavUp: searchField.focus = true
                Keys.onPressed:(event)=> {
                                   if(event.modifiers & Qt.ControlModifier ||event.modifiers & Qt.ShiftModifier){
                                       searchField.focus = true;
                                       return
                                   }
                                   if (event.key === Qt.Key_Tab) {
                                       event.accepted = true;
                                       searchField.focus = true
                                   }
                               }
            }
            /* zayron code*/
            /*
             *
             */

            Column {
                id: places
                width: headingSvg.height*.8
                anchors.top: tabBar.bottom
                anchors.topMargin: Kirigami.Units.smallSpacing * 2
                anchors.bottom: shutdownIcon.top
                anchors.bottomMargin: Kirigami.Units.smallSpacing * 2
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.smallSpacing * 2

                ListModel {
                    id: userDirs
                    ListElement {
                        text: "Home"
                        icon: "icons/home-outline.svg"
                        command: "xdg-open $HOME"
                    }
                    ListElement {
                        text: "Documents"
                        icon: "icons/documents-outline.svg"
                        command: "file:///home/deck/OneDrive/Documents"
                    }
                    ListElement {
                        text: "OneDrive"
                        icon: "icons/onedrive-outline.svg"
                        command: "file:///home/deck/OneDrive"
                    }
                    ListElement {
                        text: "Gaming Mode"
                        icon: "icons/gamepad-outline.svg"
                        command: "bash -c 'if [[ \"$(steamosctl get-default-login-mode)\" == desktop ]]; then steamosctl switch-to-game-mode; else qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout; fi'"
                    }
                    ListElement {
                        text: "System Settings"
                        icon: "icons/settings-outline.svg"
                        command: "systemsettings"
                    }
                }
                ListView {
                    id: listPlaces
                    model: userDirs
                    width: parent.width
                    height: Math.min(contentHeight, parent.height)
                    spacing: 4
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: MenuButton {
                        width: ListView.view.width
                        text: i18n(model.text)
                        iconSource: Qt.resolvedUrl(model.icon)
                        onClicked: {
                            if (model.text === "Documents" || model.text === "OneDrive") {
                                Qt.openUrlExternally(model.command)
                            } else {
                                executable.exec(model.command)
                            }
                        }
                    }
                }
            }

            MenuButton {
                id: shutdownIcon
                width: 44
                height: 44
                iconOnly: true
                text: i18n("Power options")
                iconSource: Qt.resolvedUrl("icons/power-outline.svg")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit
                anchors.right: parent.right
                anchors.rightMargin: parent.width * .2 - width / 2
                onClicked: sm.requestLogoutPrompt()
            }
            Item {
                width: headingSvg.height - Kirigami.Units.gridUnit * 2
                height: textuser.implicitHeight
                visible: true
                anchors.top: parent.top
                anchors.topMargin: iconUser.height/2 + Kirigami.Units.gridUnit * .5
                anchors.right: parent.right
                anchors.rightMargin: (headingSvg.height - width)/2

                Text {
                    width: parent.width
                    height: parent.height
                    id: textuser
                    text:  i18n("Hi, ")+ kuser.fullName
                    font.bold: true
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.15
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    color: Kirigami.Theme.textColor
                }
            }
            //
            //
            //
            //
            //
            Item{
                id: mainGrids
                // Always laid out: the search result grid inside needs its
                // initial layout pass even when the Favorites tab is shown.
                // (allAppsGrid itself is hidden while favorites/search apply)

                anchors {
                    top: rowSearchField.bottom
                    topMargin: Kirigami.Units.gridUnit * 3
                    bottom: parent.bottom
                    bottomMargin: Kirigami.Units.smallSpacing * 2
                    //left: parent.left
                    //right: parent.right

                }

                width: rootItem.width

                Item {
                    id: mainColumn
                    //width: root.cellSize *  Plasmoid.configuration.numberColumns + Kirigami.Units.gridUnit
                    width: rootItem.width
                    height: parent.height

                    property Item visibleGrid: allAppsGrid

                    function tryActivate(row, col) {
                        if (visibleGrid) {
                            visibleGrid.tryActivate(row, col);
                        }
                    }

                    ItemGridView {
                        id: allAppsGrid
                        listMode: true

                        //width: root.cellSize *  Plasmoid.configuration.numberColumns + Kirigami.Units.gridUnit
                        width: rootItem.width*.6
                        Layout.maximumWidth: rootItem.width*.6
                        height: parent.height
                        cellWidth: width - Kirigami.Units.gridUnit
                        cellHeight: 44
                        iconSize: 24
                        visible: !root.searching && !root.showFavorites
                        enabled: visible ? 1 : 0
                        z:  enabled ? 5 : -1
                        dropEnabled: false
                        dragEnabled: false
                        onVisibleChanged: {
                            if (visible) {
                                //allAppsGrid.scrollBar.flickableItem.contentY = 0;
                                mainColumn.visibleGrid = allAppsGrid;
                            }
                        }
                        onKeyNavUp: searchField.focus = true
                    }

                    ItemMultiGridView {
                        id: runnerGrid
                        width: rootItem.width*.6
                        height: parent.height
                        // search results are rendered as a flat list, like the "All apps" list
                        listMode: true
                        cellWidth:   width - Kirigami.Units.gridUnit
                        cellHeight:  44
                        enabled: (opacity == 1.0) ? 1 : 0
                        z:  enabled ? 5 : -1
                        model: runnerModel
                        grabFocus: true
                        opacity: root.searching ? 1.0 : 0.0
                        onOpacityChanged: {
                            if (opacity == 1.0) {
                                mainColumn.visibleGrid = runnerGrid;
                            }
                        }
                        onKeyNavUp: searchField.focus = true
                    }

                    Keys.onPressed: (event)=> {
                                        if(event.modifiers & Qt.ControlModifier ||event.modifiers & Qt.ShiftModifier){
                                            searchField.focus = true;
                                            return
                                        }
                                        if (event.key === Qt.Key_Tab) {
                                            event.accepted = true;
                                            searchField.focus = true
                                        } else if (event.key === Qt.Key_Backspace) {
                                            event.accepted = true;
                                            if(root.searching)
                                            searchField.backspace();
                                            else
                                            searchField.focus = true
                                        } else if (event.key === Qt.Key_Escape) {
                                            event.accepted = true;
                                            if(root.searching){
                                                searchField.clear()
                                            } else {
                                                root.toggle()
                                            }
                                        } else if (event.text !== "") {
                                            event.accepted = true;
                                            searchField.appendText(event.text);
                                            rootItem.activeTab = 1
                                        }
                                    }
                }
            }




            Keys.onPressed: (event)=> {
                                if(event.modifiers & Qt.ControlModifier ||event.modifiers & Qt.ShiftModifier){
                                    searchField.focus = true;
                                    return
                                }
                                if (event.key === Qt.Key_Escape) {
                                    event.accepted = true;
                                    if (root.searching) {
                                        reset();
                                    } else {
                                        root.visible = false;
                                    }
                                    return;
                                }

                                if (searchField.focus) {
                                    return;
                                }

                                if (event.key === Qt.Key_Backspace) {
                                    event.accepted = true;
                                    searchField.backspace();
                                }  else if (event.text !== "") {
                                    event.accepted = true;
                                    searchField.appendText(event.text);
                                }
                            }

        }

        function setModels(){
            globalFavoritesGrid.model = globalFavorites
            allAppsGrid.model = rootModel.modelForRow(0);
        }

        Component.onCompleted: {
            rootModel.refreshed.connect(setModels)
            reset();
            rootModel.refresh();
        }
    }



    PlasmaCore.Dialog {
        id: dialog

        width:  main.sizeImage*.85
        height: width

        visible: root.visible

        y: root.y - sizeImage/2
        x: root.x + root.width*.81 - sizeImage/2

        objectName: "popupWindowIcon"
        //flags: Qt.WindowStaysOnTopHint
        type: "Notification"
        location: PlasmaCore.Types.Floating

        hideOnWindowDeactivate: false
        backgroundHints: PlasmaCore.Dialog.NoBackground

        mainItem:  Rectangle{
            width: main.sizeImage*.85
            height: width
            color: 'transparent'
            Rectangle {
                id: mask
                width: parent.width
                height: parent.height
                visible: false
                radius: height/2
            }
            Image {
                id: iconUser
                source: kuser.faceIconUrl
                cache: false
                visible: source !== "" && Plasmoid.configuration.viewUser
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
                layer.enabled:true
                state: "hide"
                states: [
                    State {
                        name: "show"
                        when: dialog.visible
                        PropertyChanges { target: iconUser; y: 0; opacity: 1; }
                    },
                    State {
                        name: "hide"
                        when: !dialog.visible
                        PropertyChanges { target: iconUser; y: sizeImage/3 ; opacity: 0; }
                    }
                ]
                transitions: Transition {
                    PropertyAnimation { properties: "opacity,y"; easing.type: Easing.InOutQuad; }
                }

                layer.effect: OpacityMask {
                    maskSource: mask
                }
                MenuButton {
                    anchors.fill: parent
                    iconOnly: true
                    text: i18n("User account")
                    onClicked: KCM.KCMLauncher.openSystemSettings("kcm_users")
                }
            }
        }
    }
}
