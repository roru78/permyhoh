/* Based on:
 * JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence
 * (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.4
import "jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string appid: ""
    property string json: ""
    property string query: ""
    property string override_json: ""
    property var policy_group_overrides: null
    property var abstraction_overrides: null
    property var read_path_overrides: null
    property var write_path_overrides: null

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    onSourceChanged: {
        console.log("Loading " + source)
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                json = xhr.responseText;
                //console.log("JSON: " + json)
            }
        }

        console.log("Loading " + source + ".override")
        var xhr2 = new XMLHttpRequest;
        xhr2.open("GET", source + ".override");
        xhr2.onreadystatechange = function() {
            if (xhr2.readyState == XMLHttpRequest.DONE) {
                override_json = xhr2.responseText;
                //console.log("Override JSON: " + override_json)
            }
        }
        xhr2.send();
        xhr.send();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function updateJSONModel() {
        //console.log("Updating JSON Model")
        jsonModel.clear();

        if ( json === "" )
            return;

        if ( override_json !== "" ) {
            var overrideObjectArray = parseJSONString(override_json, query)
            if (overrideObjectArray.length !== 1) {
                console.log("ERROR: malformed override file")
            } else {
                for ( var key in overrideObjectArray ) {
                    var ojo = overrideObjectArray[key]
                    if (ojo.policy_groups && ojo.policy_groups.length > 0)
                        policy_group_overrides = ojo.policy_groups
                    if (ojo.abstractions && ojo.abstractions.length > 0)
                        abstraction_overrides = ojo.abstractions
                    if (ojo.read_path && ojo.read_path.length > 0)
                        read_path_overrides = ojo.read_path
                    if (ojo.write_path && ojo.write_path.length > 0)
                        write_path_overrides = ojo.write_path
                }
            }
        }

        var objectArray = parseJSONString(json, query);
        for ( var key in objectArray ) {
            var jo = objectArray[key];

            // Set a few defaults to make sure the delegate has everything it
            // needs
            jo.appid = appid

            if (!jo.template)
                jo.template = "ubuntu-sdk"

            if (!jo.policy_vendor)
                jo.policy_vendor = "ubuntu"

            // IMPORTANT: the QListViewModel needs strings, so split them out
            // with a common delimiter. If this changes, will need to adjust
            // any splits on this to get the list back (eg, main.qml)
            var list_delim = ", "

            if (jo.policy_groups && jo.policy_groups.length > 0) {
                var l = []
                for (var i=0; i<jo.policy_groups.length; i++) {
                    if (policy_group_overrides !== null &&
                        policy_group_overrides.indexOf(jo.policy_groups[i]) > -1)
                        l.push("<i><s>" + jo.policy_groups[i] + "</s></i>")
                    else
                        l.push(jo.policy_groups[i])
                }
                jo.policy_groups = l.join(list_delim)
            } else
                jo.policy_groups = "None"

            if (jo.abstractions && jo.abstractions.length > 0) {
                var l = []
                for (var i=0; i<jo.abstractions.length; i++) {
                    if (abstraction_overrides !== null &&
                        abstraction_overrides.indexOf(jo.abstractions[i]) > -1)
                        l.push("<i><s>" + jo.abstractions[i] + "</s></i>")
                    else
                        l.push(jo.abstractions[i])
                }
                jo.abstractions = l.join(list_delim)
            } else
                jo.abstractions = "None"

            if (jo.read_path && jo.read_path.length > 0) {
                var l = []
                for (var i=0; i<jo.read_path.length; i++) {
                    if (read_path_overrides !== null &&
                        read_path_overrides.indexOf(jo.read_path[i]) > -1)
                        l.push("<i><s>" + jo.read_path[i] + "</s></i>")
                    else
                        l.push(jo.read_path[i])
                }
                jo.read_path = l.join(list_delim)
            } else
                jo.read_path = "None"

            if (jo.write_path && jo.write_path.length > 0) {
                var l = []
                for (var i=0; i<jo.write_path.length; i++) {
                    if (write_path_overrides !== null &&
                        write_path_overrides.indexOf(jo.write_path[i]) > -1)
                        l.push("<i><s>" + jo.write_path[i] + "</s></i>")
                    else
                        l.push(jo.write_path[i])
                }
                jo.write_path = l.join(list_delim)
            } else
                jo.write_path = "None"

            jsonModel.append( jo );
        }
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }
}
