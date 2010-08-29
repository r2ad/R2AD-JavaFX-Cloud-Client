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
package com.r2ad.cloud.cloudclient.view;

import com.r2ad.cloud.cloudclient.utils.CDMIObjectChooser;

import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextBox;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.HBox;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.VBox;

import org.occi.model.OCCIStorageType;
import java.text.SimpleDateFormat;
import java.util.Locale;
import org.occi.model.StoredObject;
import java.io.File;
import javafx.scene.control.CheckBox;
import javafx.scene.paint.Color;

/**
 * Allows the user to modify the VM details such as its name,
 * core Count, Memory, notes, etc.
 * Also allows to delete the task.
 */
public class StorageEditorView extends AppView {

    // All the String/Text displayed in this view
    var createHeadingText: String = "Create Storage Resource";
    var editHeadingText: String = "Update Storage Resource";
    var doneButtonCreate: String = "Create";
    var doneButtonEdit: String = "Update";
    var nameLabelText: String = "Name:";
    var uploadButtonText: String = "Upload...";
    var defaultNameBoxText: String = "Provide Storage Name";
    var accessTimeText: String = "Access Time:";
    var createTimeText: String = "Create Time:";
    var modifiedTimeText: String = "Modified Time:";
    var filesLabelText: String = "File(s):";
    var notAvailableText: String = "N/A";
    var CDMIObjectFlag: Boolean;

    //var updateMode: Boolean;

    /*
    ** specify Locale.US since months are in english
    ** example: 2010-06-02T16:58:36
    */
    def timeFormat: SimpleDateFormat =
        new SimpleDateFormat ("yyyy-dd-MM'T'HH:mm:ss", Locale.US);

    /**
     * Storage Object represented by this editor view. The storage item that is
     * currently being edited is set by the controller.
     */
    public var storageType: OCCIStorageType on replace {
        if (storageType != null) {
            nameTextBox.text = storageType.getTitle();
            nameTextBox.commit();
        } else {
            println ("Storage Item being allocated...");
            storageType = dataManager.createOCCIStorageType();
            nameTextBox.text = defaultNameBoxText;
            nameTextBox.commit();
        }
        filesLabelText="File(s):";
        var storedObject: StoredObject = storageType.getObject();
        storedObject.setUploadFlag(false);
        var uploadFile: File = storedObject.getFile();
        println ("Debug - current uploadfile is {uploadFile.toString()}");
    }

   //
   // UI Labels
   //

