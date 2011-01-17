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

import java.net.URI;

import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.TextBox;
import javafx.scene.control.Slider;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.HBox;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.VBox;

import org.occi.model.OCCIComputeType;
import org.occi.model.OCCIStorageType;

/**
 * Allows the user to delete VM or modify details such as the name,
 * core count, memory, storage, and auto boot.

 * @author David K. Moolenaar, R2AD LLC
 */
public class ComputeEditorView extends AppView {

    // All the String/Text displayed in this view
    var createHeadingText: String = "Create Compute Resource";
    var editHeadingText: String = "Update Compute Resource";
    var doneButtonCreate: String = "Create";
    var doneButtonEdit: String = "Update";
    var storageText: String = "Storage:";
    var nameLabelText: String = "Name:";
    var archLabelText: String = "Architecture";
    var coresLabelText: String = "Cores:";
    var storageLabelText: String = "CDMI Storage:";
    var statusLabelText: String = "Status:";
    var memoryLabelUnitsText: String = "MB";
    var memoryLabelText: String = "Memory Allocation:";
    //var updateMode: Boolean;
    var storageContent: OCCIStorageType[];

    public var computeType: OCCIComputeType on replace {
        //updateMode = (computeType != null);
        storageContent = dataManager.getStorageTypes();
        if (computeType != null) {
            nameTextBox.text = computeType.getTitle();
            nameTextBox.commit();
            architectureChoiceBox.select(computeType.getArchitectureAsInt());
            var coreCnt = computeType.getCores();
            coresChoiceBox.select(java.lang.Math.max(0, coreCnt-1));
            statusChoiceBox.select(computeType.getStatusAsInt());
            memorySlider.value = computeType.getMemory();
            if (sizeof storageContent > 0) {
                storageChoiceBox.select(0);
                var links: URI[] = computeType.getLinks();
                if (sizeof links > 0) {
                    println("Links Size is {sizeof links} and first is {links[0]}");
                    var index = -1;
                    while (++index < sizeof storageContent) { 
                        println("Looking at {storageContent[index].getURI()}");
                        if (storageContent[index].getURI().equals(links[0])) {
                            storageChoiceBox.select(index);
                            println("Match at {index}");
                            break;
                        }       
                    }
                }
            }
        } else {
            nameTextBox.commit();
            architectureChoiceBox.select(0);
            coresChoiceBox.select(0);
            statusChoiceBox.select(0);
            storageChoiceBox.select(0);
            memorySlider.value = 1000;
        }
    }

   //
   // UI Labels 
   //

    var archLabel: Label = Label {
        text: archLabelText
        textFill: defaultTextColor
        font: defaultTextFont
    }

    var coreLabel: Label = Label {
        text: coresLabelText
        textFill: defaultTextColor
        font: defaultTextFont
    }

    var headingLabel: Label = Label {
        text: bind if (computeType != null) then editHeadingText else createHeadingText;
        textFill: defaultTextColor
        font: defaultTextFont
    }

    var memoryLabel: Label = Label {
        text: bind "{memoryLabelText} {memorySlider.value.intValue().
            toString()} {memoryLabelUnitsText}"
        textFill: defaultTextColor
        font: defaultTextFont
    }

    var nameLabel: Label = Label {
        text: nameLabelText
        textFill: defaultTextColor
        font: defaultTextFont
    }

    var storageLabel: Label = Label {
        text: storageLabelText
        textFill: defaultTextColor
        font: defaultTextFont
    }

    var statusLabel: Label = Label {
        text: statusLabelText
        textFill: defaultTextColor
        font: defaultTextFont
    }

   //
   // UI Controls
   //

    var memorySlider: Slider = Slider {
        min: 0
        max: 1024*6
        showTickLabels: false
        showTickMarks: false
        majorTickUnit: 64
        minorTickCount: 16
        width: bind screenWidth - 60
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                cancelButton.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
            }
        }
    }

    var coresChoiceBox = ChoiceBox {
        items: ["1", "2", "3", "4", "5", "6", "7", "8"]
    };

    var architectureChoiceBox = ChoiceBox {
        items: OCCIComputeType.ArchString
    };

    var statusChoiceBox = ChoiceBox {
        items: OCCIComputeType.StatusString
    };

    var storageChoiceBox = ChoiceBox {
        items: bind storageContent
    };

    var nameTextBox: TextBox = TextBox {
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_DOWN) {
                architectureChoiceBox.requestFocus();
            } else if (ke.code == KeyCode.VK_UP) {
                doneButton.requestFocus();
            }
        }
        onKeyTyped: function(ke: KeyEvent):Void {
            nameTextBox.commit();
        }
    }

    var cancelButton: Button = Button {
        text: cancelButtonText
        action: function() {
            controller.showComputeList();
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
    }

    var doneButton: Button = Button {
        text: bind if (computeType != null) then doneButtonEdit else doneButtonCreate
        disable: bind if (nameTextBox.text.length() < 2) true else false;
        action: function() {
            nameTextBox.commit();
            var cType = dataManager.createOCCIComputeType();
            cType.setTitle(nameTextBox.text);
            cType.setArchitecture(architectureChoiceBox.selectedIndex);
            cType.setCores(coresChoiceBox.selectedIndex + 1);
            cType.setStatus(statusChoiceBox.selectedIndex);
            cType.setMemory(memorySlider.value);
            if (sizeof storageContent > 0) {
                var selStorage = storageChoiceBox.selectedItem;
                cType.addLink((selStorage as OCCIStorageType).getURI());
            }
            if (computeType != null) {
                dataManager.removeComputeType(computeType);
            }
            dataManager.addComputeType(cType);
            controller.showComputeList();
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
    }

   //
   // UI Containers for the Controls and Labels
   //
    var headingBox = HBox {
        translateX: 45
        translateY: 5
        content: [headingLabel]
        layoutInfo: LayoutInfo {
            height: 30
        }
    }

    var nameVBox = VBox {
        content: [ nameLabel, nameTextBox ]
        spacing: 3
        translateX: 8
    }

    var architectureVBox = VBox {
        content: [archLabel, architectureChoiceBox]
        spacing: 3
        translateX: 8
    }

    var coresVBox = VBox {
        content: [coreLabel, coresChoiceBox]
        spacing: 3
        translateX: 8
    }

    var stateVBox = VBox {
        content: [statusLabel, statusChoiceBox]
        spacing: 3
        translateX: 8
    }

    var architectureCoresHBox = HBox {
        content: [ architectureVBox, coresVBox ]
        spacing: 3
        translateX: 2
    }

    var storageVBox = VBox {
        content: [storageLabel, storageChoiceBox]
        spacing: 3
        translateX: 8
    }

    var memorySliderVbox: VBox = VBox {
        content: [memoryLabel, memorySlider]
        spacing: 3
        translateX: 8
    }

    var bottomButtonBox: HBox = HBox {
        translateX: 50
        content: [doneButton , cancelButton]
        spacing: 3
        layoutInfo: LayoutInfo {
            width: bind screenWidth-25
        }
    }

   /**
    * Initializes the view that represents this screen.
    */
    protected override function createView(): Void {
        defControl = nameTextBox;
        view = VBox {
            spacing: 6
            content: [
                headingBox,
                nameVBox,
                architectureCoresHBox,
                storageVBox,
                stateVBox,                
                memorySliderVbox,
                bottomButtonBox,
            ]
        };
    }
}
