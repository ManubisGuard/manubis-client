import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Manubis"
import "../Controls2"
import PageEnum 1.0

PageType {
    id: root
    objectName: "PageManubisImportSubscription"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true
    property string errorText: ""

    Rectangle { anchors.fill: parent; color: ManubisTheme.background }
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 22; anchors.rightMargin: 22
        anchors.topMargin: 20 + PageController.safeAreaTopMargin
        anchors.bottomMargin: 22 + PageController.safeAreaBottomMargin
        spacing: 16
        RowLayout {
            Layout.fillWidth: true
            Button { id: backButton; text: "‹"; onClicked: PageController.goToPage(PageEnum.PageManubisHome); background: Rectangle { radius: 12; color: ManubisTheme.surfaceRaised }
                contentItem: Text { text: backButton.text; color: ManubisTheme.textPrimary; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter } }
            Text { Layout.fillWidth: true; text: qsTr("Add connection"); color: ManubisTheme.textPrimary; font.pixelSize: 22; font.bold: true }
        }
        Text { Layout.fillWidth: true; text: qsTr("Import a supported VPN key or configuration. Subscription URL support will be connected through the Manubis API after its contract is verified."); color: ManubisTheme.textSecondary; font.pixelSize: 13; wrapMode: Text.Wrap; lineHeight: 1.2 }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 210; radius: 20; color: ManubisTheme.surface; border.color: ManubisTheme.border; border.width: 1
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 14; spacing: 10
                Text { text: qsTr("CONNECTION KEY / CONFIG"); color: ManubisTheme.textMuted; font.pixelSize: 10; font.letterSpacing: 1 }
                TextArea {
                    id: configInput
                    Layout.fillWidth: true; Layout.fillHeight: true
                    placeholderText: qsTr("Paste your supported VPN key or configuration here…")
                    color: ManubisTheme.textPrimary; placeholderTextColor: ManubisTheme.textMuted
                    wrapMode: TextEdit.Wrap; selectByMouse: true
                    background: Rectangle { radius: 12; color: "#09111E"; border.color: "#23354E" }
                }
            }
        }
        Rectangle {
            visible: root.errorText !== ""
            Layout.fillWidth: true; Layout.preferredHeight: errorLabel.implicitHeight + 24; radius: 14; color: "#321A2A"; border.color: "#6A3048"
            Text { id: errorLabel; anchors.fill: parent; anchors.margins: 12; text: root.errorText; color: "#FF9AAF"; font.pixelSize: 12; wrapMode: Text.Wrap }
        }
        Item { Layout.fillHeight: true }
        Button {
            id: validateButton
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            enabled: configInput.text.trim().length > 0
            background: Rectangle { radius: 17; color: validateButton.enabled ? ManubisTheme.cyan : "#263751" }
            contentItem: Text { text: qsTr("Validate and continue"); color: validateButton.enabled ? "#071321" : ManubisTheme.textMuted; font.pixelSize: 14; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: {
                root.errorText = ""
                if (ImportController.extractConfigFromData(configInput.text.trim())) {
                    PageController.goToPage(PageEnum.PageManubisImportReview)
                }
            }
        }
        Connections {
            target: ImportController
            function onImportErrorOccurred(errorCode, goToPageHome) {
                root.errorText = qsTr("This key or configuration could not be imported. Check the content and try again.")
            }
        }
    }
}
