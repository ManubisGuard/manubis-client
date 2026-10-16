pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Controls2"

PageType {
    id: root
    objectName: "PageManubisStore"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true

    property string apiBaseUrl: "https://all.qoqnusradio.top/store-api"
    property string statusMessage: "برای نمایش پلن‌های ثبت‌شده، آدرس API فروشگاه را وارد کن."
    property bool loading: false
    property bool requestFailed: false
    property var plans: []
    property string storeName: "Manubis Guard"
    property string storeDescription: "پلن‌های فعال از فروشگاه دریافت می‌شوند."
    property string supportUrl: ""
    property bool maintenanceMode: false

    function loadPlans() {
        var base = root.apiBaseUrl.trim().replace(/\/+$/, "")
        if (!base) {
            statusMessage = "آدرس API فروشگاه هنوز تنظیم نشده است."
            requestFailed = true
            return
        }
        if (!base.startsWith("https://")) {
            statusMessage = "برای امنیت، آدرس فروشگاه باید با HTTPS شروع شود."
            requestFailed = true
            return
        }
        loading = true
        requestFailed = false
        statusMessage = "در حال دریافت پلن‌ها…"
        var xhr = new XMLHttpRequest()
        xhr.open("GET", base + "/api/v1/store/plans")
        xhr.timeout = 12000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            loading = false
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    if (!Array.isArray(data))
                        throw new Error("invalid response")
                    plans = data
                    statusMessage = root.maintenanceMode ? "فروشگاه موقتاً در حالت تعمیر و نگهداری است." : (data.length ? data.length + " پلن فعال پیدا شد." : "هنوز پلن فعالی در فروشگاه ثبت نشده است.")
                    requestFailed = false
                } catch (e) {
                    statusMessage = "پاسخ API فروشگاه قابل‌خواندن نیست."
                    requestFailed = true
                    plans = []
                }
            } else {
                statusMessage = "دریافت پلن‌ها ناموفق بود (HTTP " + xhr.status + "). آدرس API را بررسی کن."
                requestFailed = true
                plans = []
            }
        }
        xhr.ontimeout = function() {
            loading = false; requestFailed = true
            statusMessage = "زمان اتصال به فروشگاه تمام شد."
        }
        xhr.onerror = function() {
            loading = false; requestFailed = true
            statusMessage = "اتصال به فروشگاه برقرار نشد. آدرس و دسترسی شبکه را بررسی کن."
        }
        xhr.send()
    }

    function loadStoreSettings() {
        var base = root.apiBaseUrl.trim().replace(/\/+$/, "")
        if (!base || !base.startsWith("https://")) return
        var xhr = new XMLHttpRequest()
        xhr.open("GET", base + "/api/v1/store/settings")
        xhr.timeout = 10000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status < 200 || xhr.status >= 300) return
            try {
                var settings = JSON.parse(xhr.responseText)
                if (typeof settings.store_name === "string" && settings.store_name.length) root.storeName = settings.store_name
                if (typeof settings.store_description === "string") root.storeDescription = settings.store_description
                if (typeof settings.support_url === "string" && settings.support_url.startsWith("https://")) root.supportUrl = settings.support_url
                root.maintenanceMode = settings.maintenance_mode === true
                if (root.maintenanceMode) root.statusMessage = "فروشگاه موقتاً در حالت تعمیر و نگهداری است."
            } catch (e) {
            }
        }
        xhr.send()
    }

    Component.onCompleted: {
        root.loadPlans()
        root.loadStoreSettings()
    }

    function formatBytes(bytes) {
        var b = Number(bytes)
        if (!b) return "بدون محدودیت حجمی"
        if (b >= 1073741824) return (b / 1073741824).toFixed(1) + " GB"
        if (b >= 1048576) return (b / 1048576).toFixed(0) + " MB"
        return b.toLocaleString() + " B"
    }
    function formatDuration(seconds) {
        var s = Number(seconds)
        var days = Math.floor(s / 86400)
        if (days >= 30 && days % 30 === 0) return (days / 30) + " ماه"
        if (days > 0) return days + " روز"
        return Math.max(1, Math.floor(s / 3600)) + " ساعت"
    }
    function formatPrice(amountMinor, currency) {
        var code = String(currency || "IRR").toUpperCase()
        var zeroDecimal = ["BIF", "CLP", "DJF", "GNF", "ISK", "JPY", "KMF", "KRW", "PYG", "RWF", "UGX", "VND", "VUV", "XAF", "XOF", "XPF", "IRR"]
        var threeDecimal = ["BHD", "IQD", "JOD", "KWD", "LYD", "OMR", "TND"]
        var decimals = zeroDecimal.indexOf(code) >= 0 ? 0 : (threeDecimal.indexOf(code) >= 0 ? 3 : 2)
        var value = Number(amountMinor) / Math.pow(10, decimals)
        var locale = LanguageUiController.currentLanguageIndex === 4 ? Qt.locale("fa_IR") : Qt.locale("en_US")
        return value.toLocaleString(locale, 'f', decimals) + " " + code
    }

    Rectangle { anchors.fill: parent; color: "#080E19" }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: body.implicitHeight + 32
        clip: true
        ColumnLayout {
            id: body
            width: parent.width
            spacing: 15

            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 20; Layout.rightMargin: 20; Layout.topMargin: 24
                Text { text: "فروشگاه"; color: "#F4F8FF"; font.pixelSize: 26; font.bold: true }
                Item { Layout.fillWidth: true }
                Rectangle {
                    radius: 10; color: "#12263A"; border.color: "#244760"
                    Layout.preferredWidth: 76; Layout.preferredHeight: 29
                    Text { anchors.centerIn: parent; text: root.storeName.toUpperCase(); color: "#42D9F5"; font.pixelSize: 10; font.bold: true }
                }
            }
            Text {
                Layout.fillWidth: true; Layout.leftMargin: 20; Layout.rightMargin: 20
                text: root.storeDescription || "پلن‌های فعال از فروشگاه دریافت می‌شوند."
                color: "#91A3BC"; font.pixelSize: 13; wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 148; radius: 20
                color: "#101F34"; border.color: "#284966"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 9
                    Text { text: "کاتالوگ فروشگاه"; color: "#F4F8FF"; font.pixelSize: 16; font.bold: true }
                    Text { text: root.maintenanceMode ? "فروشگاه موقتاً در دسترس نیست." : "پلن‌های فعال پنل به‌صورت زنده نمایش داده می‌شن."; color: "#91A3BC"; font.pixelSize: 11 }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "کاتالوگ امن Manubis"; color: "#C7D5E7"; font.pixelSize: 12 }
                        Item { Layout.fillWidth: true }
                        Button {
                            id: refreshStoreButton
                            text: loading ? "…" : "تازه‌سازی"
                            enabled: !loading
                            onClicked: { root.loadPlans(); root.loadStoreSettings() }
                            background: Rectangle { radius: 10; color: "#183B51"; border.color: "#28647B" }
                            contentItem: Text { text: refreshStoreButton.text; color: "#42D9F5"; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: statusText.implicitHeight + 26
                radius: 13; color: requestFailed ? "#2A1720" : "#10251F"
                border.color: requestFailed ? "#633344" : "#225642"
                Text {
                    id: statusText
                    anchors.fill: parent; anchors.margins: 13
                    text: statusMessage
                    color: requestFailed ? "#FFB7C4" : "#A7E8C6"
                    font.pixelSize: 12; wrapMode: Text.Wrap; verticalAlignment: Text.AlignVCenter
                }
            }

            Repeater {
                model: root.plans
                delegate: Rectangle {
                    required property var modelData
                    visible: !root.maintenanceMode
                    Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                    implicitHeight: planColumn.implicitHeight + 30
                    radius: 20; color: "#111B2D"; border.color: "#2A3D59"
                    ColumnLayout {
                        id: planColumn
                        anchors.fill: parent; anchors.margins: 16; spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: modelData.name || "پلن اینترنت"; color: "#F4F8FF"; font.pixelSize: 17; font.bold: true; Layout.fillWidth: true; wrapMode: Text.Wrap }
                            Rectangle {
                                radius: 9; color: "#153448"; border.color: "#245A70"
                                Layout.preferredWidth: priceLabel.implicitWidth + 18; Layout.preferredHeight: 30
                                Text { id: priceLabel; anchors.centerIn: parent; text: root.formatPrice(modelData.price_minor, modelData.currency); color: "#42D9F5"; font.pixelSize: 12; font.bold: true }
                            }
                        }
                        Text { text: modelData.description || "سرویس اختصاصی Manubis Guard"; color: "#A7B7CC"; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "مدت: " + root.formatDuration(modelData.duration_seconds); color: "#C7D5E7"; font.pixelSize: 11 }
                            Item { Layout.fillWidth: true }
                            Text { text: "حجم: " + root.formatBytes(modelData.data_limit_bytes); color: "#C7D5E7"; font.pixelSize: 11 }
                        }
                        Button {
                            id: buyPlanButton
                            Layout.fillWidth: true; Layout.preferredHeight: 44
                            text: root.maintenanceMode ? "فروشگاه موقتاً غیرفعال است" : "انتخاب پلن"
                            enabled: !root.maintenanceMode
                            onClicked: checkoutNotice.open()
                            background: Rectangle { radius: 12; color: buyPlanButton.enabled ? "#42D9F5" : "#263751" }
                            contentItem: Text { text: buyPlanButton.text; color: "#071321"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                }
            }

            Rectangle {
                visible: root.plans.length === 0 || root.maintenanceMode
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 128; radius: 18; color: "#0D1727"; border.color: "#21344D"
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 7
                    Text { text: "◇"; color: "#42D9F5"; font.pixelSize: 28; Layout.alignment: Qt.AlignHCenter }
                    Text { text: root.maintenanceMode ? "فروشگاه موقتاً غیرفعال است" : "پلن‌ها اینجا نمایش داده می‌شن"; color: "#F4F8FF"; font.pixelSize: 14; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                    Text { text: root.maintenanceMode ? "بعداً دوباره تلاش کن." : "بعد از تنظیم API، محصولات فعال پنل ظاهر می‌شن."; color: "#91A3BC"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
                }
            }

            Button {
                id: supportButton
                visible: root.supportUrl.length > 0
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                text: "ارتباط با پشتیبانی"
                onClicked: Qt.openUrlExternally(root.supportUrl)
                background: Rectangle { radius: 12; color: "#142238"; border.color: "#263650" }
                contentItem: Text { text: supportButton.text; color: "#42D9F5"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            Item { Layout.preferredHeight: 12 }
        }
    }

    Dialog {
        id: checkoutNotice
        modal: true
        title: "خرید آنلاین"
        standardButtons: Dialog.Ok
        anchors.centerIn: Overlay.overlay
        Label {
            width: Math.min(280, root.width - 60)
            text: "فهرست پلن‌ها به API متصل می‌شود، اما پرداخت و فعال‌سازی خودکار هنوز در backend تکمیل نشده‌اند. در این نسخه خرید واقعی غیرفعال است."
            wrapMode: Text.Wrap
        }
    }
}
