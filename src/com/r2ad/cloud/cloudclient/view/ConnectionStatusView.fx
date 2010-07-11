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

import com.r2ad.cloud.cloudclient.model.StatusType;

import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ListCell;
import javafx.scene.control.ListView;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.HBox;
import javafx.geometry.HPos;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import java.lang.Void;

/**
 * Allows the user to view a CloudConnection status log.
 * Created on Jun 7, 2010, 11:23:48 AM
 * @author David K. Moolenaar, R2AD LLC
 */
public class ConnectionStatusView extends AppView {

    public var description: String = "Connection";
    public var headingText: String = "Log Viewer";
    public var listContent: StatusType[];

   //
   // UI Labels
   //

    var headingLabel: Label = Label {
        text: bind "{description} {headingText}"
        textFill: defaultTextColor
        font: defaultTextFont
    };

   //
   // UI Controls
   //

    var list: ListView = ListView {
        translateX: 5
        translateY: 6
        layoutInfo: LayoutInfo {
            width: bind screenWidth-32
            height: bind (screenHeight - 176)
        }
        items: bind
        for(conn in listContent) {
            conn;
        }
        cellFactory: function () {
            def cell: ListCell = ListCell {
                node: Label {
                    textFill: bind if ((cell.item as StatusType).alert)
                        then Color.RED else Color.BLACK
                    text: bind if (cell.empty) then "" else "{cell.item}"
                }
            }
        }
    }

    var okButton: Button = Button {
        text: okButtonText
        action: function() {
            controller.showCloudList();
        }
        onKeyPressed: function (ke: KeyEvent) {
            if (ke.code == KeyCode.VK_ENTER) {
                okButton.fire();
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

    var bottomButtonBox: HBox = HBox {
        translateY: 40
        content: [okButton]
        spacing: 4
        hpos: HPos.CENTER
        layoutInfo: LayoutInfo {
            width: bind screenWidth - 25
            height: 20
        }
    }

    protected override function createView(): Void {
        view = VBox {
            content: [
                headingBox,
                list,
                bottomButtonBox,
            ]
        };
    }
}