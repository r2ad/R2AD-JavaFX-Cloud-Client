/**
 DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
 Copyright (c) 2010, R2AD, LLC
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the R2AD, LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package com.r2ad.cloud.cloudclient.parsers.storage;
/*
 * The <code>CDMIContainerDetails</code> sends a CDMI GET request to get the contents of
 * a CDMI compliant container resource.
 * This version uses the PullParser API to parse results in JSON.
 * Created on Mar 7, 2010, 10:51:23 PM
 * @copyright Copyright 2010, R2AD, LLC.
 * @author behrens@r2ad.com
 */

import java.io.InputStream;
import javafx.data.pull.Event;
import javafx.data.pull.PullParser;
import javafx.io.http.HttpHeader;
import com.r2ad.cloud.cloudclient.controller.Controller;
import javafx.io.http.HttpRequest;
import java.net.URI;
import org.occi.model.OCCIStorageType;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
* Obtain the controller via the singleton - this is temporary code:
*/
public var controller: Controller = bind controller.controller;
var myName = "CDMIContainerDetails";
var storageItem : OCCIStorageType;
var objectURI : URI;
var objectURIText: String;
//var result: CDMIContainer;
var result: OCCIStorageType;
var connection = controller.dataManager.getStorageConnection();

var objectID: String;

/*
** specify Locale.US since months are in english
** example: 2010-06-02T16:58:36
*/
def timeFormat: SimpleDateFormat = new SimpleDateFormat ("yyyy-dd-MM'T'HH:mm:ss", Locale.US);

// Information about all relevant cloud nodes
//public var cloudNodes: NodeModel[];

public function getContainerDetails(relativeURL: String) : Void {
    var resultsProcessor: function(is: InputStream) : Void;

    println("{myName}: getDetails from {relativeURL} to: {connection}");

    var acceptHeader = HttpHeader {
           name: HttpHeader.ACCEPT,
           value:"application/cdmi-container"
        };
    var contentHeader = HttpHeader {
           name: HttpHeader.CONTENT_TYPE;
           value:"application/cdmi-container" //"application/vnd.org.snia.cdmi.container+json"
        };
    var versionHeader = HttpHeader {
           name: "X-CDMI-Specification-Version";
           value:"1.0"
        };
    var request : HttpRequest = HttpRequest {
       // TBD: Actually, need to get the path to the resource
        location: "{connection.connection}/{relativeURL}";
        // Took out version to support Ilja's server'
        headers: [contentHeader, acceptHeader] //, versionHeader
        method: HttpRequest.GET

        onStarted: function() {
           println("{myName}: onStarted location: {request.location}");
        }
        onConnecting: function() { println("{myName}:Connecting to {request.location}") }
        onDoneConnect: function() { println("{myName}:doneConnect") }
        onReadingHeaders: function() { println("{myName}:readingHeaders...") }
        onResponseCode: function(code:Integer) {
            println("{myName}: responseCode: {code}");
            if (code == 405) {
                println("{myName}: Not Allowed!  Return FAIL");
                connection.updateStatus("{myName}:Code 405 - not allowed", true);
            }
            if (code == 400) {
                println("{myName}: Bad Request!  Return FAIL");
                connection.updateStatus("{myName}:Code 400 - Bad Request", true);
            }
            if (code == 500) {
                println("{myName}: Internal error  Return FAIL");
                connection.updateStatus("{myName}:Code 500 - Internal Error", true);
            }
            if (code == 200) {
                println("{myName}: Successful Connection");
            }
        }
        onResponseMessage: function(msg:String) { println("responseMessage: {msg}") }
        onToRead: function(bytes: Long) { 
          // println("bytes to read: {bytes}")
        }

        // The onRead callback is called when some more data has been read into
        // the input stream's buffer.  The input stream will not be available until
        // the onInput call back is called, but onRead can be used to show the
        // progress of reading the content from the location.
        onRead: function(bytes: Long) {
            println("{myName}: bytes read: {bytes}");
        }

        onInput: function(is: InputStream) {
            resultsProcessor = processResults;
            resultsProcessor(is);
            try {
                println("{myName}: bytes of content available: {is.available()}");
            } finally {
                is.close();
                var debugStorage: OCCIStorageType =controller.dataManager.getStorageType(objectURIText);
                println("{myName}: Finished Parsing container: {debugStorage.getString()}");
                connection.updateStatus("Parsed: {relativeURL}");
            }

        }
    }
    request.start();

}

