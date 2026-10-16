pragma Singleton
import QtCore
import QtQml

QtObject {
    id: root

    property var persistentSettings: Settings {
        id: settingsStore
        category: "ManubisGuard"
        property bool languageChosen: false
        property string languageCode: ""
        property string storeApiBaseUrl: "https://all.qoqnusradio.top/store-api"
    }

    property alias languageChosen: settingsStore.languageChosen
    property alias languageCode: settingsStore.languageCode
    property alias storeApiBaseUrl: settingsStore.storeApiBaseUrl
}
