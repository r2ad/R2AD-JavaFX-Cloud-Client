/**
 DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
 Copyright (c) 2010, R2AD, LLC, All rights reserved.

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
import com.r2ad.cloud.cloudclient.controller.Controller;
import javafx.io.http.HttpRequest;
import java.lang.StringBuffer;
import org.occi.model.OCCINetworkType;
import com.r2ad.cloud.cloudclient.utils.Encoder;
import com.sun.javafx.io.http.impl.Base64;

/*
 * The <code>OCCICreateDisk/code> sends a OCCI POST request to create a disk compliant
 * with the OpenNebula implementation of the OCCI specification.
 * Created on Mar 7, 2010, 10:51:23 PM
 * @copyright 2010, R2AD, LLC.
 * @author behrens@r2ad.com
 */

    /**
    * Obtain the controller via the singleton - this is temporary code:
    */
    public var controller: Controller = bind controller.controller;

    var content: StringBuffer = new StringBuffer();
    var net2Model: OCCINetworkType = null;
    var myName = "OCCICreateDisk";

    // Information about all relevant cloud nodes
    //public var cloudNodes: NodeModel[];

    public function createDisk(newModel: OCCINetworkType) : Void {
        println("++createDisk : {newModel}");
        println("++createDisk++++++++++++++++++++++++");
        println("++createDisk++++++++++++++++++++++++: {newModel.getTitle()}");
        println("++createDisk++++++++++++++++++++++++");

        content.append("<DISK>\n");
        content.append("<NAME>{newModel.getTitle()}-Disk</NAME>\n");
        content.append("<URL>cdmi:123456789</URL>\n");
        content.append("</DISK>\n");

        /* we'll expect something like this to be returned:
            <DISK>
               <ID>ab5c9770-7ade-012c-f1d5-00254bd6f386</ID>
               <NAME>VM32-Disk</NAME>
               <SIZE>1000</SIZE>
               <URL>cdmi:123456789<URL>
            </DISK>         
        */

        println("{myName}: Content: \n{content.toString()}");

        if (newModel.getTitle() != null and newModel.getTitle().length() != 0 ) {
            var contentBytes : Byte[] = content.toString().getBytes();
            var contentLength  = contentBytes.size();

            var resultsProcessor: function(is: InputStream) : Void;
            var connection = controller.dataManager.getComputeConnection();
            println("{myName}: Creating Disk for VM: {newModel.getTitle()}");

            var normalAuthenticationHeader = HttpHeader.basicAuth(connection.user, connection.credentials);
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
            var contentHeader = HttpHeader {
                   name: HttpHeader.CONTENT_TYPE;
                   value:"application/xml"
                };
            var contentLengthHeader = HttpHeader {
                   name: HttpHeader.CONTENT_LENGTH,
                   value:"{contentLength}"
                };
            var request : HttpRequest = HttpRequest {
                location: "{connection.connection}/disk";
                headers: [contentHeader, acceptHeader, contentLengthHeader, authenticationHeader]
                method: HttpRequest.POST //create

                onStarted: function() {
                   println("{myName}: onStarted - started performing method, location: {connection.connection}/network");
                }
                onConnecting: function() { println("{myName}: connecting...") }
                onDoneConnect: function() { println("{myName}: doneConnect") }
                onReadingHeaders: function() { println("{myName}: readingHeaders...") }
                onResponseCode: function(code:Integer) {
                    println("{myName}: responseCode: {code}");
                    if (code == 405) {
                        println("{myName}: Not Allowed!  Return FAIL");
                        connection.updateStatus("Code 405 - not allowed", true);
                    }
                    if (code == 400) {
                        println("{myName}: Bad Request!  Return FAIL");
                        connection.updateStatus("Code 400 - Bad Request", true);
                    }
                    if (code == 500) {
                        println("{myName}: Internal error  Return FAIL");
                        connection.updateStatus("Code 500 - Internal Error", true);
                    }
                    if (code == 200) {
                        connection.updateStatus("Finished Creating Container");
                    }
                }
                onResponseMessage: function(msg:String) { println("{myName}: responseMessage: {msg}") }
                onToRead: function(bytes: Long) { println("{myName}: bytes to read: {bytes}") }

                // The onRead callback is called when some more data has been read into
                // the input stream's buffer.  The input stream will not be available until
                // the onInput call back is called, but onRead can be used to show the
                // progress of reading the content from the location.
                onRead: function(bytes: Long) {
                    println("{myName}: bytes read: {bytes}");
                }
                onWriting: function() {
                   println("{myName}: Writing...");
                   connection.updateStatus("{myName}: sending bits");
                }
                onDoneWrite: function() { println("{myName}: onDoneWrite") }
                onDone: function() { println("{myName}: onDone") }

                override var output on replace {
                   println("{myName}: output on replace: Writing...");

                    if (output != null) {
                        try {
                           output.write(content.toString().getBytes());
                           output.close();
                        } catch (e: java.io.IOException) {
                           println("{myName}: Unable to write");
                        }
                    }
                }

                onInput: function(is: InputStream) {
                    resultsProcessor = processResults;
                    resultsProcessor(is);
                    try {
                        println("{myName}: bytes of content available: {is.available()}");
                    } finally {
                        is.close();
                    }

                }
            }
           request.start();
        } else {
           println("{myName}: PROBLEM, Title/name is EMPTY or NULL");
        }

    }

public function processResults(is: InputStream) : Void {

    def parser = PullParser { documentType: PullParser.XML; input: is; onEvent: parseEventCallback; };
    parser.parse();
    //debugStream.dumpStream(is);
    is.close();
    println("{myName}: processResults");
}

var result: OCCINetworkType;

def parseEventCallback = function(event: Event) {
    //START_VALUE=25, START_ELEMENT=1, START_DOCUMENT=7, START_ARRAY=16
    //START_ARRAY_ELEMENT=17, END_ARRAY_ELEMENT=18, END_ELEMENT=2
    println("{myName}: event.type: {event.type} event.name: {event.name} event.text={event.text} event.level={event.level} ");

    println("event.type: {event.type} event.name: {event.name} event.text={event.text} event.level={event.level} ");
    if (event.type == PullParser.START_ARRAY_ELEMENT) {
       // Assume a new model is needed....
        println("{myName}:** Creating new empty Network Object Model");
    }
    
    // CreateContianer: event.type: 4 event.name: objectID event.text=1911593573364205 event.level=0
    if (event.type == 4 and event.name.equals("objectID")) {
        net2Model.setID(event.text);
        println("{myName}:objectID: {event.text}");

    }
    // CreateContianer: event.type: 4 event.name: objectURI event.text=/BOB event.level=0
    if (event.type == 4 and event.name.equals("objectURI")) {
        println("TBD: Store ObjectURI..............");
        //sModel.setObjectURI(event.text);
    }

    if (event.type == PullParser.END_ARRAY_ELEMENT) {
        if (event.name == "children" and event.level == 0) {
            if (event.text.length() > 0) {
                result.setTitle(event.text);
//                controller.dataManager.addNetworkType(result);
                println("{myName}: Should this class invoke dataHandler.addOCCIStorageType for {event.text}");
            }
        }
    }
}

  

