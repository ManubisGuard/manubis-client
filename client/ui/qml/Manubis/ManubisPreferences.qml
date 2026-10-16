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
    }

    property alias languageChosen: settingsStore.languageChosen
    property alias languageCode: settingsStore.languageCode

    // In-memory customer session only. Never persist bearer tokens in QSettings.
    property string sessionToken: ""
    property string accountId: ""
    property string accountUsername: ""
    readonly property bool isAuthenticated: sessionToken.length > 0 && accountId.length > 0
}
