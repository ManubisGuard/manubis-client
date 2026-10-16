import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore

import PageEnum 1.0
import "../Manubis"
import "../Controls2"

PageType {
    id: root
    objectName: "PageManubisLanguage"

    Settings {
        id: languageSettings
        category: "ManubisGuard"
        property bool languageChosen: false
        property string languageCode: ""
    }

    property string selectedCode: languageSettings.languageCode
    property string selectedName: ""

    Component.onCompleted: {
        if (selectedCode === "") {
            if (LanguageUiController.currentLanguageIndex === 4) selectedCode = "fa"
            else if (LanguageUiController.currentLanguageIndex === 1) selectedCode = "ru"
            else selectedCode = "en"
        }
    }

    function chooseLanguage(code, enumIndex, name) {
        selectedCode = code
        selectedName = name
        LanguageUiController.changeLanguage(enumIndex)
        languageSettings.languageCode = code
        languageSettings.languageChosen = true
        PageController.goToPage(PageEnum.PageManubisHome, false)
    }

    Rectangle {
        anchors.fill: parent
        color: ManubisTheme.background
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0C1426" }
            GradientStop { position: 0.55; color: ManubisTheme.background }
            GradientStop { position: 1.0; color: "#100E22" }
        }
    }

    Rectangle {
        width: 240; height: 240; radius: 120
        x: root.width * 0.5 - width * 0.5; y: -120
        color: "#193D70"; opacity: 0.22
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        anchors.topMargin: 36 + PageController.safeAreaTopMargin
        anchors.bottomMargin: 24 + PageController.safeAreaBottomMargin
        spacing: 0

        Item { Layout.fillHeight: true; Layout.maximumHeight: 48 }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 66
            Layout.preferredHeight: 66
            radius: 22
            color: "#172941"
            border.color: "#3D718D"
            border.width: 1
            Text {
                anchors.centerIn: parent
                text: "M"
                color: ManubisTheme.cyan
                font.pixelSize: 34
                font.weight: Font.DemiBold
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: 20
            text: "MANUBIS GUARD"
            color: ManubisTheme.textPrimary
            font.pixelSize: 23
            font.weight: Font.DemiBold
            font.letterSpacing: 2.1
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: 10
            text: qsTr("Choose your language")
            color: ManubisTheme.textSecondary
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: 5
            text: qsTr("Выберите язык  ·  زبان برنامه را انتخاب کنید")
            color: ManubisTheme.textMuted
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 34
            spacing: 12

            Repeater {
                model: [
                    { "code": "fa", "name": "فارسی", "detail": "Persian · فارسی", "index": 4 },
                    { "code": "en", "name": "English", "detail": "English", "index": 0 },
                    { "code": "ru", "name": "Русский", "detail": "Russian · Русский", "index": 1 }
                ]
                delegate: Button {
                    id: languageButton
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 68
                    padding: 16
                    hoverEnabled: true
                    background: Rectangle {
                        radius: 18
                        color: root.selectedCode === languageButton.modelData.code ? "#1B3149" : "#0D1728"
                        border.width: root.selectedCode === languageButton.modelData.code ? 1.5 : 1
                        border.color: root.selectedCode === languageButton.modelData.code ? ManubisTheme.cyan : ManubisTheme.border
                    }
                    contentItem: RowLayout {
                        spacing: 14
                        Rectangle {
                            Layout.preferredWidth: 34; Layout.preferredHeight: 34; radius: 12
                            color: "#1B2C44"
                            Text {
                                anchors.centerIn: parent
                                text: languageButton.modelData.code.toUpperCase()
                                color: ManubisTheme.cyan
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Text {
                                Layout.fillWidth: true
                                text: languageButton.modelData.name
                                color: ManubisTheme.textPrimary
                                font.pixelSize: 15
                                font.weight: Font.Medium
                            }
                            Text {
                                Layout.fillWidth: true
                                text: languageButton.modelData.detail
                                color: ManubisTheme.textMuted
                                font.pixelSize: 11
                            }
                        }
                        Text {
                            text: root.selectedCode === languageButton.modelData.code ? "✓" : "›"
                            color: root.selectedCode === languageButton.modelData.code ? ManubisTheme.cyan : ManubisTheme.textMuted
                            font.pixelSize: 20
                        }
                    }
                    onClicked: root.chooseLanguage(modelData.code, modelData.index, modelData.name)
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: 22
            text: qsTr("Private by design. Simple by nature.")
            color: ManubisTheme.textMuted
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
        }

        Item { Layout.fillHeight: true }
    }
}
