pragma Singleton
import QtCore
import QtQml

QtObject {
    id: root

    Settings {
        id: persistentSettings
        category: "ManubisGuard"
        property bool languageChosen: false
        property string storeApiBaseUrl: "https://all.qoqnusradio.top/store-api"
    }

    property alias languageChosen: persistentSettings.languageChosen
    property alias storeApiBaseUrl: persistentSettings.storeApiBaseUrl
}
