/*
 *  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
 *  Copyright (c) 2010, R2AD, LLC, All rights reserved.
 * 
 *  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *     o Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *     o Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 *     o Neither the name of the R2AD, LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * 
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.r2ad.cloud.cloudclient.parsers.storage;

/**
 * @author JavaFX@r2ad.com
 */

import java.io.InputStream;
import javafx.data.pull.Event;
import javafx.data.pull.PullParser;
import org.occi.model.OCCIStorageType;
import com.r2ad.cloud.cloudclient.controller.Controller;
import javafx.io.http.HttpRequest;
import java.io.File;
import org.occi.model.StoredObject;
import java.lang.StringBuilder;
import javafx.io.http.HttpHeader;
import java.io.BufferedReader;
import java.io.FileReader;

/*
 * The <code>CDMICreateObject</code> sends a CDMI POST request to create an object
 * at a CDMI compliant container resource.
 * Created on Aug 16, 2010, 10:51:23 PM
 * @copyright Copyright 2010, R2AD, LLC.
 * @author behrens@r2ad.com
 */
    /**
    * Obtain the controller via the singleton - this is temporary code:
    */
    public var controller: Controller = bind controller.controller;
    var myName = "CDMICreateObject";
    var content: StringBuilder = new StringBuilder();
    var contentLength  = 0;

    /*
     * Called to upload or create the object on the connected CDMI node.
     */
    public function createObject(sModel: OCCIStorageType) : Void {

        var storedObject: StoredObject = sModel.getObject();
        if ( storedObject.getUploadFlag() == true ) {
            var uploadFile: File = storedObject.getFile();
            println ("{myName}: - Now need to upload file {uploadFile.toString()}");
            println ("CDMI Content Flag: {storedObject.isCDMIContentType()}")
        } else {
            println ("WARNING - Create Object called and flag is FALSE");
        }

        var resultsProcessor: function(is: InputStream) : Void;
        var connection = controller.dataManager.getStorageConnection();
        println("{myName} Connecting to: {connection}");

        var acceptHeader: HttpHeader;
        var contentHeader: HttpHeader;
        var versionHeader: HttpHeader;

        if (storedObject.isCDMIContentType()) {

            // HoLD Lab content lines should be below:
            // Insert here StringBuilder append lines as needed to
            // comply with CDMI spec for an object PUT.
            // i.e. content.append("\{\n");
            // etc.

            content.append("\{\n");
            content.append("\t\"mimetype\" : \"text/plain\",\n");
            content.append("\t\"metadata\" : \{\n");
            content.append("\n\t\},\n");
            content.append("\t\"value\" : \"");

            // Read the file and inject as a CDMI text:
            var text: StringBuilder  = new StringBuilder();
            //use buffering, reading one line at a time
            //FileReader always assumes default encoding is OK!
            var input: BufferedReader  =  new BufferedReader(new FileReader(storedObject.getFile()));
            try {
              var line: String = null; //not declared within while loop
              while (( line = input.readLine()) != null){
                 println("{myName}: object content: {line}");
                 // HoLD Lab TODO:  Also append each line from the file:

                 content.append("{line}");
              }
            }
            finally{
               input.close();
            }
            //
            // HoLD Lab TODO:  Do not foget the closing syntax:
            //

            content.append("\"\n");
            content.append("\}\n");

        var contentBytes : Byte[] = content.toString().getBytes();
        contentLength  = contentBytes.size();

        var contentLengthHeader = HttpHeader {
               name: HttpHeader.CONTENT_LENGTH,
               value:"{contentLength}"
            };
        acceptHeader = HttpHeader {
               name: HttpHeader.ACCEPT,
               value:"application/vnd.org.snia.cdmi.dataobject+json"
            };
        contentHeader = HttpHeader {
               name: HttpHeader.CONTENT_TYPE;
               value:"application/vnd.org.snia.cdmi.dataobject+json"
            };
        versionHeader = HttpHeader {
               name: "X-CDMI-Specification-Version";
               value:"1.0"
            };
        }

        var request : HttpRequest = HttpRequest {
            var fileName = storedObject.getFileName();
            location: "{connection.connection}/{sModel.getTitle()}/{fileName}";

            // CDMI Content Type does not have a content length and does have metadata.
            // Non-CDMI types are more like basic content types (text, etc).

            headers: [contentHeader, acceptHeader, versionHeader ] //, contentLengthHeader
            method: HttpRequest.PUT
            onStarted: function() {
               println("{myName}: onStarted - started performing method");
               println("{myName}: location is {request.location}");
               println("{myName}: filename is {fileName}");
               println("{myName}: Title is {sModel.getTitle()}");
            }
            onConnecting: function() { println("connecting...") }
            onDoneConnect: function() { println("doneConnect") }
            onReadingHeaders: function() { println("readingHeaders...") }
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
                    connection.updateStatus("Finished Creating Object");
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
            onDone: function() {
                println("{myName}: onDone");
                var storedObject: StoredObject = sModel.getObject();
                storedObject.getUploadFlag() == false;
                // Does the setting keep (reference):
                storedObject = sModel.getObject();
                println("{myName}: storedObject flag={storedObject.getUploadFlag()}");

            }

            override var output on replace {
               println("{myName}: output on replace: Writing...");
               println("{myName}: Debug Content -----------------------------");
               println("{content}");
               println("{myName}: -------------------------------------------");

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
        if (contentLength > 0) {
            println("{myName}: Initiating object PUT request, len=: {contentLength}");
            request.start();
        } else {
            println("{myName}: Object Request Aborted...zero content size!");
        }

    }


public function processResults(is: InputStream) : Void {
    def parser = PullParser { documentType: PullParser.JSON; input: is; onEvent: parseEventCallback; };
    parser.parse();
    is.close();
}

def parseEventCallback = function(event: Event) {
    //START_VALUE=25, START_ELEMENT=1, START_DOCUMENT=7, START_ARRAY=16
    //START_ARRAY_ELEMENT=17, END_ARRAY_ELEMENT=18, END_ELEMENT=2
    println("{myName}: event.type: {event.type} event.name: {event.name} event.text={event.text} event.level={event.level} ");
    if (event.type == PullParser.START_ARRAY_ELEMENT) {
       // Assume a new model is needed....
        println("** {myName} Processing store Object Command");
    }

    if (event.type == PullParser.END_ARRAY_ELEMENT) {
        if (event.name == "children" and event.level == 0) {
            if (event.text.length() > 0) {
                println("** {myName} Something is here {event.text}");
            }
        }
    }
}



