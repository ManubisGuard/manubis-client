import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Manubis"
import "../Controls2"
import PageEnum 1.0

PageType {
    id: root
    objectName: "PageManubisImportReview"
    property bool showConfig: false
    property bool importing: false

    Rectangle { anchors.fill: parent; color: ManubisTheme.background }
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 22; anchors.rightMargin: 22
        anchors.topMargin: 20 + PageController.safeAreaTopMargin
        anchors.bottomMargin: 20 + PageController.safeAreaBottomMargin
        spacing: 14
        RowLayout {
            Layout.fillWidth: true
            Button { id: backButton; text: "‹"; onClicked: PageController.goToPage(PageEnum.PageManubisImportSubscription); background: Rectangle { radius: 12; color: ManubisTheme.surfaceRaised }
                contentItem: Text { text: backButton.text; color: ManubisTheme.textPrimary; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter } }
            Text { Layout.fillWidth: true; text: qsTr("Review connection"); color: ManubisTheme.textPrimary; font.pixelSize: 22; font.bold: true }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 100; radius: 20; color: ManubisTheme.surface; border.color: ManubisTheme.border
            RowLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 12
                Rectangle { Layout.preferredWidth: 46; Layout.preferredHeight: 46; radius: 15; color: "#1B3149"; Text { anchors.centerIn: parent; text: "◇"; color: ManubisTheme.cyan; font.pixelSize: 26 } }
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    Text { text: qsTr("Configuration parsed"); color: ManubisTheme.textPrimary; font.pixelSize: 15; font.bold: true }
                    Text { Layout.fillWidth: true; text: ImportController.getConfigFileName() !== "" ? ImportController.getConfigFileName() : qsTr("Imported VPN configuration"); color: ManubisTheme.textSecondary; font.pixelSize: 12; wrapMode: Text.Wrap }
                }
            }
        }
        Text { Layout.fillWidth: true; text: qsTr("Only use connection details from a source you trust."); color: ManubisTheme.textSecondary; font.pixelSize: 12; wrapMode: Text.Wrap }
        Button {
            id: toggleConfigButton
            Layout.fillWidth: true
            text: root.showConfig ? qsTr("Hide configuration details") : qsTr("Show configuration details")
            background: Rectangle { radius: 14; color: ManubisTheme.surfaceRaised; border.color: ManubisTheme.border }
            contentItem: Text { text: toggleConfigButton.text; color: ManubisTheme.cyan; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: root.showConfig = !root.showConfig
        }
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 80
            visible: root.showConfig; radius: 16; color: "#09111E"; border.color: ManubisTheme.border
            Flickable {
                anchors.fill: parent; anchors.margins: 12; contentWidth: width; contentHeight: configText.implicitHeight; clip: true
                Text { id: configText; width: parent.width; text: ImportController.getConfig(); color: ManubisTheme.textSecondary; font.pixelSize: 11; wrapMode: Text.WrapAnywhere }
            }
        }
        Rectangle {
            visible: ImportController.maliciousWarningText !== ""
            Layout.fillWidth: true; Layout.preferredHeight: warningText.implicitHeight + 24; radius: 14; color: "#321A2A"; border.color: "#6A3048"
            Text { id: warningText; anchors.fill: parent; anchors.margins: 12; text: ImportController.maliciousWarningText; color: "#FF9AAF"; font.pixelSize: 12; wrapMode: Text.Wrap }
        }
        Item { Layout.fillHeight: true }
        Button {
            id: saveButton
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            enabled: !root.importing
            background: Rectangle { radius: 17; color: saveButton.enabled ? ManubisTheme.cyan : "#263751" }
            contentItem: Text { text: root.importing ? qsTr("Importing…") : qsTr("Save connection"); color: saveButton.enabled ? "#071321" : ManubisTheme.textMuted; font.pixelSize: 14; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: { root.importing = true; PageController.showBusyIndicator(true); ImportController.importConfig() }
        }
        Connections {
            target: ImportController
            function onImportFinished() { root.importing = false; PageController.showBusyIndicator(false); PageController.goToPage(PageEnum.PageManubisHome, false) }
            function onImportErrorOccurred(errorCode, goToPageHome) { root.importing = false; PageController.showBusyIndicator(false) }
        }
    }
}
