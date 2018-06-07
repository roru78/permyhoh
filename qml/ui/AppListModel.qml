import QtQuick 2.4
import Qt.labs.folderlistmodel 2.1

Item {
    property var folder

    FolderListModel {
        id: folderModel
        nameFilters: ["*.json"]
        showDirs: false
        showDotAndDotDot: false
        showFiles: true
        showHidden: false
        sortField: "Name"

        onCountChanged: {
            if (count > 0) {
                updateModel()
            } else {
                console.log("Could not find any security manifests")
            }
        }
    }

    property ListModel model : ListModel { id: manifestModel }
    property alias count: manifestModel.count

    onFolderChanged: folderModel.folder = folder

    function updateModel() {
        var entries = new Array();
        manifestModel.clear();
        if (folderModel.count === 0) {
            console.log("Could not find any security manifests")
            return;
        }

        for (var i = 0; i < folderModel.count; i++) {
            var bn = new String(folderModel.get(i, "fileName"));
            if(bn.lastIndexOf(".") != -1)
                bn = bn.substring(0, bn.lastIndexOf("."));
            //console.log("  found:" + bn)
            var tmp = bn.split('_')
            if (tmp.length !== 3) {
                console.log("SKIPPING: " + bn + " (malformed APP_ID)")
                continue
            }
            entries.push({"filename": folderModel.get(i, "filePath"),
                                  "appid": bn,
                                  "pkgname": tmp[0],
                                  "appname": tmp[1],
                                  "version": tmp[2]})
        }
        entries.sort(function(a,b) {
            var x = a.appname.toLowerCase();
            var y = b.appname.toLowerCase();
            return x < y ? -1 : x > y ? 1 : 0;
        });
        for (var i = 0; i < entries.length; i++) {
            manifestModel.append(entries[i])
        }
    }
}
