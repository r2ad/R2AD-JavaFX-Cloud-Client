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
import javafx.io.http.HttpHeader;
import javafx.io.http.HttpRequest;
import com.r2ad.cloud.cloudclient.controller.Controller;
import java.net.URI;
import org.occi.model.OCCIComputeType;
import com.r2ad.cloud.cloudclient.utils.Encoder;
import com.sun.javafx.io.http.impl.Base64;
import java.lang.StringBuffer;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.InputStreamReader;
import java.lang.NumberFormatException;

/*
 * The <code>OCCICreateDisk/code> sends a OCCI POST request to create a disk compliant
 * with the OpenNebula implementation of the OCCI specification.
 * Created on Mar 7, 2010, 10:51:23 PM
 * @copyright 2010, R2AD, LLC.
 * @author behrens@r2ad.com
 */
/**
* Obtain the controller via the singleton - there might be a better way.
*/
public var controller: Controller = bind controller.controller;

var myName = "OCCIUpdateCompute_1_0";
var objectURI : URI;
var domainURI : URI;
var result: OCCIComputeType;
var RID: String;
var computerHostname: String;
var objectID: String;
var connection;
var tempComputer : OCCIComputeType = new OCCIComputeType();

// Information about all relevant cloud nodes.
// Use this to build up a list first, and then query.
//public var cloudNodes: NodeModel[];

/**
* This method sends an HTTP Get to based URL.
* It should only be invoked after login credentials are available.
* Messages on its progress are posted to the controller log.
* @Param stringURL the location of the compute resource to get.
*/
public function updateCompute(computer: OCCIComputeType) : Void {
    println("{myName}: Updating computer={computer.getString()}");
    computerHostname=computer.getHostname();
    connection = controller.dataManager.getComputeConnection();
    // http://www.nyren.net/api/compute/ea8e99d7-4604-4cef-bed8-f50bfc8473da
    RID=computer.getID();

    connection.updateStatus("{myName}: Updating computer");
    if ( computerHostname != "" ) {
        var payload: StringBuffer = new StringBuffer();
        payload.append("X-OCCI-Attribute: occi.compute.memory=4.0");
        println("{myName}: Content: \n{payload.toString()}");
        var contentBytes : Byte[] = payload.toString().getBytes();
        var contentLength  = contentBytes.size();

        var normalAuthenticationHeader = HttpHeader.basicAuth(connection.user, connection.credentials);
        var digestedPassPhrase = Encoder.sign("{connection.credentials}");
        var credentials64 = Base64.encode("{connection.user}:{digestedPassPhrase}".getBytes());
        var rubyAuthHeader = HttpHeader {
               name: "Authorization",
               value:"Basic {credentials64}"
            };
        var authenticationHeader;
        if ( controller.loginView.alternate == true ) {
            // This is now the default
            authenticationHeader=rubyAuthHeader;
            println("{myName}: using rubyAuthHeader");
        } else {
            authenticationHeader=normalAuthenticationHeader;
            println("{myName}: using normalAuthenticationHeader");
        }
        var agentHeader = HttpHeader {
               name: "User-Agent",
               value:"occi-client/1.0"
         };
        var acceptHeader = HttpHeader {
               name: HttpHeader.ACCEPT,
               value:"*/*"
            };
        var contentHeader = HttpHeader {
               name: HttpHeader.CONTENT_TYPE;
               value:"text/occi"
            };
        var contentLengthHeader = HttpHeader {
               name: HttpHeader.CONTENT_LENGTH,
               value:"{contentLength}"
            };
        var request : HttpRequest = HttpRequest {
            location: "{computer.getHostname()}/{computer.getID()}";
            headers: [agentHeader, contentHeader, contentLengthHeader]
            method: HttpRequest.PUT

            onStarted: function() {
               println("{myName}: onStarted - started performing method");
               println("{myName}: Headers: {agentHeader} {contentHeader} {acceptHeader}");
            }
            onConnecting: function() { println("{myName}: connecting to {request.location}") }
            onDoneConnect: function() { println("{myName}: doneConnect") }
            onReadingHeaders: function() { println("{myName}: readingHeaders...") }
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
                } else {
                    connection.connected = true;
                }

            }

            onWriting: function() {
               println("{myName}: Writing: {payload.toString()}");
               connection.updateStatus("{myName}: sending bits");
            }
            onDoneWrite: function() { println("{myName}: onDoneWrite") }
            onDone: function() { println("{myName}: onDone") }

            override var output on replace {
               println("{myName}: output on replace: Writing...");

                if (output != null) {
                    try {
                       output.write(payload.toString().getBytes());
                       output.close();
                    } catch (e: java.io.IOException) {
                       println("{myName}: Unable to write");
                    }
                }
            }

            onResponseMessage: function(msg:String) { println("responseMessage: {msg}") }
            onToRead: function(bytes: Long) {
               println("{myName}: bytes to read: {bytes}");
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
                processHTMLResults(is);
                try {
                    println("{myName}: bytes of content available: {is.available()}");
                } finally {
                    is.close();
                    println("{myName}: *** Finished Parsing *** : {computer.getID()}");
                    println("{myName}: TEMP COMPUTER: {tempComputer}");
                    connection.updateStatus("{myName}: Finisihed parsing OCCI Computer");
                }
            }
        }
        request.start();
    } else {
         println("{myName}: COMPUTER hostname not known - aborting!: {computer}");
    }


}

/**
* An HTML Parserer for the OCCI content of the resource.
* @Param is: the input stream.
*/
public function processHTMLResults(is: InputStream) : Void {
    println("{myName}: Processing Results: Parsing on InputStream");
}

/**
* Invoked for each end element tag.
* @Param event the event information
*/
function processEndOfLine() {
    //
    // If Attributes exists, then use them.  Different XML schema might be
    // used - causing confusion.
    //
    println("{myName}: processEndOfLine, Temp computer, RID: {RID}={tempComputer}");
}
