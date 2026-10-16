import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PageEnum 1.0
import "../Controls2"

PageType {
    id: root
    objectName: "PageManubisDashboard"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true

    property color ink: "#F4F8FF"
    property color muted: "#91A3BC"
    property color panel: "#111B2D"
    property color line: "#263650"
    property color cyan: "#42D9F5"
    property color blue: "#477BFF"

    function openVpn() {
        if (ServersUiController.getServersCount() > 0) {
            PageController.goToPage(PageEnum.PageManubisHome)
        } else {
            PageController.goToPage(PageEnum.PageManubisImportSubscription)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#080E19"
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: body.implicitHeight + 30
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: body
            width: parent.width
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 22
                Layout.rightMargin: 22
                Layout.topMargin: 24
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 44; Layout.preferredHeight: 44; radius: 14
                    color: "#102D42"
                    border.color: "#24566D"
                    Text {
                        anchors.centerIn: parent
                        text: "M"
                        color: cyan
                        font.pixelSize: 25
                        font.bold: true
                    }
                }
                ColumnLayout {
                    spacing: 1
                    Text { text: "MANUBIS GUARD"; color: ink; font.pixelSize: 17; font.bold: true }
                    Text { text: "SECURE CONNECTION"; color: muted; font.pixelSize: 9; font.letterSpacing: 2 }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    radius: 10; color: ConnectionController.isConnected ? "#10291F" : "#292219"; border.color: ConnectionController.isConnected ? "#205A43" : "#6A4B2A"
                    Layout.preferredWidth: 84; Layout.preferredHeight: 30
                    Row {
                        anchors.centerIn: parent; spacing: 6
                        Rectangle { width: 6; height: 6; radius: 3; color: ConnectionController.isConnected ? "#42D99A" : "#F6B95B"; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: ConnectionController.isConnected ? "متصل" : "قطع"; color: ConnectionController.isConnected ? "#8EE9BD" : "#FFD58A"; font.pixelSize: 11 }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 22
                Layout.rightMargin: 22
                spacing: 5
                Text { text: "سلام، خوش اومدی"; color: ink; font.pixelSize: 25; font.bold: true }
                Text {
                    text: "اتصال امن خودت رو از یک جا مدیریت کن."
                    color: muted; font.pixelSize: 13
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.preferredHeight: 218
                radius: 24
                color: "#101F34"
                border.color: "#284966"
                clip: true

                Rectangle {
                    width: 170; height: 170; radius: 85
                    x: parent.width - 105; y: -75
                    color: "#153D55"; opacity: 0.65
                }
                Rectangle {
                    width: 115; height: 115; radius: 58
                    x: parent.width - 80; y: -45
                    color: "#1B5267"; opacity: 0.45
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 9
                    RowLayout {
                        spacing: 7
                        Rectangle { Layout.preferredWidth: 8; Layout.preferredHeight: 8; radius: 4; color: ConnectionController.isConnected ? "#42D99A" : "#F6B95B" }
                        Text {
                            text: ConnectionController.isConnected ? "اتصال برقرار است" : ConnectionController.isConnectionInProgress ? ConnectionController.connectionStateText : "آماده اتصال"
                            color: ConnectionController.isConnected ? "#8EE9BD" : "#FFD58A"
                            font.pixelSize: 12; font.bold: true
                        }
                    }
                    Text {
                        text: ConnectionController.isConnected ? "اتصال شما فعاله" : ConnectionController.isConnectionInProgress ? ConnectionController.connectionStateText : "اینترنتت رو امن‌تر کن"
                        color: ink; font.pixelSize: 23; font.bold: true
                        Layout.fillWidth: true
                    }
                    Text {
                        text: ConnectionController.isConnected
                              ? "وضعیت اتصال را از بخش VPN مدیریت کن."
                              : "به سرویس خودت وصل شو یا یک اشتراک وارد کن."
                        color: "#AFC0D5"; font.pixelSize: 12
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    Item { Layout.fillHeight: true }
                    Button {
                        id: connectDashboardButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        text: ConnectionController.isConnected ? "مدیریت اتصال" : "اتصال / افزودن اشتراک"
                        onClicked: root.openVpn()
                        background: Rectangle {
                            radius: 14
                            color: "#42D9F5"
                        }
                        contentItem: Text {
                            text: connectDashboardButton.text
                            color: "#071321"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 105
                    radius: 18; color: panel; border.color: line
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 8
                        Text { text: "◈"; color: cyan; font.pixelSize: 21 }
                        Text { text: "اشتراک من"; color: ink; font.pixelSize: 13; font.bold: true }
                        Text { text: "اطلاعات اشتراک هنوز به API متصل نیست"; color: muted; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 105
                    radius: 18; color: panel; border.color: line
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 8
                        Text { text: "✦"; color: "#9D9BFF"; font.pixelSize: 21 }
                        Text { text: "فروشگاه"; color: ink; font.pixelSize: 13; font.bold: true }
                        Text { text: "پلن‌ها و تمدید"; color: muted; font.pixelSize: 10 }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: PageController.goToPage(PageEnum.PageManubisStore)
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.preferredHeight: 76
                radius: 16; color: "#0D1727"; border.color: "#21344D"
                RowLayout {
                    anchors.fill: parent; anchors.margins: 15; spacing: 12
                    Rectangle {
                        Layout.preferredWidth: 40; Layout.preferredHeight: 40; radius: 12; color: "#162D47"
                        Text { anchors.centerIn: parent; text: "↻"; color: cyan; font.pixelSize: 24 }
                    }
                    ColumnLayout {
                        spacing: 3
                        Text { text: "تمدید یا خرید سرویس"; color: ink; font.pixelSize: 13; font.bold: true }
                        Text { text: "پلن مناسب خودت رو پیدا کن"; color: muted; font.pixelSize: 11 }
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        id: storeDashboardButton
                        text: "مشاهده"
                        onClicked: PageController.goToPage(PageEnum.PageManubisStore)
                        background: Rectangle { radius: 10; color: "#183B51"; border.color: "#28647B" }
                        contentItem: Text { text: storeDashboardButton.text; color: cyan; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            Item { Layout.preferredHeight: 10 }
        }
    }
}
