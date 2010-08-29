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
package com.r2ad.cloud.cloudclient.utils;

/**
 * Stub for now...need to implement in future to store objects.
 * com.r2ad.cloud.cloudclient.utils.CDMIObjectChooser
 * @author JavaFX@r2ad.com
 */

import java.io.File;
import java.io.FileInputStream;
import javax.swing.JFileChooser;
import org.occi.model.StoredObject;

var uploadFile: File = null;

public function setUploadCDMIObject() : Void {
    // File chooser
    def extensions = ["*.*"];
    def chooser = new JFileChooser();
    var inputStream: FileInputStream;
    var storedObject: StoredObject;

     if (JFileChooser.APPROVE_OPTION == chooser.showOpenDialog(null)) {
        uploadFile = chooser.getSelectedFile();
        println("----Source file = {uploadFile}");
        // Get the number of bytes in the file
        var length = uploadFile.length();
        inputStream = new FileInputStream(uploadFile);
        println("Creating a store object for container, size= {length}");
        //
        // This is temporarily here - it should belong in the model, as part of an
        // initial object or perhaps an array of objects if they item is being edited.
        //
        storedObject = new StoredObject(uploadFile);
     }
}

public function getUploadFile(): File {
    return uploadFile;
}
