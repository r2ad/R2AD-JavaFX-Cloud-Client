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
import com.r2ad.cloud.cloudclient.utils.Encoder;
import com.sun.javafx.io.http.impl.Base64;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.InputStreamReader;
import java.lang.NumberFormatException;
/**
 * This is the OCCI Node Parser which implements a portion of the OCCI specification.
 * This version uses the PullParser API to parse results in XML.
 * @see <a href="http://www.ogf.org/Public_Comment_Docs/Documents/2010-01/occi-core.pdf">OCCI Spec</a>
 */

/**
* Obtain the controller via the singleton - there might be a better way.
*/
public var controller: Controller = bind controller.controller;

var myName = "OCCIComputeParser_1_0";
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
public function getComputeDetails(stringURL: String, resourceID: String) : Void {
    connection = controller.dataManager.getComputeConnection();
    domainURI = new URI("{stringURL}");
    // http://www.nyren.net/api/compute/ea8e99d7-4604-4cef-bed8-f50bfc8473da
    println("{myName}: GET domainURI: [{domainURI}] - - - - - - - - -");
    RID=resourceID;

     var IDStart;
     IDStart=stringURL.lastIndexOf("/");
     if ( IDStart >= 0 ) {
         RID=stringURL.substring(IDStart+1);
     }

    //
    // Assign the hostname from the URL:
    //
    computerHostname=stringURL.substring(0,IDStart);
    connection.updateStatus("{myName}: getting computer");
    println("{myName}: getting computer, hostname={computerHostname}");


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
    var request : HttpRequest = HttpRequest {
        location: "{stringURL}";
        headers: [contentHeader, acceptHeader, authenticationHeader]
        method: HttpRequest.GET

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
            processHTMLResults(is, resourceID);
            try {
                println("{myName}: bytes of content available: {is.available()}");
            } finally {
                is.close();
                println("{myName}: *** Finished Parsing *** : {stringURL}");
                println("{myName}: TEMP COMPUTER: {tempComputer}");
                connection.updateStatus("{myName}: Finisihed parsing OCCI Computer");
            }
        }
    }
    request.start();
}

/**
* An HTML Parserer for the OCCI content of the resource.
* @Param is: the input stream.
*/
public function processHTMLResults(is: InputStream, resourceID : String) : Void {
    println("{myName}: Processing Results: Parsing on InputStream ---------- ResourceID:{resourceID}");
    RID=resourceID;
    var htmlPage: String = "";

    try {
       println("{myName}: bytes of content available: {is.available()}");

       // Here is the new way - invoking a Java class to parse the stream:
       var htmlParser: OCCIComputeHTMLParser_1_0;
       htmlParser = new OCCIComputeHTMLParser_1_0(RID, computerHostname);
       var newcomputer: OCCIComputeType=new OCCIComputeType(RID);

       newcomputer = htmlParser.parseInput(is);
       connection.updateStatus("{myName}: Storing {newcomputer.getHostname()} ID:{newcomputer.getID()}");
       controller.dataManager.insertComputeType(newcomputer);

       //
       //Below is alternate/old way that uses fucntions in this class:
       //
       //parseInput(is, resourceID);


    } catch (e: java.io.IOException) {
       println("{myName}: Parsing Exception.");
       e.printStackTrace();
    }

    try {
       is.close();
    } catch (e: java.io.IOException) {
       e.printStackTrace();
    }
    controller.cloudView.loadComputeList();

}

function parseInput(is: InputStream, resourceID : String) {
    var dis: DataInputStream = new DataInputStream(is);
    var isr: InputStreamReader = new InputStreamReader(dis);
    var br: BufferedReader = new BufferedReader(isr);
    var strLine: String = "";
    //Read File Line By Line
    while ((strLine = br.readLine()) != null)   {
      // Print the content on the console
      println("{myName}: Line: {strLine}" );
      if (strLine.startsWith("Category:")) {
          var catStart;
          var catEnd;
          catStart=strLine.indexOf("Category:");
          catEnd=strLine.indexOf(";");
          var category: String;
          category=strLine.substring(10, catEnd);
          println("{myName}: Category Start/End...{catStart}/{catEnd}");
          println("{myName}: Found Category...{category}");
          if (category.equals("compute")) {
             processComputeCategory(strLine, resourceID);
          }
      } else {
          if ( strLine.startsWith("X-OCCI-Attribute:")) {
              processComputeAttribute(strLine);
          }
      }

   }
   processEndOfLine();
}


