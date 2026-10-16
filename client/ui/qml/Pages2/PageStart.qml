import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore

import PageEnum 1.0
import Style 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"
import "../Components"

PageType {
    id: root

    property bool isControlsDisabled: false
    property bool isTabBarDisabled: false
    property bool isTabBarShown: true
    readonly property real tabBarHeight: tabBar.visible ? tabBar.height : 0

    Settings {
        id: productPreferences
        category: "ManubisGuard"
        property bool languageChosen: false
        property string languageCode: ""
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
            PageController.keyPressEvent(event.key)
            event.accepted = true
        }
    }

    Connections {
        objectName: "pageControllerConnection"

        target: PageController

        function onGoToPageHome() {
            root.isTabBarShown = true
            tabBar.setCurrentIndex(0)
            tabBarStackView.goToTabBarPage(PageEnum.PageManubisHome)
        }

        function onGoToPageSettings() {
            var pagePath = PageController.getPagePath(PageEnum.PageManubisSettings)
            tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.PushTransition)
            root.isTabBarShown = true
        }

        function onGoToPageViewConfig() {
            var pagePath = PageController.getPagePath(PageEnum.PageManubisImportReview)
            tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.PushTransition)
        }

        function onGoToShareConnectionPage(headerText, configContentHeaderText, configCaption, configExtension, configFileName) {
            // Do not expose the legacy Amnezia share screen in the Manubis UI.
            PageController.showNotificationMessage(qsTr("Sharing connection files is not available in this version yet."))
        }

        function onDisableControls(disabled) {
            isControlsDisabled = disabled
        }

        function onDisableTabBar(disabled) {
            isTabBarDisabled = disabled
        }

        function onClosePage() {
            if (tabBarStackView.depth <= 1) {
                PageController.hideWindow()
                return
            }
            tabBarStackView.pop()
        }

        function onGoToPage(page, slide) {
            // Route legacy Amnezia entry points into the Manubis experience.
            if (page === PageEnum.PageHome || page === PageEnum.PageSetupWizardStart) {
                page = PageEnum.PageManubisHome
            } else if (page === PageEnum.PageSettings || page === PageEnum.PageSettingsServersList ||
                       (page >= PageEnum.PageSettingsServerData && page <= PageEnum.PageSettingsKillSwitchExceptions) ||
                       (page >= PageEnum.PageProtocolOpenVpnSettings && page <= PageEnum.PageProtocolXrayXPaddingBytesSettings)) {
                page = PageEnum.PageManubisSettings
            } else if (page === PageEnum.PageSettingsLanguage) {
                page = PageEnum.PageManubisLanguage
            } else if (page === PageEnum.PageShare || page === PageEnum.PageShareFullAccess ||
                       page === PageEnum.PageShareConnection) {
                page = PageEnum.PageManubisAccount
            } else if (page === PageEnum.PageAbout || page === PageEnum.PageDevMenu ||
                       (page >= PageEnum.PageServiceSftpSettings && page <= PageEnum.PageServiceTProxySettings)) {
                page = PageEnum.PageManubisSettings
            } else if (page === PageEnum.PageSetupWizardViewConfig) {
                page = PageEnum.PageManubisImportReview
            } else if (page === PageEnum.PageSetupWizardConfigSource ||
                       (page >= PageEnum.PageSetupWizardStart && page <= PageEnum.PageSetupWizardApiFreeInfo) ||
                       page === PageEnum.PageSetupWizardApiPremiumInfo || page === PageEnum.PageSetupWizardApiTrialEmail) {
                page = PageEnum.PageManubisImportSubscription
            }

            if (page === PageEnum.PageManubisHome || page === PageEnum.PageManubisDashboard ||
                    page === PageEnum.PageManubisStore || page === PageEnum.PageManubisAccount) {
                if (page === PageEnum.PageManubisHome) tabBar.setCurrentIndex(0)
                else if (page === PageEnum.PageManubisStore) tabBar.setCurrentIndex(1)
                else if (page === PageEnum.PageManubisDashboard) tabBar.setCurrentIndex(2)
                else tabBar.setCurrentIndex(3)
                tabBarStackView.goToTabBarPage(page)
                root.isTabBarShown = true
                return
            }

            var pagePath = PageController.getPagePath(page)
            if (slide) {
                tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.PushTransition)
            } else {
                tabBarStackView.replace(pagePath, { "objectName" : pagePath }, StackView.Immediate)
            }
            root.isTabBarShown = page !== PageEnum.PageManubisLanguage
        }

        function onGoToStartPage() {
            while (tabBarStackView.depth > 1) {
                tabBarStackView.pop()
            }
            if (!productPreferences.languageChosen) {
                root.isTabBarShown = false
                var languagePath = PageController.getPagePath(PageEnum.PageManubisLanguage)
                tabBarStackView.replace(languagePath, { "objectName" : languagePath }, StackView.Immediate)
            } else {
                root.isTabBarShown = true
                tabBarStackView.goToTabBarPage(PageEnum.PageManubisHome)
            }
        }

        function onEscapePressed() {
            if (root.isControlsDisabled || root.isTabBarDisabled) {
                return
            }

            var pageName = tabBarStackView.currentItem.objectName
            if ((pageName === PageController.getPagePath(PageEnum.PageShare)) ||
                    (pageName === PageController.getPagePath(PageEnum.PageManubisSettings)) ||
                    (pageName === PageController.getPagePath(PageEnum.PageManubisImportSubscription)) ||
                    (pageName === PageController.getPagePath(PageEnum.PageManubisImportReview))) {
                PageController.goToPageHome()
            } else {
                PageController.closePage()
            }
        }
    }

    Connections {
        objectName: "connectionControllerConnections"

        target: ConnectionController

        function onNoInstalledContainers() {
            PageController.setTriggeredByConnectButton(true)
            PageController.goToPage(PageEnum.PageManubisImportSubscription)
        }
    }

    Connections {
        objectName: "installControllerConnections"

        target: InstallController

        function onInstallationErrorOccurred(error) {
            PageController.showBusyIndicator(false)

            PageController.showErrorMessage(error)

            var needCloseCurrentPage = false
            var currentPageName = tabBarStackView.currentItem.objectName

            if (currentPageName === PageController.getPagePath(PageEnum.PageSetupWizardInstalling)) {
                needCloseCurrentPage = true
            } else if (currentPageName === PageController.getPagePath(PageEnum.PageDeinstalling)) {
                needCloseCurrentPage = true
            }
            if (needCloseCurrentPage) {
                PageController.closePage()
            }
        }

        function onWrongInstallationUser(message) {
            onInstallationErrorOccurred(message)
        }

        function onUpdateContainerFinished(message, closePage) {
            PageController.showNotificationMessage(message)
            if (closePage) {
                PageController.closePage()
            }
        }

        function onCachedProfileCleared(message) {
            PageController.showNotificationMessage(message)
        }

        function onRemoveServerFinished(finishedMessage) {
            PageController.goToPageHome()
            PageController.showNotificationMessage(finishedMessage)
        }

        function onRemoveAllContainersFinished(finishedMessage) {
            if (tabBarStackView.currentItem.objectName === PageController.getPagePath(PageEnum.PageDeinstalling)) {
                PageController.closePage()
            }
            PageController.showNotificationMessage(finishedMessage)
        }

        function onRemoveContainerFinished(finishedMessage) {
            if (tabBarStackView.currentItem.objectName === PageController.getPagePath(PageEnum.PageDeinstalling)) {
                PageController.closePage()
            }
            PageController.closePage()
            PageController.showNotificationMessage(finishedMessage)
        }
    }

    Connections {
        objectName: "importControllerConnections"

        target: ImportController

        function onImportErrorOccurred(error, goToPageHome) {
            PageController.showErrorMessage(error)
        }

        function onRestoreAppConfig(data) {
            PageController.showBusyIndicator(true)
            SettingsController.restoreAppConfigFromData(data)
            PageController.showBusyIndicator(false)
        }
    }

    Connections {
        objectName: "settingsControllerConnections"

        target: SettingsController

        function onLoggingDisableByWatcher() {
            PageController.showNotificationMessage(qsTr("Logging was disabled after 14 days, log files were deleted"))
        }

        function onRestoreBackupFinished() {
            PageController.showNotificationMessage(qsTr("Settings restored from backup file"))
            PageController.goToPageHome()
        }

        function onLoggingStateChanged() {
            if (SettingsController.isLoggingEnabled) {
                var message = qsTr("Logging is enabled. Note that logs will be automatically" +
                                   "disabled after 14 days, and all log files will be deleted.")
                PageController.showNotificationMessage(message)
            }
        }
    }

    Connections {
        target: SubscriptionUiController

        function onErrorOccurred(error) {
            PageController.showErrorMessage(error)
        }
    }

    Connections {
        target: SubscriptionUiController

        function onApiConfigRemoved(message) {
            PageController.showNotificationMessage(message)
        }

        function onApiServerRemoved(message) {
            PageController.goToPageHome()
            PageController.showNotificationMessage(message)
        }

        function onInstallServerFromApiFinished(message, preferredDefaultIndex) {
            PageController.goToPageHome()
            PageController.showNotificationMessage(message)
        }

        function onBackgroundPurchaseCompleted(message) {
            PageController.showNotificationMessage(message)
        }

        function onChangeApiCountryFinished(message) {
            PageController.goToPageHome()
            PageController.showNotificationMessage(message)
        }

        function onReloadServerFromApiFinished(message) {
            PageController.goToPageHome()
            PageController.showNotificationMessage(message)
        }
    }

    StackViewType {
        id: tabBarStackView
        objectName: "tabBarStackView"

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: tabBar.top

        enabled: !root.isControlsDisabled

        function goToTabBarPage(page) {
            var pagePath = PageController.getPagePath(page)
            tabBarStackView.clear(StackView.Immediate)
            tabBarStackView.replace(pagePath, { "objectName" : pagePath }, StackView.Immediate)
        }

        Component.onCompleted: {
            if (productPreferences.languageChosen) {
                root.isTabBarShown = true
                var homePath = PageController.getPagePath(PageEnum.PageManubisHome)
                tabBarStackView.push(homePath, { "objectName" : homePath })
            } else {
                root.isTabBarShown = false
                var languagePath = PageController.getPagePath(PageEnum.PageManubisLanguage)
                tabBarStackView.push(languagePath, { "objectName" : languagePath })
            }
        }
    }

    TabBarType {
        id: tabBar
        objectName: "tabBar"

        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        visible: root.isTabBarShown
                 && tabBarStackView.depth <= 1
                 && !(tabBarStackView.currentItem && tabBarStackView.currentItem.isTabBarHidden === true)

        // Also adjust TabBar position when keyboard appears (Android 14+ workaround)
        anchors.bottomMargin: PageController.imeHeight

        height: visible ? implicitHeight : 0

        enabled: !root.isControlsDisabled && !root.isTabBarDisabled

        TabBarButtonType {
            id: homeTabButton
            objectName: "homeTabButton"

            text: qsTr("Home")
            icon.source: "qrc:/images/controls/home.svg"

            onClicked: {
                tabBarStackView.goToTabBarPage(PageEnum.PageManubisHome)
                tabBar.currentIndex = 0
            }
        }

        TabBarButtonType {
            id: storeTabButton
            objectName: "storeTabButton"
            text: qsTr("Store")
            icon.source: "qrc:/images/controls/plus.svg"
            onClicked: {
                tabBarStackView.goToTabBarPage(PageEnum.PageManubisStore)
                tabBar.currentIndex = 1
            }
        }

        TabBarButtonType {
            id: vpnTabButton
            objectName: "vpnTabButton"
            text: qsTr("Usage")
            icon.source: "qrc:/images/controls/activity.svg"
            onClicked: {
                tabBarStackView.goToTabBarPage(PageEnum.PageManubisDashboard)
                tabBar.currentIndex = 2
            }
        }

        TabBarButtonType {
            id: accountTabButton
            objectName: "accountTabButton"
            text: qsTr("Account")
            icon.source: "qrc:/images/controls/user-round.svg"
            onClicked: {
                tabBarStackView.goToTabBarPage(PageEnum.PageManubisAccount)
                tabBar.currentIndex = 3
            }
        }


    }
}
