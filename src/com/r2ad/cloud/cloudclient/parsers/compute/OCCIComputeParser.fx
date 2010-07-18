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
 * This is the OCCI Node Parser which implements a portion of the OCCI specification.
 * This version uses the PullParser API to parse results in XML.
 * @see <a href="http://www.ogf.org/Public_Comment_Docs/Documents/2010-01/occi-core.pdf">OCCI Spec</a>
 */

/**
* Obtain the controller via the singleton - there might be a better way.
*/
public var controller: Controller = bind controller.controller;

var myName = "OCCIComputeParser";
var objectURI : URI;
var domainURI : URI;
var result: OCCIComputeType;
var objectID: String;
var connection;
var resultsProcessor: function(is: InputStream) : Void;
var tempComputer : OCCIComputeType;

// Information about all relevant cloud nodes.
// Use this to build up a list first, and then query.
//public var cloudNodes: NodeModel[];

/**
* This method sends an HTTP Get to based URL.
* It should only be invoked after login credentials are available.
* Messages on its progress are posted to the controller log.
* @Param stringURL the location of the compute resource to get.
*/
public function getComputeDetails(stringURL: String) : Void {
    connection = controller.dataManager.getComputeConnection();
    domainURI = new URI("{stringURL}");
    println("{myName}: GET domainURI: {domainURI}");
    connection.updateStatus("{myName}: getting computer");

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
        location: "{stringURL}";
        headers: [contentHeader, acceptHeader, agentHeader, authenticationHeader]
        method: HttpRequest.GET

        onStarted: function() {
           println("{myName}: onStarted - started performing method");
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
            resultsProcessor = processResults;
            resultsProcessor(is);
            try {
                println("{myName}: bytes of content available: {is.available()}");
            } finally {
                is.close();
                println("{myName}: Finished Parsing: {stringURL}");
                connection.updateStatus("{myName}: Finisihed parsing OCCI Computer");
            }
        }
    }
    request.start();
}

/**
* Initiates a Pull Parserer for the XML content of the OCCI resource.
* @Param is the input stream, which should be XML content.
*/
public function processResults(is: InputStream) : Void {
    def parser = PullParser { documentType: PullParser.XML; input: is; onEvent: parseEventCallback };
    parser.parse();

    is.close();
    controller.cloudView.loadComputeList();

}

def parseEventCallback = function(event: Event) {
    if (event.type == PullParser.START_ELEMENT) {
        processStartEvent(event)
    } else if (event.type == PullParser.END_ELEMENT) {
        processEndEvent(event)
    }
}


