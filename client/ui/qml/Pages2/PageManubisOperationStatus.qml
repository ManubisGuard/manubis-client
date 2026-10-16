import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PageEnum 1.0
import "./"
import "../Controls2"
import "../Manubis"

PageType {
    id: root
    objectName: "PageManubisOperationStatus"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true

    property bool serverBusy: false
    property real progressValue: 0.08
    property string statusMessage: qsTr("The VPN operation is running. Keep the app open while it completes.")

    function finishOperation(message) {
        PageController.showBusyIndicator(false)
        if (message && message.length > 0)
            PageController.showNotificationMessage(message)
        PageController.goToPage(PageEnum.PageManubisHome, false)
    }

    function failOperation(message) {
        PageController.showBusyIndicator(false)
        PageController.showErrorMessage(message && message.length > 0 ? message : qsTr("The operation could not be completed."))
        PageController.goToPage(PageEnum.PageManubisHome, false)
    }

    Rectangle { anchors.fill: parent; color: ManubisTheme.background }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 24; anchors.rightMargin: 24
        anchors.topMargin: 22 + PageController.safeAreaTopMargin
        anchors.bottomMargin: 22 + PageController.safeAreaBottomMargin
        spacing: 18

        RowLayout {
            Layout.fillWidth: true
            Button {
                id: backButton
                text: "‹"
                onClicked: PageController.goToPage(PageEnum.PageManubisHome, false)
                background: Rectangle { radius: 12; color: ManubisTheme.surfaceRaised }
                contentItem: Text { text: backButton.text; color: ManubisTheme.textPrimary; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            Text { Layout.fillWidth: true; text: qsTr("VPN operation"); color: ManubisTheme.textPrimary; font.pixelSize: 22; font.bold: true }
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 94; height: 94; radius: 30
            color: "#102B40"; border.color: ManubisTheme.cyan
            Text { anchors.centerIn: parent; text: "◌"; color: ManubisTheme.cyan; font.pixelSize: 54 }
        }

        Text {
            Layout.fillWidth: true
            text: root.serverBusy ? qsTr("Waiting for the server") : qsTr("Working on your VPN")
            color: ManubisTheme.textPrimary; font.pixelSize: 21; font.bold: true
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
        }

        Text {
            Layout.fillWidth: true
            text: root.serverBusy ? qsTr("Another server task is running. This operation will wait until it finishes.") : root.statusMessage
            color: ManubisTheme.textSecondary; font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap
        }

        ProgressBar {
            Layout.fillWidth: true
            from: 0; to: 1; value: root.progressValue
            background: Rectangle { implicitHeight: 7; radius: 4; color: ManubisTheme.surfaceRaised }
            contentItem: Item {
                implicitHeight: 7
                Rectangle { width: parent.width * root.progressValue; height: parent.height; radius: 4; color: ManubisTheme.cyan }
            }
        }

        Button {
            visible: root.serverBusy
            Layout.fillWidth: true; Layout.preferredHeight: 48
            text: qsTr("Cancel operation")
            onClicked: { InstallController.cancelInstallation(); PageController.showBusyIndicator(true) }
            background: Rectangle { radius: 14; color: ManubisTheme.surfaceRaised; border.color: ManubisTheme.border }
            contentItem: Text { text: parent.text; color: ManubisTheme.textPrimary; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        }

        Item { Layout.fillHeight: true }
    }

    Timer {
        interval: 250; repeat: true; running: !root.serverBusy
        onTriggered: root.progressValue = root.progressValue >= 0.9 ? 0.08 : root.progressValue + 0.018
    }

    Connections {
        target: InstallController
        function onInstallContainerFinished(finishedMessage, isServiceInstall) { root.finishOperation(finishedMessage) }
        function onInstallServerFinished(finishedMessage) { root.finishOperation(finishedMessage) }
        function onServerIsBusy(isBusy) { root.serverBusy = isBusy }
        function onServerAlreadyExists(serverIndex) { root.failOperation(qsTr("This server has already been added.")) }
    }
}
