import QtQuick 2.4
import Ubuntu.Components 1.3

ListItem {
    id: listItem

    property alias title: layout.title
    property alias subtitle: layout.subtitle
    property alias summary: layout.summary

    height: layout.height + divider.height

    ListItemLayout {
        id: layout
        subtitle.maximumLineCount: 2
        summary.wrapMode: Text.WordWrap
        summary.maximumLineCount: 5
    }
}

