import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../Manubis"
import "../Controls2"
import PageEnum 1.0

PageType {
    id: root
    objectName: "PageManubisImportSubscription"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true
    property string errorText: ""
    function uiText(fa, en) { return LanguageUiController.currentLanguageIndex === 4 ? fa : en }

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
            Text { Layout.fillWidth: true; text: root.uiText("افزودن اتصال", "Add connection"); color: ManubisTheme.textPrimary; font.pixelSize: 22; font.bold: true }
        }
        Text { Layout.fillWidth: true; text: root.uiText("فایل یا کلید اتصال VPN پشتیبانی‌شده را وارد کن. پشتیبانی از لینک اشتراک پس از نهایی‌شدن قرارداد API اضافه می‌شود.", "Import a supported VPN key or configuration. Subscription URL support will be added after the API contract is finalized."); color: ManubisTheme.textSecondary; font.pixelSize: 13; wrapMode: Text.Wrap; lineHeight: 1.2 }
        Button {
            id: chooseConfigFileButton
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            text: root.uiText("بارگذاری فایل کانفیگ (WireGuard / AWG)", "Load configuration file (WireGuard / AmneziaWG)")
            background: Rectangle { radius: 14; color: ManubisTheme.surfaceRaised; border.color: ManubisTheme.border }
            contentItem: Text { text: chooseConfigFileButton.text; color: ManubisTheme.cyan; font.pixelSize: 13; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            onClicked: {
                var fileName = SystemController.getFileName(root.uiText("انتخاب فایل کانفیگ", "Choose configuration file"), "Config files (*.conf *.wg *.awg *.vpn *.ovpn *.json *.txt);;All files (*)")
                if (fileName !== "" && ImportController.extractConfigFromFile(fileName)) {
                    root.errorText = ""
                    PageController.goToPage(PageEnum.PageManubisImportReview)
                }
            }
        }
        Text { Layout.fillWidth: true; text: root.uiText("یا کانفیگ را در کادر زیر وارد کن:", "Or paste the configuration below:"); color: ManubisTheme.textMuted; font.pixelSize: 12; wrapMode: Text.Wrap }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 210; radius: 20; color: ManubisTheme.surface; border.color: ManubisTheme.border; border.width: 1
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 14; spacing: 10
                Text { text: root.uiText("کلید اتصال / کانفیگ", "CONNECTION KEY / CONFIG"); color: ManubisTheme.textMuted; font.pixelSize: 10; font.letterSpacing: 1 }
                TextArea {
                    id: configInput
                    Layout.fillWidth: true; Layout.fillHeight: true
                    placeholderText: root.uiText("کلید یا کانفیگ VPN را اینجا وارد کن…", "Paste your supported VPN key or configuration here…")
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
            contentItem: Text { text: root.uiText("بررسی و ادامه", "Validate and continue"); color: validateButton.enabled ? "#071321" : ManubisTheme.textMuted; font.pixelSize: 14; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
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
                root.errorText = root.uiText("این کلید یا کانفیگ وارد نشد. محتوا را بررسی و دوباره تلاش کن.", "This key or configuration could not be imported. Check the content and try again.")
            }
        }
    }
}
