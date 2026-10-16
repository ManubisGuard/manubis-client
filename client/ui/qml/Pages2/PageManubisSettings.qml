import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import PageEnum 1.0
import "../Manubis"
import "../Controls2"

PageType {
    id: root
    objectName: "PageManubisSettings"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true
    Settings { id: prefs; category: "ManubisGuard"; property bool languageChosen: false }

    Rectangle { anchors.fill: parent; color: ManubisTheme.background }
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 22; anchors.rightMargin: 22
        anchors.topMargin: 20 + PageController.safeAreaTopMargin
        anchors.bottomMargin: 20 + PageController.safeAreaBottomMargin
        spacing: 14
        RowLayout {
            Layout.fillWidth: true
            Button { id: backButton; text: "‹"; onClicked: PageController.goToPage(PageEnum.PageManubisHome); background: Rectangle { radius: 12; color: ManubisTheme.surfaceRaised }
                contentItem: Text { text: backButton.text; color: ManubisTheme.textPrimary; font.pixelSize: 24; horizontalAlignment: Text.AlignHCenter } }
            Text { Layout.fillWidth: true; text: qsTr("VPN settings"); color: ManubisTheme.textPrimary; font.pixelSize: 22; font.bold: true }
        }
        Text { Layout.fillWidth: true; text: qsTr("Essential controls, without the clutter."); color: ManubisTheme.textSecondary; font.pixelSize: 13; wrapMode: Text.Wrap }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 82; radius: 18; color: ManubisTheme.surface; border.color: ManubisTheme.border
            RowLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    Text { text: qsTr("Application language"); color: ManubisTheme.textPrimary; font.pixelSize: 14 }
                    Text { text: LanguageUiController.currentLanguageName; color: ManubisTheme.textMuted; font.pixelSize: 12 }
                }
                Text { text: "›"; color: ManubisTheme.cyan; font.pixelSize: 25 }
            }
            MouseArea { anchors.fill: parent; onClicked: { prefs.languageChosen = false; PageController.goToPage(PageEnum.PageManubisLanguage) } }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 82; radius: 18; color: ManubisTheme.surface; border.color: ManubisTheme.border
            RowLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    Text { text: qsTr("Connection diagnostics"); color: ManubisTheme.textPrimary; font.pixelSize: 14 }
                    Text { text: ConnectionController.connectionStateText; color: ManubisTheme.textMuted; font.pixelSize: 12 }
                }
                Text { text: "›"; color: ManubisTheme.cyan; font.pixelSize: 25 }
            }
            MouseArea { anchors.fill: parent; onClicked: PageController.showNotificationMessage(qsTr("Detailed diagnostics are not yet connected to the new settings screen.")) }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 82; radius: 18; color: ManubisTheme.surface; border.color: ManubisTheme.border
            RowLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    Text { text: qsTr("Routing and split tunneling"); color: ManubisTheme.textPrimary; font.pixelSize: 14 }
                    Text { text: qsTr("Advanced controls are being verified against the VPN engine."); color: ManubisTheme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap; Layout.fillWidth: true }
                }
            }
        }
        Item { Layout.fillHeight: true }
        Text { Layout.fillWidth: true; text: "MANUBIS GUARD  ·  Android"; color: ManubisTheme.textMuted; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter }
    }
}