/**
* Invoked for each new start element tag.
* @Param event the event information
*/
function processStartEvent(event: Event) {
    //println("{myName}:  start event.level={event.level} event.qname.name: {event.qname.name} event.type: {event.type} event.name: {event.name} event.text={event.text}");
    if (event.qname.name.toLowerCase() == "compute" ) {
        // Create a new compute node:
        tempComputer = new OCCIComputeType();
        tempComputer.setID("unknownID"); // default - not always accurate
        tempComputer.setHostname("unknownHost"); // default - not always accurate
        tempComputer.setCores(1); // default - not always accurate
        tempComputer.setMemory(1024); // default - not always accurate
        tempComputer.setArchitecture(OCCIComputeType.Architecture.x86);
        println("{myName}: Instantiating computer: {tempComputer.getID()}");
    }
}
/**
* Invoked for each end element tag.
* @Param event the event information
*/
function processEndEvent(event: Event) {
    //START_VALUE=25, START_ELEMENT=1, START_DOCUMENT=7, START_ARRAY=16
    //START_ARRAY_ELEMENT=17, END_ARRAY_ELEMENT=18, END_ELEMENT=2
    //println("{myName}:  end event.level={event.level} event.qname.name: {event.qname.name} event.type: {event.type} event.name: {event.name} event.text={event.text}");

    if (event.qname.name == "collection" and event.level == 1) {
        println("{myName}: Detected Collection: {event.text}");
        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("OCCINodeParser/1: collection {qname} value: {value} Level 1");
            // Store the value in this collection
        }
    } else if (event.qname.name == "collection" and event.level == 2) {
            println("{myName}/2: collection Level 2");
    } else if (event.qname.name.toLowerCase() == "compute" ) {
        //
        // If Attributes exists, then use them.  Different XML schema might be
        // used - causing confusion.
        //
        var id : String = event.getAttributeValue("id");
        var hostname : String = event.getAttributeValue("hostname");
        var summary : String = event.getAttributeValue("summary");
        var architecture : String = event.getAttributeValue("architecture");

        if ( id.toString().length() != 0) tempComputer.setID(id);
        if ( hostname.toString().length() != 0) tempComputer.setHostname(hostname);
        if ( hostname.toString().length() != 0) tempComputer.setTitle(hostname);
        if ( hostname.toString().length() != 0) tempComputer.setHostname(hostname);

        //
        // Add this node only if hostname is defined:
        //
        if ( summary.toString().length() != 0) tempComputer.setSummary(summary);
        if (architecture != null and architecture != "") {
           try {
              tempComputer.setArchitecture(OCCIComputeType.Architecture.valueOf(architecture));
           } catch (Exception) {
              println("{myName}: could not understand architecture: {architecture}");
              tempComputer.setArchitecture(OCCIComputeType.Architecture.x86);   // Assume!
           }
        }

        //
        // Not sure why we can't just use computer, however if we do, it ends up null.
        // So, create a new object and add it.
        //
        var newcomputer: OCCIComputeType;
        newcomputer = controller.dataManager.createOCCIComputeType();
        newcomputer.setID(tempComputer.getID());
        newcomputer.setHostname(tempComputer.getHostname());
        newcomputer.setTitle(tempComputer.getHostname());
        newcomputer.setSummary("summary");
        newcomputer.setMemory(tempComputer.getMemory());
        newcomputer.setStatus(tempComputer.getStatus());
        newcomputer.setCores(tempComputer.getCores());
        newcomputer.setArchitecture(tempComputer.getArchitecture());
        newcomputer.setHostname(tempComputer.getHostname());
        println("{myName}: *************** Storing computer new host:{newcomputer.getHostname()} ID:{newcomputer.getID()} Mem:{newcomputer.getMemory()}");
        connection.updateStatus("{myName}: Storing {newcomputer.getHostname()} ID:{newcomputer.getID()}");

        controller.dataManager.insertComputeType(newcomputer);

        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("{myName}: compute: {qname} value: {value}");
            // Store the value in this collection
        }

    } else if (event.qname.name.toLowerCase() == "storage" and event.level == 2) {
        println("{myName}: Detected storage");
        connection.updateStatus("{myName}: Detected storage");

        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("{myName}: attribute qname: {qname} value: {value}");
            // Store the value in this collection
        }
    } else if (event.qname.name.toLowerCase() == "name") {
        println("{myName}: Detected Name");
        var name : String = event.getAttributeValue("name");
        if ( name.length() == 0) {
           name = event.getAttributeValue("NAME");
        }
        // If name is not an attribute (being flexible and not sure what is implemented,
        // use the event.text instead:
        if ( name.length() == 0) {
           name=event.text;
        }
        if ( name.length() != 0) {
           tempComputer.setHostname(name);
           println("{myName}: computer Name set to {tempComputer.getHostname()}");
        }

    } else if (event.qname.name.toLowerCase() == "state") {
        println("{myName}: Detected State for {tempComputer.getHostname()}");
        var state : String = event.getAttributeValue("state");
        if ( state.length() == 0) {
           state = event.getAttributeValue("STATE");
        }
        // If name is not an attribute (being flexible and not sure what is implemented,
        // use the event.text instead:
        if ( state.length() == 0) {
           state=event.text;
        }
        if ( state.length() != 0) {
            // incorrectly assume Inactive:
            tempComputer.setStatus(2);
            if (state.equals ("STOPPED") ) tempComputer.setStatus(3); //computer.Status.SUSPENDED
            if (state.equals ("ACTIVE") ) tempComputer.setStatus(1);
            if (state.equals ("INACTIVE") ) tempComputer.setStatus(2);
            println("{myName}: Assigned State to {tempComputer.getStatus()}");

        }

    } else if (event.qname.name.toLowerCase() == "memory" ) {
        println("{myName}: Detected memory, event: {event.text}");
        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("{myName}: attribute qname: {qname} value: {value}");
            // Store the value in this collection
        }
    } else if (event.level > 1 and event.qname.name.toLowerCase() == "disk" ) {
        println("{myName}: Detected {event.qname.name}");
        var diskType : String = event.getAttributeValue("type");
        var diskDevice : String = event.getAttributeValue("dev");
        println("{myName}: Detected Disk, dev attrib: {diskDevice} Type: {diskType}");
        // TBD: Store in model
    } else if (event.qname.name.toLowerCase() == "id" ) {
        println("{myName}: Detected ID");
        if ( event.text.length() != 0) {
           tempComputer.setID(event.text);
           println("{myName}: computer ID set to {tempComputer.getID()}");
        }

    } else if (event.level > 1 and event.qname.name.toLowerCase() == "nic" ) {
        println("{myName}: Detected {event.qname.name}");
        var ip : String = event.getAttributeValue("ip");
        var hrefNIC : String = event.getAttributeValue("href");
        println("{myName}: Detected nic, ip: {ip}, href={hrefNIC}");
        connection.updateStatus("{myName}: Detected NIC {ip}");

        //
        // TBD
        // Need way to add network to OCCI Compute Type.
        //
        // Next line commented out because it returns a responseCode: 404
        //OCCINetworkParser.getNetwork(hrefNIC);

    } else if (event.qname.name.toLowerCase() == "link" ) {
        println("{myName}: Detected link");
        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("{myName}: attribute qname: {qname} value: {value}");
            // Store the value in this collection
        }
    } else if (event.qname.name.toLowerCase() == "network" ) {
        println("{myName}: Detected end of network.........");
        for (qname in event.getAttributeNames()) {
            var value = event.getAttributeValue(qname);
            println("{myName}: attribute qname: {qname} value: {value}");
            // Store the value in this collection
        }
    } else  {
        println("{myName}: Unprocessed end Event: {event.qname.name}");
    }


}
