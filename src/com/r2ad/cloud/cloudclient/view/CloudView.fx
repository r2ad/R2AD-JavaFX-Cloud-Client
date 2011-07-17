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

import com.r2ad.cloud.cloudclient.model.CloudConnection;
import com.r2ad.cloud.cloudclient.view.swing.CloudTreeNode;
import com.r2ad.cloud.cloudclient.view.swing.SwingTree;

import javafx.geometry.HPos;
import javafx.scene.Group;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextBox;
import javafx.scene.control.Toggle;
import javafx.scene.control.ToggleButton;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.HBox;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.shape.Rectangle;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.control.ToggleGroup;
import java.lang.Void;

/**
 * CloudView provides a tree of OCCI Compute and CDMI Storage resources
 * maintained in OCCI Cloud implementation.
 */
public class CloudView extends AppView {

    def buttonGroup: ToggleGroup  = ToggleGroup { } ;
    var addAction: Boolean = false;
    var deleteAction: Boolean = false;
    var currentConnection: CloudConnection;
    // All the String/Text displayed in this view
    var notConnectedString : String = "Edit your Credentials";
    var addComputeMessage: String = "Creating Compute Resource";
    var addStorageMessage: String = "Creating Storage Resource";
    var removeComputeMessage: String = "Deleting Compute Resource";
    var removeStorageMessage: String = "Deleting Compute Resource";
    var editConnectionMessage: String = "Updating Cloud Connection";
    var createConnectionMessage: String = "Updating Cloud Connection";
    var computeText: String = "Compute";
    var storageText: String = "Storage";
    var statusButtonText: String = "Log";
    var versionNumber: String = "v0.62";
    var viewTitleText: String = "R2AD Cloud Client {versionNumber}";

    var progress: Number = bind progressVal on replace {
        if (progress >= 100) {
            if (selectedToggle.value == computeText) {
                if (addAction == true ) {
                    addAction = false;
                    controller.showComputeModelView(null);
                } else if (deleteAction == true) {
                    deleteAction = false;
                    controller.showComputeList();
                } else {
                    controller.showComputeModelView(
                    storageTree.selectedValue.toString());
                }
            } else {
                if (addAction == true) {
                    addAction = false;
                    controller.showStorageModelView(null);
                } else if (deleteAction == true) {
                    deleteAction = false;
                    controller.showStorageList();
                } else {
                    controller.showStorageModelView(
                        storageTree.selectedValue.toString());
                }
            }
        }
    }

    public var rootNode: CloudTreeNode on replace{
    };

    protected override function deleteData() {
        deleteAction = true;
        if (selectedToggle.value == computeText) {
            showProgress(removeStorageMessage);
            dataManager.removeComputeType(storageTree.selectedValue.toString());
        } else {
            showProgress(removeStorageMessage);
            dataManager.removeStorageType(storageTree.selectedValue.toString());
        }
        populateTree();
    }

    var selectedToggle: Toggle = bind buttonGroup.selectedToggle on replace {        
        if (selectedToggle != null) {
            populateTree();
        } 
    }

    public function loadComputeList() {
        if (computeViewButton.selected == true) {
            computeViewButton.fire();
        }
        computeViewButton.fire();
    }

    public function loadStorageList() {
        if (storageViewButton.selected == true) {
            storageViewButton.fire();
        }
        storageViewButton.fire();
    }

    public function populateTree() {
        var tempNode: CloudTreeNode;
        if (selectedToggle.value == computeText) {
            currentConnection = dataManager.getComputeConnection();
            tempNode = new CloudTreeNode(dataManager.getComputeTypes());
        } else {
            currentConnection = dataManager.getStorageConnection();
            tempNode = new CloudTreeNode(dataManager.getStorageTypes());
        }
        dataManager.setSelectedConnection(currentConnection);
        rootNode = tempNode;
        addAction = false;
        connectionField.text = currentConnection.connection;

        if (currentConnection.connected) {
           if (currentConnection.error) {
                logButton.style = ""
                "    -fx-font: 12pt \"Amble\";"
                "    -fx-base: #FFFF00;"
                "    -fx-background: #FFFF00;"
           } else {
                logButton.style = ""
                "    -fx-font: 12pt \"Amble\";"
                "    -fx-base: #224634;"
                "    -fx-background: #224634;"
           }
        } else if (logButton.disable == false) {
            logButton.style = ""
            "    -fx-font: 12pt \"Amble\";"
            "    -fx-base: #FF0000;"
            "    -fx-background: #FF0000;";
           connectionButton.requestFocus();
        }
    }

