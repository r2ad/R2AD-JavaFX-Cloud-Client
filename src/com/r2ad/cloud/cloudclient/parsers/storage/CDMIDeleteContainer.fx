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

import java.io.InputStream;
import javafx.data.pull.Event;
import javafx.data.pull.PullParser;
import org.occi.model.OCCIStorageType;
import javafx.io.http.HttpHeader;
import com.r2ad.cloud.cloudclient.controller.Controller;
import javafx.io.http.HttpRequest;

/*
 * The <code>CDMIDeleteContainer</code> deletes a container per the CDMI specification.
 * This version uses the PullParser API to parse results in JSON.
 * Created on Mar 7, 2010, 10:51:23 PM
 * @copyright Copyright 2010, R2AD, LLC.
 * @author behrens@r2ad.com
 */


    /**
    * Obtain the controller via the singleton - this is temporary code:
    */
    public var controller: Controller = bind controller.controller;


    public function deleteContainer(stringID: String) : Void {
        var resultsProcessor: function(is: InputStream) : Void;
        var connection = controller.dataManager.getStorageConnection();
        println("DeleteContainer: Deleting: {stringID}");
        var authenticationHeader = HttpHeader.basicAuth("demo", "clouddemo");

        var acceptHeader = HttpHeader {
               name: HttpHeader.ACCEPT,
               value:"application/vnd.org.snia.cdmi.container+json"
            };
        var contentHeader = HttpHeader {
               name: HttpHeader.CONTENT_TYPE;
               value:"application/vnd.org.snia.cdmi.container+json"
            };
        var versionHeader = HttpHeader {
               name: "HttpHeader.X-CDMISpecification-Version";
               value:"1.0"
            };
        var request : HttpRequest = HttpRequest {
            location: "{connection.connection}/{stringID}";
            headers: [authenticationHeader, contentHeader, acceptHeader, versionHeader]
            method: HttpRequest.DELETE

            onStarted: function() {
               println("onStarted - started performing method");
            }
            onConnecting: function() { println("DeleteContainer: connecting...") }
            onDoneConnect: function() { println("DeleteContainer: doneConnect") }
            onReadingHeaders: function() { println("DeleteContainer: readingHeaders...") }
            onResponseCode: function(code:Integer) { 
                println("DeleteContainer: responseCode: {code}");
                //controller.dataManager.removeStorageType(stringID);
                if (code == 405) {
                    println("DeleteContainer: Not Allowed!  Return FAIL");
                    connection.updateStatus("Code 405 - not allowed", true);
                }
                if (code == 400) {
                    println("DeleteContainer: Bad Request!  Return FAIL");
                    connection.updateStatus("Code 400 - Bad Request", true);
                }
                if (code == 500) {
                    println("DeleteContainer: Internal error  Return FAIL");
                    connection.updateStatus("Code 500 - Internal Error", true);
                }
                if (code == 200) {
                    println("DeleteContainer: Deleted okay");
                    connection.updateStatus("Delete successful");
                }
            }
            onResponseMessage: function(msg:String) { println("DeleteContainer:  responseMessage: {msg}") }
            onToRead: function(bytes: Long) { println("bytes to read: {bytes}") }
            onWriting: function() { println("DeleteContainer: Writing...") }
            onDoneWrite: function() { println("DeleteContainer: onDoneWrite") }
            onDone: function() { println("DeleteContainer: onDone") }
            // The onRead callback is called when some more data has been read into
            // the input stream's buffer.  The input stream will not be available until
            // the onInput call back is called, but onRead can be used to show the
            // progress of reading the content from the location.
            onRead: function(bytes: Long) {
                println("DeleteContainer: bytes read: {bytes}");
            }

            onInput: function(is: InputStream) {
                resultsProcessor = processResults;
                resultsProcessor(is);
                try {
                    println("DeleteContainer: bytes of content available: {is.available()}");
                } finally {
                    is.close();
                }

            }
        }
        request.start();
    }


public function processResults(is: InputStream) : Void {
    def parser = PullParser { documentType: PullParser.JSON; input: is; onEvent: parseEventCallback; };
    parser.parse();
    is.close();
}

var result: OCCIStorageType;

def parseEventCallback = function(event: Event) {
    //START_VALUE=25, START_ELEMENT=1, START_DOCUMENT=7, START_ARRAY=16
    //START_ARRAY_ELEMENT=17, END_ARRAY_ELEMENT=18, END_ELEMENT=2
    println("DeleteContainer: event.type: {event.type} event.name: {event.name} event.text={event.text} event.level={event.level} ");
    if (event.type == PullParser.START_ARRAY_ELEMENT) {
       // Assume a new model is needed....
        println("DeleteContainer: ** Deleting an existing Container");
    }

    if (event.type == PullParser.END_ARRAY_ELEMENT) {
        if (event.name == "children" and event.level == 0) {
            if (event.text.length() > 0) {
                result.setTitle(event.text);
                println("DeleteContainer:  Invoking Delete from here or vice versa {event.text}");
            }
        }
    }
}

