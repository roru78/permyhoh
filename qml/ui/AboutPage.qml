import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: about

    header: PageHeader {
        title: i18n.tr("About")
        flickable: flickable
    }

    anchors.fill: parent

    Flickable {
        id: flickable

        anchors.fill: parent
        contentHeight: aboutColumn.height + units.gu(6)

        Column {
            id: aboutColumn
            spacing: units.gu(3)
            width: parent.width
            y: units.gu(2)
            // Utilize image with transparency
            UbuntuShape {
                width: Math.round(parent.width * .4)
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                UbuntuShape {
                    image: Image {
                        source: "../../assets/about_permy.png"
                    }
                    anchors.fill: parent
                }
            }
            Grid {
                id: grid
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 2
                spacing: units.gu(1)
                Label {
                    font.bold: true;
                    text: i18n.tr("Version: ")
                }
                Label {
                    // FIXME: sync this with manifest somehow
                    text: "1.0.0"
                }
                Label {
                    font.bold: true;
                    text: i18n.tr("Author: ")
                }
                Label {
                    text: "Holger Höhnemann"
                }
                Label {
                    font.bold: true;
                    text: i18n.tr("Contributors: ")
                }
                Label {
                    text: "Jamie Strandboge Nekhelesh Ramananthan"
               }
                Label {
                    font.bold: true;
                    text: i18n.tr("Icon: ")
                }
                Label {
                    text: "Michael Zanetti"
                }
                Label {
                    font.bold: true;
                    text: i18n.tr("Home page: ")
                }
                Label {
                    id: urlLabel
                    text: "<a href=\"https://github.com/hoh61/permyhoh\">https://github.com/hoh61/permyhoh</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    font.bold: true;
                    text: i18n.tr("Reference: ")
                }
                Label {
                    text: "<a href=\"http://developer.ubuntu.com/apps/platform/guides/app-confinement/\">Click security permissions</a>"
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    font.bold: true;
                    text: i18n.tr("Description: ")
                }
                Label {
                    wrapMode: Text.WordWrap
                    width: (about.width * .6 > urlLabel.width) ? about.width * .6 : urlLabel.width
                    text: "Permy is a permissions viewer for click apps and will show various pieces of information related to security policy including the APP ID, policy vendor, policy version, template, policy groups and more. If any policy groups, abstractions, read paths or write paths are italicized they have been removed from the application's policy. Permyhoh is a porting of the original permy app to the UBport environment"
                }
            }
        }
    }
}
