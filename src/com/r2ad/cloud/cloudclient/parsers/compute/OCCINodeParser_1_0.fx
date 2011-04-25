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
import javafx.io.http.HttpHeader;
import javafx.io.http.HttpRequest;
import com.r2ad.cloud.cloudclient.controller.Controller;
import java.net.URI;
import org.occi.model.OCCIComputeType;
import com.sun.javafx.io.http.impl.Base64;
import com.r2ad.cloud.cloudclient.utils.Encoder;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.InputStreamReader;

/**
 * This is the OCCI Node Parser which implements a portion of the OCCI specification.
 * This version uses the PullParser API to parse results in XML.
 */

    /**
    * Obtain the controller via the singleton - this is temporary code:
    */
    public var controller: Controller = bind controller.controller;
    var myName = "OCCINodeParser_1_0";

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
        if ( not connection.connection.endsWith("/") ) {
            connection.setConnection("{connection.connection}/");
        }
        
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
        if ( controller.loginView.alternate == true ) {
            authenticationHeader=rubyAuthHeader;
            println("{myName}: using rubyAuthHeader");
        } else {
            // This is now the default
            authenticationHeader=normalAuthenticationHeader;
            println("{myName}: using normalAuthenticationHeader");
        }

        var acceptHeader = HttpHeader {
               name: HttpHeader.ACCEPT,
               value:"*/*"
            };
        var agentHeader = HttpHeader {
               name: "User-Agent",
               value:"occi-client/1.0"
            };
        var versionHeader = HttpHeader {
               name: "OCCI-Version",
               value:"1.0"
            };
        var contentHeader = HttpHeader {
               name: HttpHeader.CONTENT_TYPE;
               value:"text/occi"
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

            location: "{domainURI}";  //may need to add: /compute

            headers: [agentHeader, contentHeader, acceptHeader, authenticationHeader]
            method: HttpRequest.GET

            onStarted: function() {
               println("{myName}: onStarted - started performing method");
               println("{myName}: Headers: {agentHeader} {contentHeader} {acceptHeader}");
            }
            onConnecting: function() { println("{myName}: connecting to {request.location}") }
            onDoneConnect: function() { println("{myName}: doneConnect") }
            onReadingHeaders: function() { println("{myName}: readingHeaders...") }
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
                resultsProcessor = processHTMLResults;
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


public function processHTMLResults(is: InputStream) : Void {
    println("{myName}: Processing Results: Parsing on InputStream ---------- ");
    var htmlPage: String = "";

    try {
       println("{myName}: bytes of content available: {is.available()}");
       parseInput(is);
       //var s2s: StreamToString = new StreamToString();
       //htmlPage = s2s.convertStreamToString(is);
       //println("{myName}: Returned Page: {htmlPage}" );

    } catch (e: java.io.IOException) {
       println("{myName}: Parsing Exception.");
       e.printStackTrace();
    }

    try {
       is.close();
    } catch (e: java.io.IOException) {
       e.printStackTrace();
    }
}

function parseInput(is: InputStream) {
    var dis: DataInputStream = new DataInputStream(is);
    var isr: InputStreamReader = new InputStreamReader(dis);
    var br: BufferedReader = new BufferedReader(isr);
    var strLine: String = "";
    //Read File Line By Line
    while ((strLine = br.readLine()) != null)   {
      // Print the content on the console
      println("{myName}: Line: {strLine}" );
      if (strLine.startsWith(connection.connection)) {

         var resourceID : String="UNKNOWN";

         var IDStart;
         IDStart=strLine.lastIndexOf("/");
         if ( IDStart >= 0 ) {
             resourceID=strLine.substring(IDStart+1);
         }

          println("{myName}: Found RESOURCE: {strLine}");
          OCCIComputeParser_1_0.getComputeDetails(strLine, resourceID);
      }

    }

}
