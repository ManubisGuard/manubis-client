import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Controls2"
import PageEnum 1.0

PageType {
    id: root
    objectName: "PageManubisAccount"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true
    Rectangle { anchors.fill: parent; color: "#080E19" }
    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: body.implicitHeight + 30
        clip: true
        ColumnLayout {
            id: body
            width: parent.width
            spacing: 16
            Text {
                Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.topMargin: 26
                text: "حساب کاربری"; color: "#F4F8FF"; font.pixelSize: 26; font.bold: true
            }
            Text {
                Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.fillWidth: true
                text: "برای مدیریت اشتراک، خریدها و تمدیدها در یک جا وارد حساب شو. بدون حساب هم می‌تونی یک کانفیگ VPN پشتیبانی‌شده اضافه کنی."
                color: "#91A3BC"; font.pixelSize: 13; wrapMode: Text.Wrap
            }
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 270; radius: 20; color: "#111B2D"; border.color: "#2A3D59"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 18; spacing: 11
                    Text { text: "ورود / ساخت حساب"; color: "#F4F8FF"; font.pixelSize: 17; font.bold: true }
                    TextField { Layout.fillWidth: true; placeholderText: "ایمیل یا نام کاربری"; color: "#F4F8FF"; background: Rectangle { radius: 10; color: "#091321"; border.color: "#2B405C" } }
                    TextField { Layout.fillWidth: true; placeholderText: "رمز عبور"; echoMode: TextInput.Password; color: "#F4F8FF"; background: Rectangle { radius: 10; color: "#091321"; border.color: "#2B405C" } }
                    Button {
                        id: loginButton
                        Layout.fillWidth: true; Layout.preferredHeight: 44; text: "ورود"
                        enabled: false
                        background: Rectangle { radius: 12; color: "#42D9F5" }
                        contentItem: Text { text: loginButton.text; color: "#071321"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Text { text: "ورود و ساخت حساب تا اتصال API احراز هویت غیرفعال است."; color: "#FFD58A"; font.pixelSize: 11; wrapMode: Text.Wrap; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                }
            }
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 160; radius: 20; color: "#101F34"; border.color: "#284966"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 18; spacing: 10
                    Text { text: "ورود بدون حساب"; color: "#F4F8FF"; font.pixelSize: 16; font.bold: true }
                    Text { text: "یک کلید یا فایل کانفیگ VPN پشتیبانی‌شده را بدون ساخت حساب وارد کن."; color: "#91A3BC"; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    Button {
                        id: importSubscriptionButton
                        Layout.fillWidth: true; Layout.preferredHeight: 42; text: "افزودن کانفیگ"
                        onClicked: PageController.goToPage(PageEnum.PageManubisImportSubscription)
                        background: Rectangle { radius: 12; color: "#183B51"; border.color: "#28647B" }
                        contentItem: Text { text: importSubscriptionButton.text; color: "#42D9F5"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }
        }
    }
}