    var accessTimeLabel: Label = Label {
        text: bind "{accessTimeText} {if (storageType.getAccessTime()==null)
            {notAvailableText} else timeFormat.format(storageType.getAccessTime()) }"
        textFill: defaultTextColor
        font: smallerTextFont
    }

    var createTimeLabel: Label = Label {
        text: bind "{createTimeText} {if (storageType.getCreateTime()==null)
            {notAvailableText} else timeFormat.format(storageType.getCreateTime()) }"
        textFill: defaultTextColor
        font: smallerTextFont
    }

    var modifiedTimeLabel: Label = Label {
        text: bind "{modifiedTimeText} {if (storageType.getModifiedTime()==null)
            {notAvailableText} else timeFormat.format(storageType.getModifiedTime())}"
        textFill: defaultTextColor
        font: smallerTextFont
    }

    var filesLabel: Label = Label {
        text: bind filesLabelText;
        textFill: defaultTextColor
        font: smallerTextFont
    }

    var headingLabel: Label = Label {
        text: bind if (storageType.getTitle() != null) then editHeadingText else createHeadingText;
        textFill: defaultTextColor
        font: defaultTextFont
    }

    var nameLabel: Label = Label {
        text: nameLabelText
        textFill: defaultTextColor
        font: defaultTextFont
    }

   //
   // UI Controls
   //

    var nameTextBox: TextBox = TextBox {
        columns: 20
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
            } else if (ke.code == KeyCode.VK_UP) {
                doneButton.requestFocus();
            }
        }
    }

    var cancelButton: Button = Button {
        text: cancelButtonText
        action: function() {
            controller.showStorageList();
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                doneButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                cancelButton.fire();
            }
        }
        layoutInfo: LayoutInfo { vpos: javafx.geometry.VPos.CENTER }
    }

    var doneButton: Button = Button {

        text: bind if (storageType.getTitle() != null) then doneButtonEdit else doneButtonCreate
        action: function() {
            nameTextBox.commit();
            if (storageType.getTitle() != null) {
                //Get rid of older one first:
                println("NOT removing older one from current model first: {storageType.getTitle()}");
//               dataManager.removeStorageType(storageType.getTitle());
// Do not want to actually send a delete to the server.
            }
            storageType.setTitle(nameTextBox.text);
            // Update the CDMI Content type flag:
            var storedObject: StoredObject;
            storedObject = storageType.getObject();
            if (storedObject != null) {
                storedObject.setCDMIContentType(CDMIObjectFlag);
            }            

            println("Model Change: {storageType.getTitle()} Action: {doneButton.text}");
            // Aug 2010 - added update action in support of object uploads.
            if (doneButton.text.equals("Create")) {
                dataManager.addStorageType(storageType);
            } else {
                dataManager.updateStorageType(storageType);
            }
            controller.showStorageList();
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                nameTextBox.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                cancelButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                doneButton.fire();
            }
        }
        layoutInfo: LayoutInfo { vpos: javafx.geometry.VPos.CENTER }
    }

    //
    // Note, In order for an applet to be able to access the local drive,
    // additional permission is required by the user.  Since this application
    // may be deployed as a WebStart application, the security entry would need
    // to have this added: java.io.FilePermission  read
    // in addtion to this for HTTP requests: j2ee-application-client-permissions
    //
    var uploadActionButton: Button = Button {
        text: uploadButtonText
        disable: false
        action: function() {
           var objectChooser: CDMIObjectChooser;
           objectChooser.setUploadCDMIObject();
           var storedObject: StoredObject;

           var uploadFile: File = objectChooser.getUploadFile();
           if (uploadFile != null) {
                //storageType.
                println ("Queuing object to process...file: {uploadFile.toString()}");
                storedObject = new StoredObject(uploadFile);
                //
                // Set the flag which is processed AFTER the contianer is updated/created.
                //
                storedObject.setUploadFlag(true);
                storedObject.setCDMIContentType(CDMIObjectFlag);
                storageType.addObject(storedObject);
                filesLabelText="Files: {uploadFile.toString()}";
                uploadActionButton.text="Delete"
                // Later on, process delete action, etc as a list of file objects.
           }

        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                doneButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
            } else if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                uploadActionButton.fire();
            }
        }      
    }

   //
   // UI Containers for the Controls and Labels
   //

    var headingBox = HBox {
        translateX: 50
        translateY: 5
        content: [headingLabel]
        layoutInfo: LayoutInfo {
            width: bind screenWidth - 20
            height: 30
        }
    }

    var nameHBox = HBox {
        content: [ nameLabel, nameTextBox ]
        spacing: 5
        translateX: 8
        layoutInfo: LayoutInfo {
            height: 30
        }
    }

    var timeVBox: VBox = VBox {
        content: [createTimeLabel, accessTimeLabel, modifiedTimeLabel]
        spacing: 5
        translateX: 8
        layoutInfo: LayoutInfo {
            height: 30
        }
    }

  def CDMIContentCheckbox : CheckBox =
        CheckBox {
        selected: bind CDMIObjectFlag with inverse
    };

    var CDMIContentBox: HBox = HBox {
       translateX: 5
       spacing: 3
       content: [
            CDMIContentCheckbox,
            Label {
                text: "CDMI Content Type"
                textFill: Color.ALICEBLUE }
    ]}


    var filesVBox: HBox = HBox {
        content: [ filesLabel, uploadActionButton ]
        spacing: 5
        translateX: 8
        translateY: 10
        layoutInfo: LayoutInfo {
            height: 40
        }
    }

    var bottomButtonBox: HBox = HBox {
        translateX: 30
        //translateY: 40
        content: [doneButton , cancelButton]
        spacing: 5
        layoutInfo: LayoutInfo {
            width: bind screenWidth - 25
            height: 20
        }
    }

    function idString(): String {
       var answer : String;
       answer = if (storageType.getID() == null ) "<empty>" else if
          (storageType.getID() == null ) "<empty>" else storageType.getID().toString();
       return answer;
    }

   /**
    * Initializes the view that represents this screen.
    */
    protected override function createView(): Void {
        defControl = nameTextBox;
        view = VBox {
            spacing: 15
            content: [
                headingBox,
                nameHBox,
                timeVBox,
                filesVBox,
                CDMIContentBox,
                bottomButtonBox
            ]
        };
    }
}
