import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import PageEnum 1.0
import "../Manubis"
import "../Controls2"

PageType {
    id: root
    objectName: "PageManubisHome"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true

    property bool locationPickerOpen: false
    readonly property bool connected: ConnectionController.isConnected
    readonly property bool busy: ConnectionController.isConnectionInProgress

    function openMainPage(page) {
        menuDrawer.close()
        PageController.goToPage(page)
    }

    Rectangle {
        anchors.fill: parent
        color: ManubisTheme.background
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0D1729" }
            GradientStop { position: 0.52; color: ManubisTheme.background }
            GradientStop { position: 1.0; color: "#0B1020" }
        }
    }

    Rectangle {
        width: 300; height: 300; radius: 150
        x: root.width * 0.5 - width * 0.5; y: root.height * 0.19 - height * 0.5
        color: root.connected ? "#164C4A" : "#173E70"
        opacity: root.connected ? 0.18 : 0.14
        Behavior on opacity { NumberAnimation { duration: 350 } }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 22
        anchors.rightMargin: 22
        anchors.topMargin: 16 + PageController.safeAreaTopMargin
        anchors.bottomMargin: 14 + PageController.safeAreaBottomMargin
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            spacing: 12

            Button {
                Layout.preferredWidth: 44; Layout.preferredHeight: 44
                padding: 0
                background: Rectangle { radius: 15; color: "#142238"; border.color: ManubisTheme.border; border.width: 1 }
                contentItem: Text { text: "☰"; color: ManubisTheme.textPrimary; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                Accessible.name: qsTr("Open menu")
                onClicked: menuDrawer.open()
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text { text: "MANUBIS GUARD"; color: ManubisTheme.textPrimary; font.pixelSize: 15; font.weight: Font.DemiBold; font.letterSpacing: 1.2 }
                Text { text: qsTr("SECURE CONNECTION") ; color: ManubisTheme.textMuted; font.pixelSize: 9; font.letterSpacing: 1.6 }
            }

            Rectangle {
                Layout.preferredWidth: 42; Layout.preferredHeight: 42; radius: 14
                color: "#132238"; border.color: ManubisTheme.border; border.width: 1
                Text { anchors.centerIn: parent; text: "◈"; color: ManubisTheme.cyan; font.pixelSize: 23 }
            }
        }

        Item { Layout.fillHeight: true; Layout.minimumHeight: 12 }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 9
            Text {
                Layout.fillWidth: true
                text: root.connected ? qsTr("You are protected") : root.busy ? qsTr("Securing connection") : qsTr("Your private space")
                color: ManubisTheme.textPrimary
                font.pixelSize: 25
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: root.connected ? qsTr("Your VPN connection is active") : root.busy ? ConnectionController.connectionStateText : qsTr("One tap to connect securely")
                color: ManubisTheme.textSecondary
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Item { Layout.fillHeight: true; Layout.minimumHeight: 16 }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(root.width - 80, 236)
            Layout.preferredHeight: Math.min(root.width - 80, 236)

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: width / 2
                color: "#0E1A2D"
                border.width: 1
                border.color: root.connected ? "#3CCCA7" : "#274C71"
                opacity: 0.95
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 17
                radius: width / 2
                color: "#12233A"
                border.width: 1
                border.color: root.connected ? "#2C9D8C" : "#31527D"
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.61
                height: width
                radius: width / 2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.connected ? "#39D9B0" : "#5ADFF1" }
                    GradientStop { position: 1.0; color: root.connected ? "#1C9D91" : "#647EFF" }
                }
                opacity: root.busy ? 0.74 : 1.0
                border.color: "#9CEFF6"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 5
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.busy ? "⋯" : root.connected ? "✓" : "↗"
                        color: "#071321"
                        font.pixelSize: 39
                        font.weight: Font.Light
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.busy ? qsTr("WAIT") : root.connected ? qsTr("CONNECTED") : qsTr("CONNECT")
                        color: "#071321"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 1.3
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: true
                onClicked: {
                    if (ServersUiController.getServersCount() === 0) {
                        PageController.goToPage(PageEnum.PageManubisImportSubscription)
                        return
                    }
                    ConnectionController.connectButtonClicked()
                }
                cursorShape: Qt.PointingHandCursor
            }

            RotationAnimator on rotation {
                running: root.busy
                from: 0; to: 360
                duration: 2600
                loops: Animation.Infinite
            }
        }

        Item { Layout.fillHeight: true; Layout.minimumHeight: 18 }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 84
            radius: 20
            color: "#101C2D"
            border.color: ManubisTheme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 14
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 42; Layout.preferredHeight: 42; radius: 14
                    color: "#1A2D45"
                    Text { anchors.centerIn: parent; text: "◎"; color: ManubisTheme.cyan; font.pixelSize: 24 }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: qsTr("CONNECTION LOCATION"); color: ManubisTheme.textMuted; font.pixelSize: 9; font.letterSpacing: 1.1 }
                    Text {
                        Layout.fillWidth: true
                        text: ServersUiController.getServersCount() > 0 ? ServersUiController.defaultServerName : qsTr("No location selected")
                        color: ManubisTheme.textPrimary
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                }

                Text { text: "›"; color: ManubisTheme.cyan; font.pixelSize: 27 }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (ServersUiController.getServersCount() === 0) {
                        PageController.goToPage(PageEnum.PageManubisImportSubscription)
                    } else {
                        locationDialog.open()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 12
            Layout.preferredHeight: 64
            radius: 18
            color: "#0C1524"
            border.color: "#1D2C42"
            border.width: 1
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12
                Rectangle { Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 11; color: "#17263B"; Text { anchors.centerIn: parent; text: "◌"; color: ManubisTheme.violet; font.pixelSize: 21 } }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    Text { text: qsTr("DATA USAGE"); color: ManubisTheme.textMuted; font.pixelSize: 9; font.letterSpacing: 0.8 }
                    Text { text: qsTr("Usage details unavailable"); color: ManubisTheme.textSecondary; font.pixelSize: 12 }
                }
                Text { text: "↗"; color: ManubisTheme.textMuted; font.pixelSize: 18 }
            }
            MouseArea { anchors.fill: parent; onClicked: root.openMainPage(PageEnum.PageManubisDashboard) }
        }

        Item { Layout.preferredHeight: 6 }
    }

    Dialog {
        id: locationDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(root.width - 32, 420)
        padding: 18
        modal: true
        title: qsTr("Choose connection")
        background: Rectangle { radius: 22; color: ManubisTheme.surface; border.color: ManubisTheme.border; border.width: 1 }
        contentItem: ColumnLayout {
            spacing: 10
            Text { Layout.fillWidth: true; text: qsTr("Saved VPN connections"); color: ManubisTheme.textSecondary; font.pixelSize: 12; wrapMode: Text.Wrap }
            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 280)
                clip: true
                model: ServersModel
                delegate: Button {
                    id: serverButton
                    required property string name
                    required property string serverId
                    required property bool isDefault
                    width: ListView.view.width
                    height: 58
                    background: Rectangle { radius: 13; color: serverButton.isDefault ? "#1A3048" : "#101B2B"; border.color: serverButton.isDefault ? ManubisTheme.cyan : ManubisTheme.border; border.width: 1 }
                    contentItem: RowLayout {
                        Text { text: "◉"; color: ManubisTheme.cyan; font.pixelSize: 18 }
                        Text { Layout.fillWidth: true; text: serverButton.name; color: ManubisTheme.textPrimary; font.pixelSize: 13; elide: Text.ElideRight }
                        Text { text: serverButton.isDefault ? "✓" : ""; color: ManubisTheme.connected; font.pixelSize: 17 }
                    }
                    onClicked: {
                        if (ConnectionController.isConnected || ConnectionController.isConnectionInProgress) {
                            PageController.showNotificationMessage(qsTr("Disconnect before changing location"))
                            return
                        }
                        ServersUiController.setDefaultServer(serverId)
                        locationDialog.close()
                    }
                }
            }
            Button {
                Layout.fillWidth: true
                text: qsTr("Add subscription")
                onClicked: { locationDialog.close(); PageController.goToPage(PageEnum.PageManubisImportSubscription) }
            }
        }
    }

    Drawer {
        id: menuDrawer
        edge: Qt.LeftEdge
        width: Math.min(root.width * 0.84, 340)
        height: root.height
        background: Rectangle { color: ManubisTheme.surface; border.color: ManubisTheme.border; border.width: 1 }
        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 28 + PageController.safeAreaTopMargin
            anchors.bottomMargin: 18 + PageController.safeAreaBottomMargin
            anchors.leftMargin: 18; anchors.rightMargin: 18
            spacing: 8
            RowLayout {
                Layout.fillWidth: true; Layout.bottomMargin: 24
                Rectangle { Layout.preferredWidth: 48; Layout.preferredHeight: 48; radius: 16; color: "#1A3048"; Text { anchors.centerIn: parent; text: "M"; color: ManubisTheme.cyan; font.pixelSize: 25; font.bold: true } }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 3
                    Text { text: "MANUBIS GUARD"; color: ManubisTheme.textPrimary; font.pixelSize: 14; font.bold: true; font.letterSpacing: 1 }
                    Text { text: qsTr("Secure access, simplified"); color: ManubisTheme.textMuted; font.pixelSize: 11 }
                }
            }
            Repeater {
                model: [
                    { "label": qsTr("Home"), "icon": "⌂", "page": PageEnum.PageManubisHome },
                    { "label": qsTr("Usage dashboard"), "icon": "◷", "page": PageEnum.PageManubisDashboard },
                    { "label": qsTr("Store"), "icon": "◇", "page": PageEnum.PageManubisStore },
                    { "label": qsTr("My account"), "icon": "○", "page": PageEnum.PageManubisAccount },
                    { "label": qsTr("Add connection"), "icon": "+", "page": PageEnum.PageManubisImportSubscription },
                    { "label": qsTr("VPN settings"), "icon": "⚙", "page": PageEnum.PageManubisSettings }
                ]
                delegate: Button {
                    id: menuItemButton
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    background: Rectangle { radius: 14; color: menuItemButton.down ? "#213752" : "transparent" }
                    contentItem: RowLayout {
                        spacing: 14
                        Text { text: modelData.icon; color: ManubisTheme.cyan; font.pixelSize: 22; Layout.preferredWidth: 26; horizontalAlignment: Text.AlignHCenter }
                        Text { Layout.fillWidth: true; text: modelData.label; color: ManubisTheme.textPrimary; font.pixelSize: 14 }
                        Text { text: "›"; color: ManubisTheme.textMuted; font.pixelSize: 21 }
                    }
                    onClicked: root.openMainPage(modelData.page)
                }
            }
            Item { Layout.fillHeight: true }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: ManubisTheme.border }
            Button {
                Layout.fillWidth: true; Layout.preferredHeight: 48
                background: Rectangle { radius: 14; color: "#101C2D" }
                contentItem: Text { text: qsTr("Language / Язык / زبان"); color: ManubisTheme.textSecondary; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: root.openMainPage(PageEnum.PageManubisLanguage)
            }
        }
    }

    Connections {
        target: ConnectionController
        function onNoInstalledContainers() { PageController.goToPage(PageEnum.PageManubisImportSubscription) }
        function onConnectionErrorOccurred(errorCode) { /* The shared application error handler displays the native error. */ }
    }
}
