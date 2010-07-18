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
import com.r2ad.cloud.cloudclient.utils.Encoder;
import com.sun.javafx.io.http.impl.Base64;

/**
 * This is the OCCI Network Parser which implements a portion of the OCCI specification.
 * This version uses the PullParser API to parse results in XML.
 */

    /**
    * Obtain the controller via the singleton - this is temporary code:
    */
    public var controller: Controller = bind controller.controller;
    var myName = "OCCINetworkParser";

    var objectURI : URI;
    var domainURI : URI;
    var result: OCCIComputeType;
    var objectID: String;
    var connection;
    var resultsProcessor: function(is: InputStream) : Void;

    public function getNetwork(URIstringID: String) : Void {
        connection = controller.dataManager.getComputeConnection();
        domainURI = new URI(URIstringID);
        connection.updateStatus("Getting OCCI resource...domainURI: {domainURI}");

        println("{myName}: get Network details from {URIstringID} to: {connection}");
        println("{myName}: using connection: {connection}");
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
    var agentHeader = HttpHeader {
           name: "User-Agent",
           value:"R2ADCloud"
     };
    var acceptHeader = HttpHeader {
           name: HttpHeader.ACCEPT,
           value:"*/*"
        };
    var contentHeader = HttpHeader {
           name: HttpHeader.CONTENT_TYPE;
           value:"application/occi"
        };
    var request : HttpRequest = HttpRequest {
            location: "{domainURI}";
            headers: [contentHeader, acceptHeader, agentHeader, authenticationHeader]
            method: HttpRequest.GET

            onStarted: function() {
               println("{myName}: onStarted - started performing method");
            }
            onConnecting: function() { println("{myName}: connecting to {request.location}") }
            onDoneConnect: function() { println("{myName}: doneConnect") }
            onReadingHeaders: function() { println("readingHeaders...") }
            onResponseCode: function(code:Integer) {
                println("{myName}: responseCode: {code}");
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
            }
            onResponseMessage: function(msg:String) { println("responseMessage: {msg}") }
            onToRead: function(bytes: Long) {
               println("bytes to read: {bytes}");
               //connection.updateStatus("Reading {bytes} OCCI bytes");

             }

            // The onRead callback is called when some more data has been read into
            // the input stream's buffer.  The input stream will not be available until
            // the onInput call back is called, but onRead can be used to show the
            // progress of reading the content from the location.
            onRead: function(bytes: Long) {
               // println("bytes read: {bytes}");
            }

            onInput: function(is: InputStream) {
                resultsProcessor = processResults;
                resultsProcessor(is);
                try {
                    println("{myName}: bytes of content available: {is.available()}");
                } finally {
                    is.close();
                    println("{myName}: Finished Parsing: {URIstringID}");
                    connection.updateStatus("Finisihed parsing OCCI Network");
                }
            }
        }
        request.start();
    }


public function processResults(is: InputStream) : Void {
//    def parser = PullParser { documentType: PullParser.XML; input: is; onEvent: parseEventCallback };
//    parser.parse();
    debugStream.dumpStream(is);

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
    if (event.qname.name == "Result" and event.level == 1) {
        //result = NodeModel {
        //    id: event.getAttributeValue(QName{name:"id"}) as String;
        //}
    }
}

function processEndEvent(event: Event) {
    //START_VALUE=25, START_ELEMENT=1, START_DOCUMENT=7, START_ARRAY=16
    //START_ARRAY_ELEMENT=17, END_ARRAY_ELEMENT=18, END_ELEMENT=2
    println("** {myName}:  event.level={event.level} event.qname.name: {event.qname.name} event.type: {event.type} event.name: {event.name} event.text={event.text}");

    if (event.qname.name == "collection" and event.level == 1) {
        println("{myName}: Detected Collection: {event.text}");
        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("{myName}/1: collection {qname} value: {value} Level 1");
            // Store the value in this collection
        }
    } else if (event.qname.name == "collection" and event.level == 2) {
        println("{myName}/2: collection Level 2");
    } else if (event.qname.name == "compute" and event.level == 2) {
        println("{myName}: Detected compute");
        var id : String = event.getAttributeValue("id");
        var hostname : String = event.getAttributeValue("hostname");
        var summary : String = event.getAttributeValue("summary");
        var architecture : String = event.getAttributeValue("architecture");
        // Create a new compute node:
        var computer : OCCIComputeType = new OCCIComputeType();
        if ( id.toString().length() != 0) computer.setID(id);
        if ( hostname.toString().length() != 0) {
            computer.setHostname(hostname);
            computer.setTitle(hostname);
            //
            // Add this node only if hostname is defined:
            //
            if ( summary.toString().length() != 0) computer.setSummary(summary);
            if (architecture != null and architecture != "") {
               try {
                  computer.setArchitecture(OCCIComputeType.Architecture.valueOf(architecture));
               } catch (Exception) {
                  println("{myName}: could not understand architecture: {architecture}");
               }
            }
            controller.dataManager.addComputeType(computer);
        }

        // Debug:
        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("{myName}: {qname} value: {value}");
            // Store the value in this collection
        }

    } else if (event.qname.name == "network" and event.level == 2) {
        println("{myName}: Detected storage");
        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("{myName} network: {qname} value: {value}");
            // Store the value in this collection
        }
    } else if (event.qname.name == "link" and event.level == 2) {
        println("{myName}: Detected link");
        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("{myName} link: {qname} value: {value}");
            // Store the value in this collection
        }
    }

}
