/**
 DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the R2AD, LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 * PasswordBox.fx
 * source http://blog.alutam.com/2009/09/12/javafx-password-field/
 * better than: http://jfx.wikia.com/wiki/SwingComponents
 * Created on Feb 28, 2010, 10:56:32 AM
 */

package com.r2ad.cloud.cloudclient.utils;

import javafx.scene.control.TextBox;
import javafx.util.Math;

/**
 * Found public source code - added to project for password field support.
 * @author Martin Matula
 */
 // Example usage:
 // replaceSelection("password") on the password field after it’s initialization
 // ie:  passwordField.replaceSelection("mypasswrd");
public class PasswordBox extends TextBox {
    public-read var password = "";

    override function replaceSelection(arg) {
        var pos1 = Math.min(dot, mark);
        var pos2 = Math.max(dot, mark);
        password = "{password.substring(0, pos1)}{arg}{password.substring(pos2)}";
        super.replaceSelection(getStars(arg.length()));
    }

    override function deleteNextChar() {
        if ((mark == dot) and (dot < password.length())) {
            password = "{password.substring(0, dot)}{password.substring(dot + 1)}";
        }
        super.deleteNextChar();
    }

    override function deletePreviousChar() {
        if ((mark == dot) and (dot > 0)) {
            password = "{password.substring(0, dot - 1)}{password.substring(dot)}";
        }
        super.deletePreviousChar();
    }


    function getStars(len: Integer): String {
        var result: String = "";
        for (i in [1..len]) {
            result = "{result}*";
        }
        result;
    }
}

