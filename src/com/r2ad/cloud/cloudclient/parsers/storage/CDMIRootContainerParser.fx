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

import com.r2ad.cloud.cloudclient.controller.Controller;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.data.pull.Event;
import javafx.data.pull.PullParser;
import javafx.io.http.HttpHeader;
import javafx.io.http.HttpRequest;
import java.io.InputStream;
import java.lang.Thread;
import com.r2ad.cloud.cloudclient.utils.StringUtilities;


/*
 * The <code>CDMIRootcontainerParser</code> is the CDMI Root Parser which
 * implements a portion of the CDMI specification.
 * This version uses the PullParser API to parse results in JSON.
 * Created on Mar 7, 2010, 10:51:23 PM
 * @author behrens@r2ad.com
*/
    def strings: StringUtilities = new StringUtilities();

    /**
    * Obtain the controller via the singleton - this is temporary code:
    */
    public var controller: Controller = bind controller.controller;
    //var traceLevel = Trace.getLevel("RootCDMIParser");
    var resultsProcessor: function(is: InputStream) : Void;
    var connection;
    var myName = "CDMIRoot";

        /**
         * Not being used...pull parser seems work okay.
         * Timeline that executes the parsing in a background thread, this way,
         * The GUI can continue to function.  Not sure what the effect will be
         * on GUI when updating from this code - we'll see.
         * Consider javafx.data.pull.ParserTask as well.
         */
        var parserTimeline: Timeline = Timeline {
            repeatCount: 1
            keyFrames: [
                KeyFrame {
                    time: 1s
                    canSkip: true
                    action: function() {
                         println("{myName}: Timer Thread ID: {Thread.currentThread()}");
                         controller.dataManager.getStorageConnection().updateStatus("1sec rootCDMI");
                    }
                }
                KeyFrame {
                    time: 2s
                    canSkip: true
                    action: function() {
                         controller.dataManager.getStorageConnection().updateStatus("2 sec rootCDMI");
                    }
                }
            ]
        }

    public function allDone () {
        println("{myName}:allDone");
    }
   /**
     * This function is the main method which kicks off the root GET request.
     */
    public function getRootCDMIContainers () {
      println("{myName}: Main Entry Thread ID: {Thread.currentThread()}");
      parseResource();
    }

    function parseResource() : Void {
        connection = controller.dataManager.getStorageConnection();
        println("{myName}: Connecting to: {connection}");
        connection.updateStatus("Connecting to {connection.connection}");

        var acceptHeader = HttpHeader {
               name: HttpHeader.ACCEPT,
               value:"application/vnd.org.snia.cdmi.container+json"
            };
        var contentHeader = HttpHeader {
               name: HttpHeader.CONTENT_TYPE;
               value:"application/vnd.org.snia.cdmi.container+json"
            };
        var request : HttpRequest = HttpRequest {
            location: connection.connection;
            headers: [contentHeader, acceptHeader]
            method: HttpRequest.GET
            onResponseCode: function(code:Integer) { 
                println("{myName}: responseCode: {code}");
                /*
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
                if (code == 401) {
                    println("OCCINodeParser: Login Failure (401)");
                    connection.updateStatus("Login Failure. Try Again", true);
                } else {
                    //connection.updateStatus("Good {code} Response");
                    connection.connected = true;
                }
                */
                if (code == 200) {
                    connection.connected = true;
                    connection.updateStatus("Response Code {code}");
                } else {
                    connection.updateStatus("Response Code: {code}", true);
                }
            }
            onResponseMessage: function(msg:String) { println("rootCDMI: responseMessage: {msg}") }
            onReadingHeaders: function() { println("rootCDMI: readingHeaders...") }
            onToRead: function(bytes: Long) {
               println("rootCDMI: bytes to read: {bytes}");
               connection.updateStatus("Reading {bytes} CDMI bytes");
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
                    connection.updateStatus("Parsing CDMI Node Completed");
                    //controller.showStorageList();
                }
            }
        }
        request.start();       
    }

/**
 * This is the main parser for a CDMI resource.  It expects to find contianers present.
 * For each container found, the internal model is updated.
*/
public function processResults(is: InputStream) : Void {
    def parser = PullParser { documentType: PullParser.JSON; input: is; onEvent: parseEventCallback; };
    parser.parse();
    is.close();
    println("{myName} Closing input stream");
}


def parseEventCallback = function(event: Event) {
    //START_VALUE=25, START_ELEMENT=1, START_DOCUMENT=7, START_ARRAY=16
    //START_ARRAY_ELEMENT=17, END_ARRAY_ELEMENT=18, END_ELEMENT=2
    //println("event.type: {event.type} event.name: {event.name} event.text={event.text} event.level={event.level} ");

    if (event.type == PullParser.END_ARRAY_ELEMENT) {
        if (event.name == "children" and event.level == 0) {
            if (event.text.length() > 0) {
                // Remove any trailing slashes.
                var title: String = strings.trimSlashes(event.text);

                // For now - get the details of this container from the net resource.
                // This in turn populates the tree.
                CDMIContainerDetails.getContainerDetails(title);
            }
        }
    }
}
  