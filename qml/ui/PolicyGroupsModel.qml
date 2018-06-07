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
    property string json: ""
    property string query: "$"
    property string vendor: ""
    property string version: ""
    property variant groups: []

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    onSourceChanged: {
        console.log("Loading " + source)
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE)
                json = xhr.responseText;
                //console.log("JSON: " + json)
        }
        xhr.send();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()
    onVendorChanged: updateJSONModel()
    onVersionChanged: updateJSONModel()
    onGroupsChanged: updateJSONModel()

    function contains(arr, obj) {
        var i = arr.length;
        while (i--) {
            //console.log("Checking " + obj + " is in " + arr[i])
            if (arr[i] === obj) {
                return true;
            }
        }
        return false;
    }

    function updateJSONModel() {
        console.log("Updating JSON Model")
        jsonModel.clear();

        if ( json === "" )
            return;

        if ( vendor === "" )
            return;

        if ( version === "" )
            return;

        var objectArray = parseJSONString(json, query);

        for ( var key in objectArray ) {
            var jo = objectArray[key];
            if (!jo.hasOwnProperty(vendor)) {
                console.log("Could not find vendor '" + vendor + "' in results")
                continue
            }
            if (!jo[vendor].hasOwnProperty(version)) {
                console.log("Could not find version '" + version + "' in results")
                continue
            }

            for ( var account in jo[vendor][version]) {
                if (!contains(groups, account))
                    continue

                var obj = new Object()
                obj.group = account

                obj.usage = "Usage unknown"
                if (jo[vendor][version][account].hasOwnProperty("usage"))
                    obj.usage = jo[vendor][version][account]["usage"]

                obj.description = "Description unknown"
                if (jo[vendor][version][account].hasOwnProperty("description"))
                    obj.description = jo[vendor][version][account]["description"]

                jsonModel.append( obj );
            }
        }
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }
}