    var createButton: Button = Button {
        text: createButtonText
        //disable: bind currentConnection.connected == false
        action: function() {
            addAction = true;
            if (selectedToggle.value == computeText) {
                showProgress(addComputeMessage)
            } else {
                showProgress(addStorageMessage)
            }

        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                //urlTextField.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                //list.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
                // or ke.code == KeyCode.VK_SPACE) {
                createButton.fire();
            }
        }
    }

    var deleteButton: Button = Button {
        text: deleteButtonText
        disable: bind if (selectedToggle.value == computeText or
            storageTree.selectedValue == null) then true else false;
        action: function() {
            if (storageTree.selectedValue != null and storageTree.selectedValue != "") {
                deleteConfirmation(storageTree.selectedValue.toString());
            }
        }        
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                updateButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
               //urlTextField.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
                //or  ke.code == KeyCode.VK_SPACE) {
                deleteButton.fire();
            }
        }
    }

    var updateButton: Button = Button {
        text: updateButtonText
        action: function() {
            if (storageTree.selectedValue != null) {
                showProgress("Opening {storageTree.selectedValue.toString()}");
            }
        }
        disable: bind
        if (storageTree.selectedValue == null) then true else false;
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
            } else if (ke.code == KeyCode.VK_UP) {
            } else if (ke.code == KeyCode.VK_ENTER) {
                updateButton.fire();
            }
        }
    }

    /* OCCI Cloud Computer VM retrieval */
    var computeViewButton: ToggleButton = ToggleButton {
        text: computeText
        value: computeText
        width: 100
        toggleGroup: buttonGroup
        layoutInfo: LayoutInfo {
            width: bind storageTree.width / 2
        }
        graphic: ImageView {
        image: Image {
            url: "{__DIR__}images/vm.png"
        }
        }
        graphicHPos: HPos.RIGHT
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                //allButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                //medButton.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
               //or ke.code == KeyCode.VK_SPACE) {
                //lowButton.fire();
            }
        }
    }

    /* CDMI Cloud Storage Retrieval */
    var storageViewButton: ToggleButton = ToggleButton {
        text: storageText
        value: storageText
        toggleGroup: buttonGroup
        width: 100
        layoutInfo: LayoutInfo {
            width: bind storageTree.width / 2
        }
        graphic: ImageView {
        image: Image {
            url: "{__DIR__}images/storage.png"
        }
        }
        graphicHPos: HPos.RIGHT
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
            } else if (ke.code == KeyCode.VK_UP) {
            } else if (ke.code == KeyCode.VK_ENTER) {
            }
        }
    }

    var bgRect:Rectangle = Rectangle {
        width: bind storageTree.width
        height: bind connectionButton.height + 3
        arcWidth: 5
        arcHeight: 5
        fill:  defaultTextColor
        stroke: Color.SLATEGREY
        strokeWidth:2
    }

    var connectionField: TextBox = TextBox {
        blocksMouse: true
        editable: false
        columns: 16
        selectOnFocus: false
        onKeyPressed:function(e:KeyEvent) {
            if (e.code == KeyCode.VK_UP) {               
            } else if(e.code == KeyCode.VK_RIGHT) {
                connectionButton.requestFocus();
            } else if (e.code == KeyCode.VK_ENTER) {
                connectionButton.fire();
            }
         }
         onMousePressed: function (e: MouseEvent){
             if (e.clickCount >= 2) {
                 connectionButton.fire();
             }
         }
         layoutInfo: LayoutInfo { vpos: javafx.geometry.VPos.CENTER }
    }

    var connectionButton: Button = Button {
        text: editButtonText
        action: function() {
            addAction = false;
            var occiRequest = computeViewButton.selected;
            controller.showLoginView(occiRequest);
            logButton.disable = false;
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
            } else if (ke.code == KeyCode.VK_UP) {
                connectionField.requestFocus();
            } else if (ke.code == KeyCode.VK_ENTER) {
                connectionButton.fire();
            }
        }
    }

    var logButton: Button = Button {
        text: statusButtonText
        disable: true
        action: function() {
            var temp: String = "Storage";
            if (selectedToggle.value == computeText) {
                temp = "Compute"
            }
            controller.showConnectionStatusView(temp);
        }
        style: ""
        "    -fx-font: 12pt \"Amble\";"
        "    -fx-base: #224634;"
        "    -fx-background: #224634;"
    }

    var storageTree = SwingTree {
        root: bind rootNode
        width: 200
        action: function(obj:Object){
            //println("CLV: Selected Object: {obj}");
        }
        translateX: 5
        translateY: 6
        layoutInfo: LayoutInfo {
            width: bind screenWidth-25
            height: bind (screenHeight - 176)
        }
    }

    var headingLabel: Label = Label {
        text: viewTitleText
        textFill: defaultTextColor
        font: defaultTextFont
    };

    var topButtonBox: HBox = HBox {
        translateX: 5
        content: [computeViewButton, storageViewButton ]
    }

    var headingBox = HBox {
        translateY: 4
        translateX: 20
    	content: [headingLabel]
        hpos: HPos.CENTER
        layoutInfo: LayoutInfo {
            width: bind storageTree.width
            height: 30
        }
    }

    var connectionHBox = HBox {
        spacing: 1
        content: [connectionField, connectionButton, logButton]
        layoutInfo: LayoutInfo {
            width: bind storageTree.width
            hpos: HPos.LEFT
            height: 22
        }
    }

    var connectionBox = HBox {
        translateX: 4
        content: bind [
            Group {
                focusTraversable: true
                content: [bgRect, connectionHBox]

            }]
        layoutInfo: LayoutInfo {
            width: bind storageTree.width
            height: 22
        }
    }
    
    var bottomButtonBox: HBox = HBox {
        translateY: 10
        width: 100
        content: [createButton, updateButton, deleteButton]
        spacing: 4
        hpos: HPos.CENTER
        layoutInfo: LayoutInfo {
            width: bind storageTree.width
        }
    }

    protected override function createView(): Void {
        view = VBox {
            content: [
                headingBox,
                topButtonBox,
                connectionBox,
                storageTree,
                bottomButtonBox,
            ]
        };
        computeViewButton.selected = true;
    }
}
