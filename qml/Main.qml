import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "ui"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'permyhoh.holger'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    PageStack {
      id: pageStack
      anchors.fill: parent
      Component.onCompleted: {
        console.log("Starting...")
        pageStack.push(apps)
      }
      Page {
        id: apps
        anchors.fill: parent
        header: PageHeader {
          id: header
          title: i18n.tr("Applications")
        //        flickable: appsList leadingActionBar { width: 0 visible: false }
          trailingActionBar.actions: Action {
            id: aboutAction
            text:        i18n.tr("About")
            iconName: "help"
            onTriggered: {
              pageStack.push(Qt.resolvedUrl("./ui/AboutPage.qml"))
            }
          }
        }
        AppListModel {
          id: appEntry
          //folder: "file://./app/tests/data"
          // folder: "file:///var/lib/apparmor/clicks"
          folder: "file:///var/lib/apparmor/clicks"
        }

        ListView {
          id: appsList
//            objectName: "appsList"
          anchors.fill: parent
          model: appEntry.model

          delegate: ListItem {
            id: appDelegate

            height: appDelegateLayout.height + divider.height

            ListItemLayout {
              id: appDelegateLayout
              title.text: model.appname
              subtitle.text: 'Version: ' + model.version
              summary.text: 'Package: ' + model.pkgname
               ProgressionSlot{}
            }

            onClicked: {
              permsList.appid = model.appid
              permsList.profile = model.filename
              permsView.visible = true
              pageStack.push(permsView)
            }
          }
        } // apps
      }
      Page {
    id: permsView

    header: PageHeader {
        title: i18n.tr("Permissions")
        flickable: permsList
    }

    visible: false

    ListView {
        id: permsList
        objectName: "permsList"
        anchors.fill: parent

        property var profile: ""
        property var appid: ""

        AppModel {
            id: permEntry
            query: "$"
        }
        model: permEntry.model

        onAppidChanged: {
            permEntry.appid = appid
        }
        onProfileChanged: {
            if (profile) {
                permEntry.source = Qt.resolvedUrl(profile)
            }
        }

        delegate: permDelegate
    }

    Component {
        id: permDelegate
        Column {
            id: column
            width: parent.width

            SubtitledListItem {
                title.text: "APP ID: "
                subtitle.text: appid
            }
            SubtitledListItem {
                title.text: "Policy vendor:"
                subtitle.text: policy_vendor
            }
            SubtitledListItem {
                title.text: "Policy version:"
                subtitle.text: policy_version
            }
            SubtitledListItem {
                title.text: "Policy template:"
                subtitle.text: template
            }
            ListItem {
                id: policyDelegate

                height: policyDelegateLayout.height + divider.height

                ListItemLayout {
                    id: policyDelegateLayout
                    title.text: "Policy groups:"
                    subtitle.text: policy_groups
                    subtitle.maximumLineCount: 3
                    ProgressionSlot{}
                }

                onClicked: {
                    policyGroupsList.vendor = policy_vendor
                    policyGroupsList.version = policy_version
                    // Coordinate this split with ui/AppModel.qml
                    policyGroupsList.groups = policy_groups.replace("<i><s>", "").replace("</s></i>", "").split(", ")
                    policyGroupsView.visible = true
                    pageStack.push(policyGroupsView)
                }
            }
            SubtitledListItem {
                title.text: "Additional abstractions:"
                subtitle.text: abstractions
            }
            SubtitledListItem {
                title.text: "Additional read paths:"
                subtitle.text: read_path
            }
            SubtitledListItem {
                title.text: "Additional write paths:"
                subtitle.text: write_path
            }
        }
    }
} // permsView
Page {
            id: policyGroupsView

            header: PageHeader {
                title: i18n.tr("Policy Groups")
                flickable: policyGroupsList
            }

            visible: false

            ListView {
                id: policyGroupsList
                objectName: "policyGroupsList"
                anchors.fill: parent

                property var vendor: ""
                property var version: ""
                property var groups: []

                PolicyGroupsModel {
                    id: policyGroupsEntry
                    source: Qt.resolvedUrl("./ui/policy-groups.json")
                    query: "$"
                }
                model: policyGroupsEntry.model

                onVendorChanged: {
                    policyGroupsEntry.vendor = vendor
                }

                onVersionChanged: {
                    // SDK uses '1' for '1.0', so account for that
                    policyGroupsEntry.version = version.toFixed(1)
                }

                onGroupsChanged: {
                    policyGroupsEntry.groups = groups
                }

                delegate: policyGroupsDelegate
            }

            Component {
                id: policyGroupsDelegate
                Column {
                    id: column
                    width: parent.width

                    SubtitledListItem {
                        title.text: group + " (" + usage + ")"
                        summary.text: description
                    }
                }
            }
        } // policyGroupsView
    }
  }
