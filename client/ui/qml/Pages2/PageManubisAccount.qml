import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Controls2"
import "../Manubis"
import PageEnum 1.0

PageType {
    id: root
    objectName: "PageManubisAccount"
    LayoutMirroring.enabled: LanguageUiController.currentLanguageIndex === 4
    LayoutMirroring.childrenInherit: true

    readonly property string apiBaseUrl: "https://all.qoqnusradio.top/store-api"
    property bool registerMode: false
    property bool busy: false
    property bool messageIsError: false
    property string message: ""
    property var orders: []
    property bool ordersLoading: false
    property color ink: "#F4F8FF"
    property color muted: "#91A3BC"
    property color cyan: "#42D9F5"
    property color panel: "#111B2D"
    property color line: "#2A3D59"

    function clearSession() {
        ManubisPreferences.sessionToken = ""
        ManubisPreferences.accountId = ""
        ManubisPreferences.accountUsername = ""
        orders = []
    }

    function restoreSession() {
        if (!ManubisPreferences.sessionToken.length) return
        var xhr = new XMLHttpRequest()
        xhr.open("GET", root.apiBaseUrl + "/api/v1/auth/me")
        xhr.setRequestHeader("Authorization", "Bearer " + ManubisPreferences.sessionToken)
        xhr.timeout = 10000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status === 200) {
                try {
                    var user = JSON.parse(xhr.responseText)
                    ManubisPreferences.accountId = String(user.id || "")
                    ManubisPreferences.accountUsername = String(user.username || "")
                    root.loadOrders()
                } catch (e) { root.clearSession() }
            } else {
                root.clearSession()
                root.message = "نشست قبلی معتبر نیست؛ دوباره وارد شو."
                root.messageIsError = true
            }
        }
        xhr.ontimeout = function() { root.message = "بررسی نشست زمان‌بر شد؛ اتصال را بررسی کن."; root.messageIsError = true }
        xhr.onerror = function() { root.message = "فعلاً اتصال به حساب برقرار نشد."; root.messageIsError = true }
        xhr.send()
    }

    function authenticate() {
        var username = usernameInput.text.trim().toLowerCase()
        var password = passwordInput.text
        if (username.length < 3) { message = "نام کاربری باید حداقل ۳ نویسه باشد."; messageIsError = true; return }
        if (password.length < 10) { message = "رمز عبور باید حداقل ۱۰ نویسه باشد."; messageIsError = true; return }
        if (registerMode && password !== confirmPasswordInput.text) { message = "تکرار رمز عبور یکسان نیست."; messageIsError = true; return }
        if (busy) return
        busy = true
        message = registerMode ? "در حال ساخت حساب امن…" : "در حال بررسی اطلاعات ورود…"
        messageIsError = false
        var xhr = new XMLHttpRequest()
        xhr.open("POST", root.apiBaseUrl + (registerMode ? "/api/v1/auth/register" : "/api/v1/auth/login"))
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.timeout = 20000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            busy = false
            if (xhr.status === 200 || xhr.status === 201) {
                try {
                    var data = JSON.parse(xhr.responseText)
                    if (!data.access_token || !data.user || !data.user.id) throw new Error("invalid response")
                    ManubisPreferences.sessionToken = String(data.access_token)
                    ManubisPreferences.accountId = String(data.user.id)
                    ManubisPreferences.accountUsername = String(data.user.username || username)
                    passwordInput.text = ""
                    confirmPasswordInput.text = ""
                    message = registerMode ? "حساب ساخته شد و وارد شدی." : "ورود موفق بود. خوش برگشتی!"
                    messageIsError = false
                    root.loadOrders()
                } catch (e) { message = "پاسخ سرور قابل‌خواندن نیست."; messageIsError = true }
            } else {
                var detail = xhr.status === 409 ? "این نام کاربری قبلاً ثبت شده است." : xhr.status === 401 ? "نام کاربری یا رمز عبور درست نیست." : xhr.status === 429 ? "تلاش‌ها زیاد بود؛ ۱۵ دقیقه بعد دوباره امتحان کن." : "ارتباط با سرویس حساب ناموفق بود (HTTP " + xhr.status + ")."
                try { var data = JSON.parse(xhr.responseText); if (data.detail && xhr.status !== 401 && xhr.status !== 429 && xhr.status !== 409) detail = data.detail } catch (e) {}
                message = detail
                messageIsError = true
            }
        }
        xhr.ontimeout = function() { busy = false; message = "درخواست زمان‌بر شد؛ دوباره امتحان کن."; messageIsError = true }
        xhr.onerror = function() { busy = false; message = "اتصال به سرویس حساب برقرار نشد."; messageIsError = true }
        xhr.send(JSON.stringify({username: username, password: password}))
    }

    function loadOrders() {
        if (!ManubisPreferences.isAuthenticated) { orders = []; return }
        ordersLoading = true
        var xhr = new XMLHttpRequest()
        xhr.open("GET", root.apiBaseUrl + "/api/v1/auth/me/orders")
        xhr.setRequestHeader("Authorization", "Bearer " + ManubisPreferences.sessionToken)
        xhr.timeout = 12000
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            ordersLoading = false
            if (xhr.status === 200) {
                try { var data = JSON.parse(xhr.responseText); orders = Array.isArray(data) ? data : [] }
                catch (e) { message = "تاریخچه سفارش‌ها قابل‌خواندن نیست."; messageIsError = true }
            } else if (xhr.status === 401) {
                clearSession(); message = "نشست منقضی شده؛ دوباره وارد شو."; messageIsError = true
            } else {
                message = "دریافت تاریخچه سفارش‌ها ناموفق بود (HTTP " + xhr.status + ")."; messageIsError = true
            }
        }
        xhr.ontimeout = function() { ordersLoading = false; message = "دریافت تاریخچه زمان‌بر شد."; messageIsError = true }
        xhr.onerror = function() { ordersLoading = false; message = "اتصال برای دریافت سفارش‌ها برقرار نشد."; messageIsError = true }
        xhr.send()
    }

    function statusLabel(value) {
        var labels = {pending_payment:"در انتظار پرداخت", pending_review:"رسید در حال بررسی", rejected:"رسید رد شده", paid_pending_provisioning:"پرداخت تأیید شده، فعال‌سازی در انتظار", fulfilled:"فعال شده", cancelled:"لغو شده", failed:"ناموفق", refunded:"بازپرداخت شده"}
        return labels[String(value)] || String(value || "نامشخص")
    }

    function logout() {
        var token = ManubisPreferences.sessionToken
        clearSession()
        message = "از حساب خارج شدی."; messageIsError = false
        if (!token.length) return
        var xhr = new XMLHttpRequest()
        xhr.open("POST", root.apiBaseUrl + "/api/v1/auth/logout")
        xhr.setRequestHeader("Authorization", "Bearer " + token)
        xhr.timeout = 5000
        xhr.send()
    }

    Component.onCompleted: root.restoreSession()

    Rectangle { anchors.fill: parent; color: "#080E19" }
    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: body.implicitHeight + 32
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ColumnLayout {
            id: body
            width: parent.width
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.topMargin: 26; spacing: 5
                Text { text: "حساب کاربری"; color: root.ink; font.pixelSize: 27; font.bold: true }
                Text { text: "حساب، سفارش‌ها و وضعیت رسیدهای پرداختت را از همین‌جا مدیریت کن."; color: root.muted; font.pixelSize: 13; wrapMode: Text.Wrap; Layout.fillWidth: true }
            }

            Rectangle {
                visible: ManubisPreferences.isAuthenticated
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                implicitHeight: profileColumn.implicitHeight + 34
                radius: 20; color: "#10291F"; border.color: "#205A43"
                ColumnLayout {
                    id: profileColumn
                    anchors.fill: parent; anchors.margins: 17; spacing: 8
                    Text { text: "وارد شده‌ای"; color: "#8EE9BD"; font.pixelSize: 12; font.bold: true }
                    Text { text: "@" + ManubisPreferences.accountUsername; color: root.ink; font.pixelSize: 21; font.bold: true }
                    Text { text: "نشست فقط در حافظه فعلی برنامه نگهداری می‌شود و با بستن کامل برنامه پاک خواهد شد."; color: "#B3C8BE"; font.pixelSize: 11; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    RowLayout {
                        Layout.fillWidth: true
                        Button {
                            text: "به‌روزرسانی سفارش‌ها"
                            onClicked: { root.loadOrders() }
                            Layout.fillWidth: true
                            background: Rectangle { radius: 10; color: "#183B51" }
                            contentItem: Text { text: parent.text; color: root.cyan; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 11 }
                        }
                        Button {
                            text: "خروج"
                            onClicked: { root.logout() }
                            background: Rectangle { radius: 10; color: "#33202B" }
                            contentItem: Text { text: parent.text; color: "#FFB7C4"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 11 }
                        }
                    }
                }
            }

            Rectangle {
                visible: !ManubisPreferences.isAuthenticated
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                implicitHeight: formColumn.implicitHeight + 36
                radius: 20; color: root.panel; border.color: root.line
                ColumnLayout {
                    id: formColumn
                    anchors.fill: parent; anchors.margins: 18; spacing: 11
                    Text { text: root.registerMode ? "ساخت حساب جدید" : "ورود به حساب"; color: root.ink; font.pixelSize: 18; font.bold: true }
                    Text { text: "نام کاربری و رمز عبور برای نگهداری امن نشست استفاده می‌شوند. ایمیل یا اطلاعات غیرضروری درخواست نمی‌کنیم."; color: root.muted; font.pixelSize: 11; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    TextField {
                        id: usernameInput; Layout.fillWidth: true; placeholderText: "نام کاربری (۳ تا ۳۲ نویسه)"; color: root.ink; selectByMouse: true; maximumLength: 32; inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                        background: Rectangle { radius: 10; color: "#091321"; border.color: root.line }
                    }
                    TextField {
                        id: passwordInput; Layout.fillWidth: true; placeholderText: "رمز عبور (حداقل ۱۰ نویسه)"; echoMode: TextInput.Password; color: root.ink; selectByMouse: true; maximumLength: 128
                        background: Rectangle { radius: 10; color: "#091321"; border.color: root.line }
                    }
                    TextField {
                        id: confirmPasswordInput; visible: root.registerMode; Layout.fillWidth: true; placeholderText: "تکرار رمز عبور"; echoMode: TextInput.Password; color: root.ink; selectByMouse: true; maximumLength: 128
                        background: Rectangle { radius: 10; color: "#091321"; border.color: root.line }
                    }
                    Button {
                        id: submitButton; Layout.fillWidth: true; Layout.preferredHeight: 46
                        enabled: !root.busy; text: root.busy ? "در حال بررسی…" : (root.registerMode ? "ساخت حساب و ورود" : "ورود امن")
                        onClicked: root.authenticate()
                        background: Rectangle { radius: 12; color: submitButton.enabled ? root.cyan : "#365166" }
                        contentItem: Text { text: submitButton.text; color: "#071321"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Button {
                        Layout.fillWidth: true; flat: true
                        text: root.registerMode ? "حساب داری؟ ورود" : "حساب نداری؟ ساخت حساب"
                        onClicked: { root.registerMode = !root.registerMode; root.message = ""; root.messageIsError = false }
                        contentItem: Text { text: parent.text; color: root.cyan; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 12 }
                    }
                }
            }

            Rectangle {
                visible: root.message.length > 0
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18
                implicitHeight: messageLabel.implicitHeight + 22
                radius: 12; color: root.messageIsError ? "#321F2A" : "#102B3A"; border.color: root.messageIsError ? "#794253" : "#24566D"
                Text { id: messageLabel; anchors.fill: parent; anchors.margins: 11; text: root.message; color: root.messageIsError ? "#FFB7C4" : root.cyan; font.pixelSize: 12; wrapMode: Text.Wrap; verticalAlignment: Text.AlignVCenter }
            }

            ColumnLayout {
                visible: ManubisPreferences.isAuthenticated
                Layout.fillWidth: true; Layout.leftMargin: 18; Layout.rightMargin: 18; spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "سفارش‌های من"; color: root.ink; font.pixelSize: 18; font.bold: true; Layout.fillWidth: true }
                    Text { text: root.ordersLoading ? "در حال دریافت…" : root.orders.length + " سفارش"; color: root.muted; font.pixelSize: 11 }
                }
                Rectangle {
                    visible: !root.ordersLoading && root.orders.length === 0
                    Layout.fillWidth: true; implicitHeight: 78; radius: 16; color: "#0D1727"; border.color: "#21344D"
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 6
                        Text { text: "هنوز سفارشی ثبت نشده"; color: root.ink; font.pixelSize: 13; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "پلن‌ها را در فروشگاه ببین و سفارش اولت را ثبت کن."; color: root.muted; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
                    }
                }
                Repeater {
                    model: root.orders
                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true; implicitHeight: orderInfo.implicitHeight + 28
                        radius: 15; color: "#111B2D"; border.color: "#263650"
                        ColumnLayout {
                            id: orderInfo; anchors.fill: parent; anchors.margins: 13; spacing: 5
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: modelData.plan_name || "سفارش ManubisGuard"; color: root.ink; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true; wrapMode: Text.Wrap }
                                Text { text: root.statusLabel(modelData.status); color: modelData.status === "fulfilled" ? "#8EE9BD" : modelData.status === "rejected" || modelData.status === "failed" ? "#FFB7C4" : root.cyan; font.pixelSize: 10; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignRight }
                            }
                            Text { text: root.formatOrderPrice(modelData.amount_minor, modelData.currency); color: root.cyan; font.pixelSize: 13; font.bold: true }
                            Text { text: "ثبت: " + String(modelData.created_at || "").replace("T", " ").slice(0, 16); color: root.muted; font.pixelSize: 10 }
                            Text { visible: modelData.receipt_submitted; text: "رسید ثبت شده"; color: "#8EE9BD"; font.pixelSize: 10 }
                        }
                    }
                }
                Button {
                    Layout.fillWidth: true; text: "رفتن به فروشگاه"; onClicked: PageController.goToPage(PageEnum.PageManubisStore)
                    background: Rectangle { radius: 12; color: "#183B51"; border.color: "#28647B" }
                    contentItem: Text { text: parent.text; color: root.cyan; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
            Item { Layout.preferredHeight: 10 }
        }
    }

    function formatOrderPrice(amountMinor, currency) {
        var code = String(currency || "IRR").toUpperCase()
        var decimals = ["BIF","CLP","DJF","GNF","ISK","JPY","KMF","KRW","PYG","RWF","UGX","VND","VUV","XAF","XOF","XPF","IRR"].indexOf(code) >= 0 ? 0 : 2
        var locale = LanguageUiController.currentLanguageIndex === 4 ? Qt.locale("fa_IR") : Qt.locale("en_US")
        return (Number(amountMinor) / Math.pow(10, decimals)).toLocaleString(locale, "f", decimals) + " " + code
    }
}
