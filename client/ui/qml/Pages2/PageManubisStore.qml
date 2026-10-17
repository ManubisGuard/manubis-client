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

    function uiText(fa, en) { return LanguageUiController.currentLanguageIndex === 4 ? fa : en }
    function remoteText(value, fallback) { var v = String(value || ""); if (!v.length) return fallback; return LanguageUiController.currentLanguageIndex === 4 || !/[\u0600-\u06FF]/.test(v) ? v : fallback }
    function remoteField(obj, key, fallback) { var suffix = LanguageUiController.currentLanguageIndex === 4 ? "_fa" : "_en"; var translated = obj && obj[key + suffix]; return translated ? String(translated) : remoteText(obj ? obj[key] : "", fallback) }

    // Public Store API endpoint. Admin credentials and main-panel API keys never belong in the client.
    readonly property string apiBaseUrl: "https://all.qoqnusradio.top/store-api"
    property string statusMessage: root.uiText("در حال دریافت پلن‌های فعال فروشگاه…", "Loading available store plans…")
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
                    if (typeof data.store_name === "string" || typeof data.store_name_en === "string" || typeof data.store_name_fa === "string") root.storeName = root.remoteField(data, "store_name", "ManubisGuard Store")
                    if (typeof data.store_description === "string" || typeof data.store_description_en === "string" || typeof data.store_description_fa === "string") root.storeDescription = root.remoteField(data, "store_description", root.uiText("پلن‌های فعال از API فروشگاه دریافت می‌شوند.", "Active plans are loaded from the store API."))
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
            statusMessage = root.uiText("آدرس API فروشگاه هنوز تنظیم نشده است.", "Store API endpoint is not configured.")
            requestFailed = true
            return
        }
        if (!base.startsWith("https://")) {
            statusMessage = root.uiText("برای امنیت، آدرس فروشگاه باید با HTTPS شروع شود.", "For security, the store must use HTTPS.")
            requestFailed = true
            return
        }
        loading = true
        requestFailed = false
        statusMessage = root.uiText("در حال دریافت پلن‌ها…", "Loading plans…")
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
                    statusMessage = data.length ? data.length + root.uiText(" پلن فعال پیدا شد.", " active plans found.") : root.uiText("هنوز پلن فعالی در فروشگاه ثبت نشده است.", "No active plans are available yet.")
                    requestFailed = false
                } catch (e) {
                    statusMessage = root.uiText("پاسخ API فروشگاه قابل‌خواندن نیست.", "Could not read the store API response.")
                    requestFailed = true
                    plans = []
                }
            } else {
                statusMessage = root.uiText("دریافت پلن‌ها ناموفق بود (HTTP ", "Could not load plans (HTTP ") + xhr.status + "). " + root.uiText("آدرس API را بررسی کن.", "Check the API endpoint.")
                requestFailed = true
                plans = []
            }
        }
        xhr.ontimeout = function() {
            loading = false; requestFailed = true
            statusMessage = root.uiText("زمان اتصال به فروشگاه تمام شد.", "Store connection timed out.")
        }
        xhr.onerror = function() {
            loading = false; requestFailed = true
            statusMessage = root.uiText("اتصال به فروشگاه برقرار نشد. آدرس و دسترسی شبکه را بررسی کن.", "Could not connect to the store. Check network access.")
        }
        xhr.send()
    }

    function createOrder() {
        var base = root.apiBaseUrl.trim().replace(/\/+$/, "")
        var reference = customerReferenceInput.text.trim()
        if (reference.length < 2) { checkoutStatus = root.uiText("شماره تماس یا شناسه تلگرام را وارد کن.", "Enter a contact number or Telegram ID."); return }
        if (!root.selectedPlanId || root.orderSubmitting) return
        root.orderSubmitting = true
        checkoutStatus = root.uiText("در حال ساخت سفارش…", "Creating order…")
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
                    root.paymentCardHolder = root.remoteField(d, "card_holder_name", root.uiText("اطلاعات صاحب کارت از مدیریت دریافت شود.", "Contact support for bank account holder details."))
                    root.paymentCardNumber = d.card_number || ""
                    root.paymentBankName = root.remoteField(d, "card_bank_name", "")
                    root.paymentInstructions = root.remoteField(d, "card_transfer_instructions", root.uiText("برای دریافت راهنمای پرداخت با پشتیبانی تماس بگیر.", "Contact support for payment instructions."))
                    orderReferenceDialog.close()
                    cardTransferDialog.open()
                    checkoutStatus = root.uiText("سفارش ساخته شد. پس از واریز، رسید را بارگذاری کن.", "Order created. Upload your receipt after payment.")
                } catch (e) { checkoutStatus = root.uiText("پاسخ سفارش نامعتبر است.", "Invalid order response.") }
            } else {
                var detail = root.uiText("ساخت سفارش ناموفق بود (HTTP ", "Could not create order (HTTP ") + xhr.status + ")."
                try { var err = JSON.parse(xhr.responseText); if (err.detail) detail = root.remoteText(err.detail, "Could not create order (HTTP " + xhr.status + ").") } catch (e) {}
                checkoutStatus = detail
            }
        }
        xhr.ontimeout = function() { root.orderSubmitting = false; checkoutStatus = root.uiText("زمان ساخت سفارش تمام شد.", "Order creation timed out.") }
        xhr.onerror = function() { root.orderSubmitting = false; checkoutStatus = root.uiText("اتصال به فروشگاه برقرار نشد.", "Could not connect to the store.") }
        xhr.send(JSON.stringify({plan_id: root.selectedPlanId, customer_reference: reference}))
    }

    function uploadReceipt(fileInfo) {
        if (!root.activeOrder || !root.orderReceiptToken) { checkoutStatus = root.uiText("سفارش معتبر پیدا نشد.", "No valid order found."); return }
        if (fileInfo.error) { checkoutStatus = fileInfo.error; return }
        if (!fileInfo.contentBase64 || !fileInfo.contentType) { checkoutStatus = root.uiText("خواندن فایل رسید ناموفق بود.", "Could not read the receipt file."); return }
        checkoutStatus = root.uiText("در حال ارسال رسید به مدیریت…", "Sending receipt for review…")
        var xhr = new XMLHttpRequest()
        var base = root.apiBaseUrl.trim().replace(/\/+$/, "")
        xhr.open("POST", base + "/api/v1/store/orders/" + encodeURIComponent(root.activeOrder.order_id) + "/receipt")
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("X-Receipt-Token", root.orderReceiptToken)
        xhr.timeout = 30000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status === 202) {
                checkoutStatus = root.uiText("رسید با موفقیت برای مدیر ارسال شد. پس از بررسی، وضعیت پرداخت به‌روزرسانی می‌شود.", "Receipt submitted successfully. Payment status will update after review.")
                root.activeOrder.status = "pending_review"
            } else {
                var detail = root.uiText("ارسال رسید ناموفق بود (HTTP ", "Receipt upload failed (HTTP ") + xhr.status + ")."
                try { var err = JSON.parse(xhr.responseText); if (err.detail) detail = root.remoteText(err.detail, "Receipt upload failed (HTTP " + xhr.status + ").") } catch (e) {}
                checkoutStatus = detail
            }
        }
        xhr.ontimeout = function() { checkoutStatus = root.uiText("ارسال رسید زمان‌بر شد؛ اتصال را بررسی کن.", "Receipt upload timed out. Check your connection.") }
        xhr.onerror = function() { checkoutStatus = root.uiText("اتصال هنگام ارسال رسید قطع شد.", "Connection lost while uploading receipt.") }
        xhr.send(JSON.stringify({filename: fileInfo.filename, content_type: fileInfo.contentType, content_base64: fileInfo.contentBase64, transfer_reference: transferReferenceInput.text.trim() || null}))
    }

    Component.onCompleted: {
        root.loadPlans()
        root.loadStoreSettings()
    }

    function formatBytes(bytes) {
        var b = Number(bytes)
        if (!b) return root.uiText("بدون محدودیت حجمی", "Unlimited data")
        if (b >= 1073741824) return (b / 1073741824).toFixed(1) + " GB"
        if (b >= 1048576) return (b / 1048576).toFixed(0) + " MB"
        return b.toLocaleString() + " B"
    }
    function formatDuration(seconds) {
        var s = Number(seconds)
        var days = Math.floor(s / 86400)
        if (days >= 30 && days % 30 === 0) return (days / 30) + root.uiText(" ماه", " months")
        if (days > 0) return days + root.uiText(" روز", " days")
        return Math.max(1, Math.floor(s / 3600)) + root.uiText(" ساعت", " hours")
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
                Text { text: root.remoteText(root.storeName, "ManubisGuard Store"); color: "#F4F8FF"; font.pixelSize: 26; font.bold: true; Layout.fillWidth: true; wrapMode: Text.Wrap }
                Item { Layout.fillWidth: true }
                Rectangle {
                    radius: 10; color: "#12263A"; border.color: "#244760"
                    Layout.preferredWidth: 76; Layout.preferredHeight: 29
                    Text { anchors.centerIn: parent; text: "MANUBIS"; color: "#42D9F5"; font.pixelSize: 10; font.bold: true }
                }
            }
            Text {
                Layout.fillWidth: true; Layout.leftMargin: 20; Layout.rightMargin: 20
                text: root.storeDescription !== "" ? root.remoteText(root.storeDescription, root.uiText("پلن‌های فعال از API فروشگاه دریافت می‌شوند.", "Active plans are loaded from the store API.")) : root.uiText("پلن‌های فعال از API فروشگاه دریافت می‌شوند.", "Active plans are loaded from the store API.")
                color: "#91A3BC"; font.pixelSize: 13; wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                Layout.preferredHeight: 148; radius: 20
                color: "#101F34"; border.color: "#284966"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 9
                    Text { text: root.uiText("کاتالوگ فروشگاه", "Store catalogue"); color: "#F4F8FF"; font.pixelSize: 16; font.bold: true }
                    Text { text: root.uiText("پلن‌های فعال پنل به‌صورت زنده نمایش داده می‌شن.", "Active plans are shown live."); color: "#91A3BC"; font.pixelSize: 11 }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 8
                        Text { text: root.uiText("کاتالوگ امن Manubis", "Secure Manubis catalogue"); color: "#C7D5E7"; font.pixelSize: 12 }
                        Item { Layout.fillWidth: true }
                        Button {
                            id: refreshStoreButton
                            text: loading ? "…" : root.uiText("تازه‌سازی", "Refresh")
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
                    text: root.uiText("فروشگاه موقتاً در حالت تعمیر و نگهداری است. خرید جدید در دسترس نیست.", "The store is under maintenance. New purchases are unavailable.")
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
                            Text { text: root.remoteField(modelData, "name", root.uiText("پلن اینترنت", "Internet plan")); color: "#F4F8FF"; font.pixelSize: 17; font.bold: true; Layout.fillWidth: true; wrapMode: Text.Wrap }
                            Rectangle {
                                radius: 9; color: "#153448"; border.color: "#245A70"
                                Layout.preferredWidth: priceLabel.implicitWidth + 18; Layout.preferredHeight: 30
                                Text { id: priceLabel; anchors.centerIn: parent; text: root.formatPrice(modelData.price_minor, modelData.currency); color: "#42D9F5"; font.pixelSize: 12; font.bold: true }
                            }
                        }
                        Text { text: root.remoteField(modelData, "description", root.uiText("سرویس اختصاصی Manubis Guard", "Manubis Guard service")); color: "#A7B7CC"; font.pixelSize: 12; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: root.uiText("مدت: ", "Duration: ") + root.formatDuration(modelData.duration_seconds); color: "#C7D5E7"; font.pixelSize: 11 }
                            Item { Layout.fillWidth: true }
                            Text { text: root.uiText("حجم: ", "Data: ") + root.formatBytes(modelData.data_limit_bytes); color: "#C7D5E7"; font.pixelSize: 11 }
                        }
                        Button {
                            id: buyPlanButton
                            Layout.fillWidth: true; Layout.preferredHeight: 44
                            text: root.maintenanceMode ? root.uiText("فروشگاه موقتاً غیرفعال است", "Store temporarily disabled") : (root.cardTransferEnabled ? root.uiText("خرید با کارت‌به‌کارت", "Pay by bank transfer") : root.uiText("پرداخت هنوز تنظیم نشده", "Payment is not configured yet"))
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
                    Text { text: root.uiText("پلن‌ها اینجا نمایش داده می‌شن", "Plans will appear here"); color: "#F4F8FF"; font.pixelSize: 14; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                    Text { text: root.uiText("بعد از ثبت پلن فعال در backend، محصولات اینجا ظاهر می‌شن.", "Products appear here after an active plan is added in the backend."); color: "#91A3BC"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
                }
            }

            Button {
                id: supportButton
                visible: root.supportUrl.length > 0
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                text: root.uiText("ارتباط با پشتیبانی", "Contact support")
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
        title: root.uiText("ثبت سفارش کارت‌به‌کارت", "Bank transfer order")
        standardButtons: Dialog.Cancel
        anchors.centerIn: Overlay.overlay
        width: Math.min(360, root.width - 28)
        contentItem: ColumnLayout {
            spacing: 10
            Label { text: ManubisPreferences.isAuthenticated ? root.uiText("شناسه تماس برای سفارش (حساب به سفارش متصل می‌شود)", "Contact ID for this order (linked to your account)") : root.uiText("شماره تماس یا شناسه تلگرام", "Contact number or Telegram ID"); wrapMode: Text.Wrap; Layout.fillWidth: true }
            TextField { id: customerReferenceInput; placeholderText: root.uiText("مثلاً @username یا 09…", "e.g. @username or phone number"); Layout.fillWidth: true; selectByMouse: true }
            Button { text: root.orderSubmitting ? root.uiText("در حال ساخت سفارش…", "Creating order…") : root.uiText("ادامه به پرداخت", "Continue to payment"); enabled: !root.orderSubmitting; Layout.fillWidth: true; onClicked: root.createOrder() }
            Label { text: root.checkoutStatus; color: "#FFB7C4"; wrapMode: Text.Wrap; Layout.fillWidth: true; visible: root.checkoutStatus.length > 0 }
        }
    }

    Dialog {
        id: cardTransferDialog
        modal: true
        title: root.uiText("پرداخت کارت‌به‌کارت", "Bank transfer payment")
        standardButtons: Dialog.Close
        anchors.centerIn: Overlay.overlay
        width: Math.min(380, root.width - 24)
        contentItem: Flickable {
            implicitHeight: Math.min(paymentContent.implicitHeight + 8, root.height * 0.72)
            contentWidth: width; contentHeight: paymentContent.implicitHeight + 16; clip: true
            ColumnLayout {
                id: paymentContent; width: parent.width; spacing: 9
                Label { text: root.activeOrder ? root.uiText("سفارش: ", "Order: ") + root.activeOrder.order_id : ""; color: "#91A3BC"; wrapMode: Text.Wrap; Layout.fillWidth: true; font.pixelSize: 10 }
                Label { text: root.activeOrder ? root.uiText("مبلغ قابل پرداخت: ", "Amount due: ") + root.formatPrice(root.activeOrder.amount_minor, root.activeOrder.currency) : ""; color: "#42D9F5"; font.bold: true; wrapMode: Text.Wrap; Layout.fillWidth: true }
                Label { text: root.uiText("صاحب کارت: ", "Account holder: ") + root.paymentCardHolder; color: "#F4F8FF"; wrapMode: Text.Wrap; Layout.fillWidth: true }
                Label { text: root.paymentBankName.length ? root.uiText("بانک: ", "Bank: ") + root.paymentBankName : ""; color: "#91A3BC"; visible: root.paymentBankName.length > 0; Layout.fillWidth: true }
                TextField { id: paymentCardNumberField; text: root.paymentCardNumber; readOnly: true; selectByMouse: true; Layout.fillWidth: true; font.pixelSize: 16; horizontalAlignment: TextInput.AlignHCenter }
                Button { text: root.uiText("کپی شماره کارت", "Copy card number"); Layout.fillWidth: true; onClicked: { paymentCardNumberField.selectAll(); paymentCardNumberField.copy(); checkoutStatus = root.uiText("شماره کارت کپی شد.", "Card number copied.") } }
                Label { text: root.paymentInstructions; visible: root.paymentInstructions.length > 0; color: "#C7D5E7"; wrapMode: Text.Wrap; Layout.fillWidth: true }
                Label { text: root.uiText("بعد از انتقال وجه، تصویر یا PDF رسید را انتخاب کن.", "After payment, select an image or PDF receipt."); color: "#91A3BC"; wrapMode: Text.Wrap; Layout.fillWidth: true }
                TextField { id: transferReferenceInput; placeholderText: root.uiText("شماره پیگیری (اختیاری)", "Payment reference (optional)"); Layout.fillWidth: true }
                Button { text: root.uiText("انتخاب و ارسال رسید", "Choose and upload receipt"); Layout.fillWidth: true; enabled: Boolean(root.activeOrder) && root.orderReceiptToken.length > 0; onClicked: receiptFileDialog.open() }
                Label { text: root.checkoutStatus; color: (root.checkoutStatus.indexOf("موفقیت") >= 0 || root.checkoutStatus.toLowerCase().indexOf("successfully") >= 0) ? "#A7E8C6" : "#FFB7C4"; wrapMode: Text.Wrap; Layout.fillWidth: true; visible: root.checkoutStatus.length > 0 }
            }
        }
    }

    FileDialog {
        id: receiptFileDialog
        title: root.uiText("انتخاب رسید پرداخت", "Select payment receipt")
        fileMode: FileDialog.OpenFile
        nameFilters: [root.uiText("رسید پرداخت (*.jpg *.jpeg *.png *.webp *.pdf)", "Payment receipts (*.jpg *.jpeg *.png *.webp *.pdf)"), root.uiText("همه فایل‌ها (*)", "All files (*)")]
        onAccepted: {
            var fileInfo = SubscriptionUiController.readLocalFileForUpload(selectedFile.toString())
            root.uploadReceipt(fileInfo)
        }
    }
}
