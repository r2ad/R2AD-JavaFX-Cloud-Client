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

package com.r2ad.cloud.cloudclient.utils;
import java.lang.Exception;

/*
 * The <code>stringUtilities</code> is a library of useful utilities for string manipulation.
 * Included are validators and converters which can be used for parsing and checking input.
 * Created on Aug 8, 2010, 10:51:23 PM
 * @copyright Copyright 2010, R2AD, LLC.
 * @author behrens@r2ad.com
 */
public class stringUtilities {


    // Example validation function which cna be used for some fields
    function validateZipCode(zipcode:String): Boolean {
        //
        // Zip Code Format -> 12345 or 12345-1234
        //
        try {
            if(zipcode.length() == 5) {
                var zipCodeInt = java.lang.Integer.valueOf(zipcode).intValue();
                return (zipCodeInt > 0);
            } else if (zipcode.length() == 10) {
                var dashIndex = zipcode.indexOf("-");
                if(dashIndex != 5) return false;
                var firstPart = zipcode.substring(0, dashIndex);
                var zipCodeInt = java.lang.Integer.valueOf(firstPart).intValue();
                if(zipCodeInt <= 0) { return false; }
                var secondPart = zipcode.substring(0, dashIndex);
                zipCodeInt = java.lang.Integer.valueOf(secondPart).intValue();
                return (zipCodeInt > 0);
            }
        } catch (e:Exception) { }
        return false;
    }


    // Trim the string if length is greater than specified length
    function trimString(string:String, length:Integer) : String {
        if(string == null) return "";
        if(string.length() > length) {
            return "{string.substring(0, length).trim()}...";
        } else {
            return string;
        }
    }

}
