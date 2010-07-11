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
import java.lang.Exception;
import javafx.io.http.HttpHeader;
import com.r2ad.cloud.cloudclient.controller.Controller;
import javafx.io.http.HttpRequest;

/**
 * @author JavaFX@r2ad.com
 */

    /**
    * Obtain the controller via the singleton - this is temporary code:
    */
    public var controller: Controller = bind controller.controller;

    // Information about all relevant cloud nodes
    //public var cloudNodes: NodeModel[];

    public function getContainers() : Void {
        var resultsProcessor: function(is: InputStream) : Void;
        var connection = controller.dataManager.getStorageConnection();
        println("Connecting to: {connection}");

        var acceptHeader = HttpHeader {
               name: HttpHeader.ACCEPT,
               value:"application/vnd.org.snia.cdmi.dataobject+json"
            };
        var contentHeader = HttpHeader {
               name: HttpHeader.CONTENT_TYPE;
               value:"application/vnd.org.snia.cdmi.dataobject+json"
            };
        var request : HttpRequest = HttpRequest {
            location: connection.connection;
            headers: [contentHeader, acceptHeader]
            method: HttpRequest.GET

            onStarted: function() {
               println("onStarted - started performing method");
            }
            onConnecting: function() { println("connecting...") }
            onDoneConnect: function() { println("doneConnect") }
            onReadingHeaders: function() { println("readingHeaders...") }
            onResponseCode: function(code:Integer) { println("responseCode: {code}") }
            onResponseMessage: function(msg:String) { println("responseMessage: {msg}") }
            onToRead: function(bytes: Long) { println("bytes to read: {bytes}") }

            // The onRead callback is called when some more data has been read into
            // the input stream's buffer.  The input stream will not be available until
            // the onInput call back is called, but onRead can be used to show the
            // progress of reading the content from the location.
            onRead: function(bytes: Long) {
                println("bytes read: {bytes}");
            }

            onInput: function(is: InputStream) {
                resultsProcessor = processResults;
                resultsProcessor(is);
                try {
                    println("bytes of content available: {is.available()}");
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
    println("event.type: {event.type} event.name: {event.name} event.text={event.text} event.level={event.level} ");
    if (event.type == PullParser.START_ARRAY_ELEMENT) {
       // Assume a new model is needed....
        println("** Creating new empty Storage Object Model");
        result = OCCIStorageType{}
    }

    if (event.type == PullParser.END_ARRAY_ELEMENT) {
        if (event.name == "children" and event.level == 0) {
            if (event.text.length() > 0) {
                result.setTitle(event.text);
                println("** Invoking dataHandler.addOCCIStorageType for {event.text}");
                controller.dataManager.addStorageType(result);
                println("CMDI Storage: {result}");
            }
        }
    }
}

    // Example validation function which cna be used for some fields
    function validateZipCode(zipcode:String): Boolean {
        //
        // Zip Code Format -> 12345 or 12345-1234
        //
        try {
            if(zipcode.length() == 5) {
                var zipCodeInt = java.lang.Integer.valueOf(zipcode).intValue();
                return (zipCodeInt > 0);
            } else if (zipcode.length() == 10) {
                var dashIndex = zipcode.indexOf("-");
                if(dashIndex != 5) return false;
                var firstPart = zipcode.substring(0, dashIndex);
                var zipCodeInt = java.lang.Integer.valueOf(firstPart).intValue();
                if(zipCodeInt <= 0) { return false; }
                var secondPart = zipcode.substring(0, dashIndex);
                zipCodeInt = java.lang.Integer.valueOf(secondPart).intValue();
                return (zipCodeInt > 0);
            }
        } catch (e:Exception) { }
        return false;
    }


    // Trim the string if length is greater than specified length
    function trimString(string:String, length:Integer) : String {
        if(string == null) return "";
        if(string.length() > length) {
            return "{string.substring(0, length).trim()}...";
        } else {
            return string;
        }
    }

