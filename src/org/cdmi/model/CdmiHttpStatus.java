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
package org.cdmi.model;

/**
 * HTTP status code mappings.
 * @author David Moolenaar, R2AD LLC 4/21/2010
 */
public interface CdmiHttpStatus {

    /** Resource retrieved successfully */
    public static int OK = 200;

    /** Resource created successfully */
    public static int Created = 201;

    /** Long running operation accepted for processing */
    public static int Accepted = 202;

    /** Operation successful, no data */
    public static int No_Content = 204;

    /** The URI is a reference to another URI. */
    public static int Found = 302;

    /** The operation conflicts because the object already exists
     * and the X-CDMI-NoClobber header element was set to "true"
     */
    public static int Not_Modified = 304;

    /** Missing or invalid request contents */
    public static int Bad_Request = 400;

    /** Invalid authentication/authorization credentials */
    public static int Unauthorized = 401;

    /** This user is not allowed to perform this request */
    public static int Forbidden = 403;

    /** Requested resource not found */
    public static int Not_Found = 404;

    /** Requested HTTP verb not allowed on this resource */
    public static int Method_Not_Allowed = 405;

    /** No content type can be produced at this URI
     * that matches the request */
    public static int Not_Acceptable = 406;

    /** The operation conflicts with a non-CDMI access protocol
     * lock, or could cause a state transition error on the server. */
    public static int Conflict = 409;

    /** An unexpected vendor specific error */
    public static int Internal_Server_Error = 500;

    /** A CDMI operation or metadata value was attempted
     * that is not implemented */
    public static int Not_Implemented = 501;

}
