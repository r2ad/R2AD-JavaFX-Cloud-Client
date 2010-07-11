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


package com.r2ad.cloud.cloudclient.model;

/*
 * CloudConnection.fx
 *
 * Created on Apr 30, 2010, 4:27:58 PM
 * @author David
*/
public class CloudConnection {

    public var connection : String = "Click Edit to Login...";
    public var user: String;
    public var credentials: String;
    public var connected: Boolean = false;
    public var error: Boolean = false;
    public var alternate: Boolean = false;  // not being used
    var status: StatusType[];

    // Custom toString() Method.
    override function toString(): String {
            var output: String;
            output = "\n\tconnection={connection}\n\tuser={user}\n\tcredentials={credentials}\n\ton-line={connected}";
            return output;
    }

    /**
     * Update the current connection status with the provided message String.
     * and a default alert of "false" meaning this is a normal (non-error) type
     * message.
     * @param msg - the status message to save
     */
    public function updateStatus(msg: String) {
        updateStatus(msg, false);
    }

    /**
     * Update the current connection status with the provided message String
     * and alert.
     * @param msg - the status message to save
     * @param isError - true if the status reflects an error condition
     */
    public function updateStatus(msg: String, isError: Boolean) {
        var newMsg = StatusType {
            message: msg;
            alert: isError
        }
        insert newMsg into status;
        if (isError) {
            this.error = true;
        }
    }

    /**
     * Return the current StatusType array for this connection.
     * @return the internal array of status messages.
     */
    public function getStatus() : StatusType[] {
        return status;
    }


    public function getAlternate() : Boolean {
        return alternate;
    }
    
}
