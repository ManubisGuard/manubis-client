pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../Controls2"
import "../Manubis"

PageType {
    id: root
    objectName: "PageManubisStore"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true

    // Public Store API endpoint. Admin credentials and main-panel API keys never belong in the client.
    readonly property string apiBaseUrl: "https://all.qoqnusradio.top/store-api"
    property string statusMessage: "در حال دریافت پلن‌های فعال فروشگاه…"
    property bool loading: false
    property bool requestFailed: false
    property bool settingsLoading: false
    property bool maintenanceMode: false
    property bool cardTransferEnabled: false
    property string selectedPlanId: ""
    property var activeOrder: null
    property string orderReceiptToken: ""
    property string paymentCardHolder: ""
    property string paymentCardNumber: ""
    property string paymentBankName: ""
    property string paymentInstructions: ""
    property bool orderSubmitting: false
    property string checkoutStatus: ""
    property string storeName: "ManubisGuard Store"
    property string storeDescription: ""
    property string supportUrl: ""
    property var plans: []

    function loadStoreSettings() {
        var base = root.apiBaseUrl.trim().replace(/\/+$/, "")
        if (!base.startsWith("https://")) return
        settingsLoading = true
        var xhr = new XMLHttpRequest()
        xhr.open("GET", base + "/api/v1/store/settings")
        xhr.timeout = 10000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            settingsLoading = false
            if (xhr.status >= 200 && xhr.status < 300) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    if (typeof data.store_name === "string") root.storeName = data.store_name
                    if (typeof data.store_description === "string") root.storeDescription = data.store_description
                    if (typeof data.support_url === "string") root.supportUrl = data.support_url
                    root.maintenanceMode = data.maintenance_mode === true
                    root.cardTransferEnabled = data.card_transfer_enabled === true
                } catch (e) {
                    console.warn("Manubis store settings response was invalid")
                }
            }
        }
        xhr.ontimeout = function() { settingsLoading = false }
        xhr.onerror = function() { settingsLoading = false }
        xhr.send()
    }

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
                    statusMessage = data.length ? data.length + " پلن فعال پیدا شد." : "هنوز پلن فعالی در فروشگاه ثبت نشده است."
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

    function createOrder() {
        var base = root.apiBaseUrl.trim().replace(/\/+$/, "")
        var reference = customerReferenceInput.text.trim()
        if (reference.length < 2) { checkoutStatus = "شماره تماس یا شناسه تلگرام را وارد کن."; return }
        if (!root.selectedPlanId || root.orderSubmitting) return
        root.orderSubmitting = true
        checkoutStatus = "در حال ساخت سفارش…"
        var xhr = new XMLHttpRequest()
        xhr.open("POST", base + "/api/v1/store/orders")
        xhr.setRequestHeader("Content-Type", "application/json")
        if (ManubisPreferences.isAuthenticated)
            xhr.setRequestHeader("Authorization", "Bearer " + ManubisPreferences.sessionToken)
        xhr.timeout = 15000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            root.orderSubmitting = false
            if (xhr.status === 201) {
                try {
                    var d = JSON.parse(xhr.responseText)
                    root.activeOrder = d
                    root.orderReceiptToken = d.receipt_token || ""
                    root.paymentCardHolder = d.card_holder_name || ""
                    root.paymentCardNumber = d.card_number || ""
                    root.paymentBankName = d.card_bank_name || ""
                    root.paymentInstructions = d.card_transfer_instructions || ""
                    orderReferenceDialog.close()
                    cardTransferDialog.open()
                    checkoutStatus = "سفارش ساخته شد. پس از واریز، رسید را بارگذاری کن."
                } catch (e) { checkoutStatus = "پاسخ سفارش نامعتبر است." }
            } else {
                var detail = "ساخت سفارش ناموفق بود (HTTP " + xhr.status + ")."
                try { var err = JSON.parse(xhr.responseText); if (err.detail) detail = err.detail } catch (e) {}
                checkoutStatus = detail
            }
        }
        xhr.ontimeout = function() { root.orderSubmitting = false; checkoutStatus = "زمان ساخت سفارش تمام شد." }
        xhr.onerror = function() { root.orderSubmitting = false; checkoutStatus = "اتصال به فروشگاه برقرار نشد." }
        xhr.send(JSON.stringify({plan_id: root.selectedPlanId, customer_reference: reference}))
    }

    function uploadReceipt(fileInfo) {
        if (!root.activeOrder || !root.orderReceiptToken) { checkoutStatus = "سفارش معتبر پیدا نشد."; return }
        if (fileInfo.error) { checkoutStatus = fileInfo.error; return }
        if (!fileInfo.contentBase64 || !fileInfo.contentType) { checkoutStatus = "خواندن فایل رسید ناموفق بود."; return }
        checkoutStatus = "در حال ارسال رسید به مدیریت…"
        var xhr = new XMLHttpRequest()
        var base = root.apiBaseUrl.trim().replace(/\/+$/, "")
        xhr.open("POST", base + "/api/v1/store/orders/" + encodeURIComponent(root.activeOrder.order_id) + "/receipt")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("X-Receipt-Token", root.orderReceiptToken)
        xhr.timeout = 30000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status === 202) {
                checkoutStatus = "رسید با موفقیت برای مدیر ارسال شد. پس از بررسی، وضعیت پرداخت به‌روزرسانی می‌شود."
                root.activeOrder.status = "pending_review"
            } else {
                var detail = "ارسال رسید ناموفق بود (HTTP " + xhr.status + ")."
                try { var err = JSON.parse(xhr.responseText); if (err.detail) detail = err.detail } catch (e) {}
                checkoutStatus = detail
            }
        }
        xhr.ontimeout = function() { checkoutStatus = "ارسال رسید زمان‌بر شد؛ اتصال را بررسی کن." }
        xhr.onerror = function() { checkoutStatus = "اتصال هنگام ارسال رسید قطع شد." }
        xhr.send(JSON.stringify({filename: fileInfo.filename, content_type: fileInfo.contentType, content_base64: fileInfo.contentBase64, transfer_reference: transferReferenceInput.text.trim() || null}))
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
                Text { text: root.storeName; color: "#F4F8FF"; font.pixelSize: 26; font.bold: true; Layout.fillWidth: true; wrapMode: Text.Wrap }
                Item { Layout.fillWidth: true }
                Rectangle {
                    radius: 10; color: "#12263A"; border.color: "#244760"
                    Layout.preferredWidth: 76; Layout.preferredHeight: 29
                    Text { anchors.centerIn: parent; text: "MANUBIS"; color: "#42D9F5"; font.pixelSize: 10; font.bold: true }
                }
            }
            Text {
                Layout.fillWidth: true; Layout.leftMargin: 20; Layout.rightMargin: 20
                text: root.storeDescription !== "" ? root.storeDescription : "پلن‌های فعال از API فروشگاه دریافت می‌شوند."
                color: "#91A3BC"; font.pixelSize: 13; wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 148; radius: 20
                color: "#101F34"; border.color: "#284966"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 9
                    Text { text: "کاتالوگ فروشگاه"; color: "#F4F8FF"; font.pixelSize: 16; font.bold: true }
                    Text { text: "پلن‌های فعال پنل به‌صورت زنده نمایش داده می‌شن."; color: "#91A3BC"; font.pixelSize: 11 }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "کاتالوگ امن Manubis"; color: "#C7D5E7"; font.pixelSize: 12 }
                        Item { Layout.fillWidth: true }
                        Button {
                            id: refreshStoreButton
                            text: loading ? "…" : "تازه‌سازی"
                            enabled: !loading
                            onClicked: root.loadPlans()
                            background: Rectangle { radius: 10; color: "#183B51"; border.color: "#28647B" }
                            contentItem: Text { text: refreshStoreButton.text; color: "#42D9F5"; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                }
            }

            Rectangle {
                visible: root.maintenanceMode
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: maintenanceText.implicitHeight + 28
                radius: 14; color: "#30251A"; border.color: "#72522A"
                Text {
                    id: maintenanceText
                    anchors.fill: parent; anchors.margins: 13
                    text: "فروشگاه موقتاً در حالت تعمیر و نگهداری است. خرید جدید در دسترس نیست."
                    color: "#FFD58A"; font.pixelSize: 12; wrapMode: Text.Wrap
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
                    visible: true
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
                            text: root.maintenanceMode ? "فروشگاه موقتاً غیرفعال است" : (root.cardTransferEnabled ? "خرید با کارت‌به‌کارت" : "پرداخت هنوز تنظیم نشده")
                            enabled: !root.maintenanceMode && root.cardTransferEnabled && !root.loading
                            onClicked: { root.selectedPlanId = modelData.id; customerReferenceInput.text = ManubisPreferences.isAuthenticated ? ManubisPreferences.accountUsername : ""; checkoutStatus = ""; orderReferenceDialog.open() }
                            background: Rectangle { radius: 12; color: buyPlanButton.enabled ? "#42D9F5" : "#263751" }
                            contentItem: Text { text: buyPlanButton.text; color: "#071321"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                }
            }

            Rectangle {
                visible: root.plans.length === 0
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 128; radius: 18; color: "#0D1727"; border.color: "#21344D"
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 7
                    Text { text: "◇"; color: "#42D9F5"; font.pixelSize: 28; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "پلن‌ها اینجا نمایش داده می‌شن"; color: "#F4F8FF"; font.pixelSize: 14; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "بعد از ثبت پلن فعال در backend، محصولات اینجا ظاهر می‌شن."; color: "#91A3BC"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
                }
            }

            Button {
                id: supportButton
                visible: root.supportUrl.length > 0
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                text: "ارتباط با پشتیبانی"
                onClicked: {
                    if (root.supportUrl.startsWith("https://"))
                        Qt.openUrlExternally(root.supportUrl)
                }
                background: Rectangle { radius: 12; color: "#142238"; border.color: "#263650" }
                contentItem: Text { text: supportButton.text; color: "#42D9F5"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            Item { Layout.preferredHeight: 12 }
        }
    }

    Dialog {
        id: orderReferenceDialog
        modal: true
        title: "ثبت سفارش کارت‌به‌کارت"
        standardButtons: Dialog.Cancel
        anchors.centerIn: Overlay.overlay
        width: Math.min(360, root.width - 28)
        contentItem: ColumnLayout {
            spacing: 10
            Label { text: ManubisPreferences.isAuthenticated ? "شناسه تماس برای سفارش (حساب به سفارش متصل می‌شود)" : "شماره تماس یا شناسه تلگرام"; wrapMode: Text.Wrap; Layout.fillWidth: true }
            TextField { id: customerReferenceInput; placeholderText: "مثلاً @username یا 09…"; Layout.fillWidth: true; selectByMouse: true }
            Button { text: root.orderSubmitting ? "در حال ساخت سفارش…" : "ادامه به پرداخت"; enabled: !root.orderSubmitting; Layout.fillWidth: true; onClicked: root.createOrder() }
            Label { text: root.checkoutStatus; color: "#FFB7C4"; wrapMode: Text.Wrap; Layout.fillWidth: true; visible: root.checkoutStatus.length > 0 }
        }
    }

    Dialog {
        id: cardTransferDialog
        modal: true
        title: "پرداخت کارت‌به‌کارت"
        standardButtons: Dialog.Close
        anchors.centerIn: Overlay.overlay
        width: Math.min(380, root.width - 24)
        contentItem: Flickable {
            implicitHeight: Math.min(paymentContent.implicitHeight + 8, root.height * 0.72)
            contentWidth: width; contentHeight: paymentContent.implicitHeight + 16; clip: true
            ColumnLayout {
                id: paymentContent; width: parent.width; spacing: 9
                Label { text: root.activeOrder ? "سفارش: " + root.activeOrder.order_id : ""; color: "#91A3BC"; wrapMode: Text.Wrap; Layout.fillWidth: true; font.pixelSize: 10 }
                Label { text: root.activeOrder ? "مبلغ قابل پرداخت: " + root.formatPrice(root.activeOrder.amount_minor, root.activeOrder.currency) : ""; color: "#42D9F5"; font.bold: true; wrapMode: Text.Wrap; Layout.fillWidth: true }
                Label { text: "صاحب کارت: " + root.paymentCardHolder; color: "#F4F8FF"; wrapMode: Text.Wrap; Layout.fillWidth: true }
                Label { text: root.paymentBankName.length ? "بانک: " + root.paymentBankName : ""; color: "#91A3BC"; visible: root.paymentBankName.length > 0; Layout.fillWidth: true }
                TextField { id: paymentCardNumberField; text: root.paymentCardNumber; readOnly: true; selectByMouse: true; Layout.fillWidth: true; font.pixelSize: 16; horizontalAlignment: TextInput.AlignHCenter }
                Button { text: "کپی شماره کارت"; Layout.fillWidth: true; onClicked: { paymentCardNumberField.selectAll(); paymentCardNumberField.copy(); checkoutStatus = "شماره کارت کپی شد." } }
                Label { text: root.paymentInstructions; visible: root.paymentInstructions.length > 0; color: "#C7D5E7"; wrapMode: Text.Wrap; Layout.fillWidth: true }
                Label { text: "بعد از انتقال وجه، تصویر یا PDF رسید را انتخاب کن."; color: "#91A3BC"; wrapMode: Text.Wrap; Layout.fillWidth: true }
                TextField { id: transferReferenceInput; placeholderText: "شماره پیگیری (اختیاری)"; Layout.fillWidth: true }
                Button { text: "انتخاب و ارسال رسید"; Layout.fillWidth: true; enabled: Boolean(root.activeOrder) && root.orderReceiptToken.length > 0; onClicked: receiptFileDialog.open() }
                Label { text: root.checkoutStatus; color: root.checkoutStatus.indexOf("موفقیت") >= 0 ? "#A7E8C6" : "#FFB7C4"; wrapMode: Text.Wrap; Layout.fillWidth: true; visible: root.checkoutStatus.length > 0 }
            }
        }
    }

    FileDialog {
        id: receiptFileDialog
        title: "انتخاب رسید پرداخت"
        fileMode: FileDialog.OpenFile
        nameFilters: ["رسید پرداخت (*.jpg *.jpeg *.png *.webp *.pdf)", "همه فایل‌ها (*)"]
        onAccepted: {
            var fileInfo = SubscriptionUiController.readLocalFileForUpload(selectedFile.toString())
            root.uploadReceipt(fileInfo)
        }
    }
}
