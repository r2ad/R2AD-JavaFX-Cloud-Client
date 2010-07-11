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
package com.r2ad.cloud.cloudclient.parsers.compute;

import java.io.InputStream;
import javafx.data.pull.Event;
import javafx.data.pull.PullParser;
import javafx.io.http.HttpHeader;
import javafx.io.http.HttpRequest;
import com.r2ad.cloud.cloudclient.controller.Controller;
import java.net.URI;
import org.occi.model.OCCIComputeType;
import com.sun.javafx.io.http.impl.Base64;
import com.r2ad.cloud.cloudclient.utils.Encoder;

//import cloudclient.model.NodeModel;

/**
 * This is the OCCI Node Parser which implements a portion of the OCCI specification.
 * This version uses the PullParser API to parse results in XML.
 */

    /**
    * Obtain the controller via the singleton - this is temporary code:
    */
    public var controller: Controller = bind controller.controller;
    var myName = "OCCINodeParser";

    var objectURI : URI;
    var domainURI : URI;
    var result: OCCIComputeType;
    var objectID: String;
    var connection;
    var resultsProcessor: function(is: InputStream) : Void;

    var computeNode : String;



    // Information about all relevant cloud nodes
    //public var cloudNodes: NodeModel[];
    //   GetMethod httpget = new GetMethod("https://www.verisign.com/");

    public function getComputeNode(stringID: String) : Void {
        connection = controller.dataManager.getComputeConnection();
        domainURI = new URI("{connection.connection}");
        connection.updateStatus("Getting OCCI resource: {domainURI}");

        println("{myName}: getDetails from {stringID} to: {connection}");

        var normalAuthenticationHeader = HttpHeader.basicAuth(connection.user, connection.credentials);
        // Good Ref: http://javafx.com/samples/ScreenshotMaker/src/Flickr.java.html
        var digestedPassPhrase = Encoder.sign("{connection.credentials}");
        var credentials64 = Base64.encode("{connection.user}:{digestedPassPhrase}".getBytes());
        var rubyAuthHeader = HttpHeader {
               name: "Authorization",
               value:"Basic {credentials64}"
            };
        var authenticationHeader;
        if ( controller.loginView.alternate == false ) {
            // This is now the default
            authenticationHeader=rubyAuthHeader;
            println("{myName}: using rubyAuthHeader");
        } else {
            authenticationHeader=normalAuthenticationHeader;
            println("{myName}: using normalAuthenticationHeader");
        }

        var acceptHeader = HttpHeader {
               name: HttpHeader.ACCEPT,
               value:"*/*"
            };
        var agentHeader = HttpHeader {
               name: "User-Agent",
               value:"R2ADCloud"
            };
        var versionHeader = HttpHeader {
               name: "OCCI-Version",
               value:"0.1"
            };
        var contentHeader = HttpHeader {
               name: HttpHeader.CONTENT_TYPE;
               value:"application/occi"
            };
        var langHeader = HttpHeader {
               name: "Accept-Language";
               value:"en-us"
            };
        var hostHeader = HttpHeader {
               name: "Host";
               value:"localhost"
            };

        var request : HttpRequest = HttpRequest {
           // TBD: Actually, need to get the path to the resource
            location: "{domainURI}";

            headers: [contentHeader, acceptHeader, agentHeader, versionHeader, authenticationHeader]
            method: HttpRequest.GET

            onStarted: function() {
               println("{myName}: onStarted - started performing method");
            }
            onConnecting: function() { println("{myName}: connecting to {request.location}") }
            onDoneConnect: function() { println("{myName}: doneConnect") }
           // onReadingHeaders: function() { println("readingHeaders...") }
            onResponseCode: function(code:Integer) {
                println("{myName}: OCCNode responseCode: {code}");
                //controller.dataManager.removeStorageType(stringID);
                if (code == 405) {
                    println("{myName}: Not Allowed!  Return FAIL");
                    connection.updateStatus("Not Allowed (405)", true);
                }
                if (code == 400) {
                    println("{myName}: Bad Request!  Return FAIL");
                    connection.updateStatus("Bad Request (400)", true);
                }
                if (code == 500) {
                    println("{myName}: Internal error  Return FAIL");
                    connection.updateStatus("Internal Error (500)", true);
                }
                if (code == 401) {
                    println("{myName}: Login Failure (401)");
                    connection.updateStatus("Login Failure. Try Again", true);
                }
                if (code == 200) {
                    connection.connected = true;
                    connection.updateStatus("Response Code {code}");
                } else {
                    connection.updateStatus("Response Code {code}", true);
                }
            }

            onResponseHeaders: function(headerNames: String[]) {
                println("onResponseHeaders - there are {headerNames.size()} response headers:");
                for (name in headerNames) {
                    println("{myName}:  {name}: {request.getResponseHeaderValue(name)}");
                }
            }


            onResponseMessage: function(msg:String) {
                println("{myName}: responseMessage: {msg}");
                connection.updateStatus("Response: {msg}", true);
            }
            onToRead: function(bytes: Long) {
               println("{myName}: bytes to read: {bytes}");
               connection.updateStatus("{myName}: Reading {bytes} OCCI bytes");

             }

            // The onRead callback is called when some more data has been read into
            // the input stream's buffer.  The input stream will not be available until
            // the onInput call back is called, but onRead can be used to show the
            // progress of reading the content from the location.
            onRead: function(bytes: Long) {
                println("{myName}: onRead - bytes read: {bytes}");

                // The toread variable is non negative only if the server provides the content length
                def progress =
                if (request.toread > 0) "({(bytes * 100 / request.toread)}%)" else "";
                println("{myName}: onRead - bytes read: {bytes} {progress}");
            }

            onInput: function(is: InputStream) {
                resultsProcessor = processResults;
                resultsProcessor(is);
                try {
                    println("{myName}: bytes of content available: {is.available()}");
                } finally {
                    is.close();
                    println("{myName}: Finished Parsing: {stringID}");
                    connection.updateStatus("Finisihed parsing OCCI Node");
                }
            }
        }
        request.start();
    }


