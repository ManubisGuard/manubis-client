import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Manubis"
import "../Controls2"
import PageEnum 1.0

PageType {
    id: root
    objectName: "PageManubisImportReview"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true

    function uiText(fa, en) { return LanguageUiController.currentLanguageIndex === 4 ? fa : en }

    property bool showConfig: false
    property bool importing: false
    property string errorText: ""

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
            Text { Layout.fillWidth: true; text: root.uiText("بررسی اتصال", "Review connection"); color: ManubisTheme.textPrimary; font.pixelSize: 22; font.bold: true }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 100; radius: 20; color: ManubisTheme.surface; border.color: ManubisTheme.border
            RowLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 12
                Rectangle { Layout.preferredWidth: 46; Layout.preferredHeight: 46; radius: 15; color: "#1B3149"; Text { anchors.centerIn: parent; text: "◇"; color: ManubisTheme.cyan; font.pixelSize: 26 } }
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    Text { text: root.uiText("کانفیگ بررسی شد", "Configuration parsed"); color: ManubisTheme.textPrimary; font.pixelSize: 15; font.bold: true }
                    Text { Layout.fillWidth: true; text: ImportController.getConfigFileName() !== "" ? ImportController.getConfigFileName() : root.uiText("کانفیگ VPN واردشده", "Imported VPN configuration"); color: ManubisTheme.textSecondary; font.pixelSize: 12; wrapMode: Text.Wrap }
                }
            }
        }
        Text { Layout.fillWidth: true; text: root.uiText("فقط از اطلاعات اتصالی استفاده کن که منبع آن را می‌شناسی و به آن اعتماد داری.", "Only use connection details from a source you trust."); color: ManubisTheme.textSecondary; font.pixelSize: 12; wrapMode: Text.Wrap }
        Button {
            id: toggleConfigButton
            Layout.fillWidth: true
            text: root.showConfig ? root.uiText("پنهان‌کردن جزئیات کانفیگ", "Hide configuration details") : root.uiText("نمایش جزئیات کانفیگ", "Show configuration details")
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
        Rectangle {
            visible: root.errorText.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: errorLabel.implicitHeight + 24
            radius: 14; color: "#321A2A"; border.color: "#6A3048"
            Text { id: errorLabel; anchors.fill: parent; anchors.margins: 12; text: root.errorText; color: "#FF9AAF"; font.pixelSize: 12; wrapMode: Text.Wrap }
        }
        Item { Layout.fillHeight: true }
        Button {
            id: saveButton
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            enabled: !root.importing
            background: Rectangle { radius: 17; color: saveButton.enabled ? ManubisTheme.cyan : "#263751" }
            contentItem: Text { text: root.importing ? root.uiText("در حال واردکردن…", "Importing…") : root.uiText("ذخیره اتصال", "Save connection"); color: saveButton.enabled ? "#071321" : ManubisTheme.textMuted; font.pixelSize: 14; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: { root.errorText = ""; root.importing = true; PageController.showBusyIndicator(true); ImportController.importConfig() }
        }
        Connections {
            target: ImportController
            function onImportFinished() { root.importing = false; PageController.showBusyIndicator(false); PageController.goToPage(PageEnum.PageManubisHome, false) }
            function onImportErrorOccurred(errorCode, goToPageHome) { root.importing = false; PageController.showBusyIndicator(false); root.errorText = root.uiText("اتصال ذخیره نشد. کانفیگ را بررسی و دوباره تلاش کن.", "The connection could not be saved. Check the configuration and try again.") }
        }
    }
}