public function processResults(is: InputStream) : Void {
    def parser = PullParser { documentType: PullParser.JSON; input: is; onEvent: parseEventCallback; };
    parser.parse();
    is.close();
    controller.dataManager.insertStorageType(result);
    println("{myName}: OCCI Storage Type inserted into Model: {result.getString()}");
    controller.cloudView.loadStorageList();
}


def parseEventCallback = function(event: Event) {
    //START_VALUE=25, START_ELEMENT=1, START_DOCUMENT=7, START_ARRAY=16
    //START_ARRAY_ELEMENT=17, END_ARRAY_ELEMENT=18, END_ELEMENT=2
    // END_DOCUMENT=8, END_ELEMENT=2, END_ARRAY_ELEMENT=18, TEXT=4
    // START_ARRAY_ELEMENT=17, END_ARRAY_ELEMENT=18,
    //println(">>> {myName}:  event.type: {event.type} event.name: {event.name} event.text={event.text} event.level={event.level} ");
    if (event.type == PullParser.START_DOCUMENT) {
        println("{myName}: ** Creating new empty Storage Model");
        result = OCCIStorageType{}
    }
    if (event.type == PullParser.END_VALUE) {
        if (event.name == "objectURI" and event.level == 0) {
            if (event.text.length() > 0) {
                objectURIText = event.text.substring(1, event.text.length());

                objectURI = new URI("{connection.connection}/{objectURIText}");
                println("{myName}: objectURI: {objectURIText} obtained");

                //var storage: OCCIStorageType =controller.dataManager.getStorageType(objectURIText);
                //
                // Assume that the Full URL is better...
                // Not sure, since main URL may change - maybe keeping relative is best?
                //
                result.setTitle(objectURIText);
                result.setURI(objectURI);

            }
        }
    }
    if (event.type == PullParser.END_VALUE) {
        if (event.name == "objectID" and event.level == 0) {
            if (event.text.length() > 0) {
                if (event.text != null ) {
                    objectID = event.text;
                    println("{myName}: objectID obtained: {event.text} for objectURI: {objectURIText}");
                    // Found a container:
                    //result.setTitle(event.text);
                    println("{myName}: ** Invoking dataHandler.addOCCIStorageType for {event.text}");
                    var storelink: URI;
                    storelink = new URI("{connection.connection}/{objectURIText}");

                    result.addLink(storelink);

                    // Not sure what to do here...probably only create if it is an object:
                    // result = new CDMIContainer(objectURI, objectID);

                    // Get the current model for this objectURI and update its object ID:
                    //var storage: OCCIStorageType =controller.dataManager.getStorageType(objectURIText);
                    println("{myName}: objectID obtained: {objectURI}  storage: {result.getString()}");
                    storageItem.setID(objectID);
                    result.setID(objectID);

                }
            }
        } else if (event.name == "cdmi_ctime" and event.level == 1) {
            println("{myName}: CTime obtained: {event.text} for {objectURIText}");
            if (event.text != "never") {
               var datetime: Date;
               datetime = timeFormat.parse(event.text);
               result.setCreateTime(datetime);
            }
        } else if (event.name == "cdmi_atime" and event.level == 1) {
            println("{myName}: ATime obtained: {event.text} for {objectURIText}");
            if (event.text != "never") {
               var datetime: Date;
               datetime = timeFormat.parse(event.text);
               result.setAccessTime(datetime);
            }
        } else if (event.name == "cdmi_mtime" and event.level == 1) {
            println("{myName}: MTime obtained: {event.text} for {objectURIText}");
            if (event.text != "never") {
               var datetime: Date;
               datetime = timeFormat.parse(event.text);
               result.setModifiedTime(datetime);
            }
        } 

        // Not Parsing these events at this time:
        // OCCI/NFS event.text= event.level=1
        // exports event.text= event.level=0
        // parentURI event.text=/ event.level=0
        // capabilitiesURI event.text=/cdmi_capabilities/container/default event.level=0

     } // End Value

     if (event.type == PullParser.TEXT) {
        if (event.name == "children" and event.level == 0) {
            // Example: >>> CDMIContainerDetails:  event.type: 4 event.name: children event.text=foo.txt event.level=0
            println("{myName}: >>> child object identified: {event.text} for parent {objectURIText}");
        }

     }

}

   