/**
* Invoked for each new start element tag.
* @Param event the event information
*/
function processComputeCategory(input: String, resourceID : String) {
    // Create a new compute node:
    var newID: String=resourceID;
    var idStart;
    var idEnd;
    idStart=input.indexOf("title=\"");
    if ( idStart > 0) {
        idEnd=input.lastIndexOf("\"");
        newID=input.substring(idStart+7, idEnd);
        println("{myName}: Title Start/End...{idStart}/{idEnd}");
        println("{myName}: Found Title...[{newID}]");
    }
    var existingComputer: OCCIComputeType;

    existingComputer = controller.dataManager.getComputeType(RID);
    if (existingComputer != null ) {
       newID={newID}"-Duplicate";
    }
    tempComputer = new OCCIComputeType (RID);
    println("{myName}:#######  ####### Creating new Temp Computer ####### ####### {tempComputer}");



    tempComputer.setHostname(computerHostname); // default - not always accurate
    tempComputer.setCategory("compute");
    tempComputer.setTitle(newID); // default - not always accurate
    tempComputer.setCores(1); // default - not always accurate
    tempComputer.setArchitecture(OCCIComputeType.Architecture.x86);
    tempComputer.setMemory(1024); // default - not always accurate
    println("{myName}: Instantiating Temp computer: {tempComputer}");
}


function processComputeAttribute(input: String) {
        var catStart;
        var catEnd;
        catStart=input.indexOf("X-OCCI-Attribute: ");
        catEnd=input.indexOf("=");
        var OCCIattribute: String="";
        var attributeValue: String="";

        OCCIattribute=input.substring(catStart+18, catEnd);
        //println("{myName}: Attribute [{OCCIattribute}]");

        catStart=input.indexOf("=");
        attributeValue=input.substring(catStart+1);
        //println("{myName}: Start/End...{catStart}/{catEnd}");


        // If value starts and ends with qoutes, remove them:
        catStart=attributeValue.indexOf("\"");
        catEnd=attributeValue.lastIndexOf("\"");
        if (catStart >= 0 ) {
            attributeValue=attributeValue.substring(catStart+1, catEnd);
        }
        //println("{myName}: Value [{attributeValue}]");

        println("{myName}: Found Attribute: ]{OCCIattribute}]=[{attributeValue}]");
        if (OCCIattribute.equals("occi.compute.architecture")) {
           if ( attributeValue.equals("x86_64")) tempComputer.setArchitecture(OCCIComputeType.Architecture.x86_64);
           if ( attributeValue.equals("x86_32")) tempComputer.setArchitecture(OCCIComputeType.Architecture.x86_32);
           if ( attributeValue.equals("x86")) tempComputer.setArchitecture(OCCIComputeType.Architecture.x86);
           println("{myName}: Found architecture...{tempComputer.getArchitecture()}");

        }
        if (OCCIattribute.equals("occi.compute.state")) {
            if ( attributeValue.equals("active")) tempComputer.setStatus(OCCIComputeType.Status.ACTIVE);
            if ( attributeValue.equals("inactive")) tempComputer.setStatus(OCCIComputeType.Status.INACTIVE);
            if ( attributeValue.equals("suspended")) tempComputer.setStatus(OCCIComputeType.Status.SUSPENDED);
            println("{myName}: Found state...{tempComputer.getStatus()}");
        }
        if (OCCIattribute.equals("occi.compute.memory")) {
            try {
               tempComputer.setMemory(Float.parseFloat(attributeValue)); // default - not always accurate
            } catch (ne: NumberFormatException) {
               tempComputer.setMemory(0.07); // default - not always accurate
               println("{myName}: MEMORY Attribute non numeric...using default of 0.07");
            }
            println("{myName}: Found memory...{tempComputer.getMemory()}");
        }
        if (OCCIattribute.equals("occi.compute.speed")) {
            try {
               tempComputer.setSpeed(Float.parseFloat(attributeValue));
            } catch (ne: NumberFormatException) {
               tempComputer.setSpeed(-1.0);
               println("{myName}: SPEED Attribute non float...using default of -1.0");
            }
            println("{myName}: Found Speed...{tempComputer.getSpeed()}");

        }
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

        var newcomputer: OCCIComputeType=new OCCIComputeType(RID);
        newcomputer.setHostname(computerHostname);
        newcomputer.setTitle(tempComputer.getTitle());
        newcomputer.setSummary("summary");
        newcomputer.setMemory(tempComputer.getMemory() * 1024.0);
        newcomputer.setStatus(tempComputer.getStatus()); //state
        newcomputer.setCores(tempComputer.getCores());
        newcomputer.setCategory(tempComputer.getCategory());
        newcomputer.setSpeed(tempComputer.getSpeed());
        newcomputer.setArchitecture(tempComputer.getArchitecture());
        println("{myName}: *************** Storing computer new host:{newcomputer.getHostname()} ID:{newcomputer.getID()} Mem:{newcomputer.getMemory()}");
        connection.updateStatus("{myName}: Storing {newcomputer.getHostname()} ID:{newcomputer.getID()}");
        controller.dataManager.insertComputeType(newcomputer);

}
