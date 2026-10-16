import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PageEnum 1.0
import "../Manubis"
import "../Controls2"

PageType {
    id: root
    objectName: "PageManubisSettings"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true

    function saveApiAddress() {
        var value = apiAddress.text.trim().replace(/\/+$/, "")
        if (!value.startsWith("https://") || /\s/.test(value)) {
            apiError.text = qsTr("Enter a valid HTTPS API base address.")
            apiError.visible = true
            return
        }
        ManubisPreferences.storeApiBaseUrl = value
        apiAddress.text = value
        apiError.visible = false
        PageController.showNotificationMessage(qsTr("Store API address saved on this device."))
    }

    Rectangle { anchors.fill: parent; color: ManubisTheme.background }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: body.implicitHeight + 36
        clip: true
        ColumnLayout {
            id: body
            width: parent.width
            anchors.leftMargin: 22
            anchors.rightMargin: 22
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 22
                Layout.rightMargin: 22
                Layout.topMargin: 20 + PageController.safeAreaTopMargin
                Button {
                    id: backButton
                    text: "‹"
                    onClicked: PageController.goToPage(PageEnum.PageManubisHome)
                    background: Rectangle { radius: 12; color: ManubisTheme.surfaceRaised }
                    contentItem: Text { text: backButton.text; color: ManubisTheme.textPrimary; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter }
                }
                Text { Layout.fillWidth: true; text: qsTr("VPN settings"); color: ManubisTheme.textPrimary; font.pixelSize: 22; font.bold: true }
            }

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 22; Layout.rightMargin: 22
                text: qsTr("Essential controls and service connection settings.")
                color: ManubisTheme.textSecondary; font.pixelSize: 13; wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 82; radius: 18; color: ManubisTheme.surface; border.color: ManubisTheme.border
                RowLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 12
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 4
                        Text { text: qsTr("Application language"); color: ManubisTheme.textPrimary; font.pixelSize: 14 }
                        Text { text: LanguageUiController.currentLanguageName; color: ManubisTheme.textMuted; font.pixelSize: 12 }
                    }
                    Text { text: "›"; color: ManubisTheme.cyan; font.pixelSize: 25 }
                }
                MouseArea { anchors.fill: parent; onClicked: { ManubisPreferences.languageChosen = false; PageController.goToPage(PageEnum.PageManubisLanguage) } }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                implicitHeight: apiColumn.implicitHeight + 32
                radius: 18; color: ManubisTheme.surface; border.color: ManubisTheme.border
                ColumnLayout {
                    id: apiColumn
                    anchors.fill: parent; anchors.margins: 16; spacing: 10
                    Text { text: qsTr("Store API address"); color: ManubisTheme.textPrimary; font.pixelSize: 15; font.bold: true }
                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Change the API base address used to load the store catalogue. This setting is saved on this device.")
                        color: ManubisTheme.textMuted; font.pixelSize: 12; wrapMode: Text.Wrap
                    }
                    TextField {
                        id: apiAddress
                        Layout.fillWidth: true
                        text: ManubisPreferences.storeApiBaseUrl
                        placeholderText: "https://example.com/store-api"
                        inputMethodHints: Qt.ImhUrlCharactersOnly
                        selectByMouse: true
                        color: ManubisTheme.textPrimary
                        background: Rectangle { radius: 10; color: "#091321"; border.color: ManubisTheme.border }
                    }
                    Text {
                        id: apiError
                        visible: false
                        Layout.fillWidth: true
                        color: "#FF9AAF"; font.pixelSize: 12; wrapMode: Text.Wrap
                    }
                    Button {
                        id: saveApiButton
                        Layout.fillWidth: true; Layout.preferredHeight: 44
                        text: qsTr("Save API address")
                        onClicked: root.saveApiAddress()
                        background: Rectangle { radius: 12; color: ManubisTheme.cyan }
                        contentItem: Text { text: saveApiButton.text; color: "#071321"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Button {
                        id: openStoreButton
                        Layout.fillWidth: true; Layout.preferredHeight: 42
                        text: qsTr("Open store")
                        onClicked: PageController.goToPage(PageEnum.PageManubisStore)
                        background: Rectangle { radius: 12; color: ManubisTheme.surfaceRaised; border.color: ManubisTheme.border }
                        contentItem: Text { text: openStoreButton.text; color: ManubisTheme.cyan; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 82; radius: 18; color: ManubisTheme.surface; border.color: ManubisTheme.border
                RowLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 12
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 4
                        Text { text: qsTr("Connection diagnostics"); color: ManubisTheme.textPrimary; font.pixelSize: 14 }
                        Text { text: ConnectionController.connectionStateText; color: ManubisTheme.textMuted; font.pixelSize: 12; wrapMode: Text.Wrap }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 78; radius: 18; color: ManubisTheme.surface; border.color: ManubisTheme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 4
                    Text { text: qsTr("Advanced VPN controls"); color: ManubisTheme.textPrimary; font.pixelSize: 14 }
                    Text { Layout.fillWidth: true; text: qsTr("Routing and split-tunneling controls remain available in the verified VPN engine settings."); color: ManubisTheme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap }
                }
            }

            Text {
                Layout.fillWidth: true; Layout.topMargin: 6; Layout.bottomMargin: 10
                text: "MANUBIS GUARD  ·  Android"
                color: ManubisTheme.textMuted; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