public function processResults(is: InputStream) : Void {
    def parser = PullParser { documentType: PullParser.XML; input: is; onEvent: parseEventCallback };
    try {
        parser.parse();
    } catch (e: java.io.IOException) {
       println("{myName}:: Parsing Exception.");
       e.printStackTrace();
    }

    is.close();
}

def parseEventCallback = function(event: Event) {
    if (event.type == PullParser.START_ELEMENT) {
        processStartEvent(event)
    } else if (event.type == PullParser.END_ELEMENT) {
        processEndEvent(event)
    }
}

// temporary variables needed during processing
//var result: NodeModel;

function processStartEvent(event: Event) {
    println("{myName}:  start event.level={event.level} event.qname.name: {event.qname.name} event.type: {event.type} event.name: {event.name} event.text={event.text}");
    for (qname in event.getAttributeNames()) {
        var value = event.getAttributeValue(qname);
        println("{myName} start: {qname} value: {value}");
        // Store the value in this collection
    }
    if (event.qname.name.toLowerCase() == "compute") {
        computeNode = event.getAttributeValue("href");

        println("{myName}: Detected compute: {computeNode}");
        //
        // Automatically Drill Down and get the compute details:
        //
        OCCIComputeParser.getComputeDetails(computeNode);
    }

}

function processEndEvent(event: Event) {
    //START_VALUE=25, START_ELEMENT=1, START_DOCUMENT=7, START_ARRAY=16
    //START_ARRAY_ELEMENT=17, END_ARRAY_ELEMENT=18, END_ELEMENT=2
    println("{myName}:  end event.level={event.level} event.qname.name: {event.qname.name} event.type: {event.type} event.name: {event.name} event.text={event.text}");


}