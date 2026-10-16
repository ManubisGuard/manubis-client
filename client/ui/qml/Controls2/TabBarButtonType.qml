import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl

import Style 1.0

TabButton {
    id: root

    property bool showBadge: false

    hoverEnabled: true

    topPadding: 4
    bottomPadding: 4
    leftPadding: 0
    rightPadding: 0

    icon.width: 24
    icon.height: 24
    icon.color: root.checked ? AmneziaStyle.color.accentLight : AmneziaStyle.color.iconDefault

    Accessible.name: root.text

    background: Item {
        implicitHeight: 32

        FocusRingType {
            radius: 12
            visible: root.visualFocus
        }
    }

    contentItem: Column {
        spacing: 2

        IconImage {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 20
            height: 20
            source: root.icon.source
            sourceSize: Qt.size(width, height)
            color: root.icon.color

            DotBadgeType {
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.top
                visible: root.showBadge
                color: AmneziaStyle.color.accentDefault
            }
        }

        Text {
            width: parent.width
            text: root.text
            color: root.checked ? AmneziaStyle.color.accentLight : AmneziaStyle.color.textSecondary
            font.pixelSize: 9
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    implicitWidth: 64
    implicitHeight: 44

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    Keys.onEnterPressed: root.clicked()
    Keys.onReturnPressed: root.clicked()
}
