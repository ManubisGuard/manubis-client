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
                    Text { text: qsTr("ManubisGuard Store"); color: ManubisTheme.textPrimary; font.pixelSize: 15; font.bold: true }
                    Text {
                        Layout.fillWidth: true
                        text: qsTr("The store connection is managed centrally by ManubisGuard. Store plans and public settings are loaded securely from the official service.")
                        color: ManubisTheme.textMuted; font.pixelSize: 12; wrapMode: Text.Wrap
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
