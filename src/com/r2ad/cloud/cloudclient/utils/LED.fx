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


import javafx.scene.CustomNode;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.effect.Effect;
import javafx.scene.effect.Reflection;
import javafx.scene.paint.Color;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.image.Image;
import javafx.scene.effect.DropShadow;
import javafx.scene.text.Font;
import javafx.scene.text.Text;
import javafx.scene.layout.HBox;

/**
 * LED
 *
 * This class encapsulates a basic circular LED.
 */
/**
 * The reflection effect applied to the thumbnail if reflect is true.
 * This is a script-level variable because the values never change.
 */
def reflection: Effect = Reflection {
            fraction: 0.4
            topOpacity: 0.5
            bottomOpacity: 0.0
            topOffset: 1
        }

def redLEDImage = Image {
    url: "{__DIR__}images/led-red.png"
}
def yellowLEDImage = Image {
    url: "{__DIR__}images/led-yellow.png"
}
def greenLEDImage = Image {
    url: "{__DIR__}images/led-green.png"
}

public class LED extends CustomNode {

    protected var defaultTextColor: Color = Color.WHITE;
    protected var defaultTextFont:Font = Font.font("Veranda", 15);

    public var greenState = 0;
    public var yellowState = 1;
    public var redState = 2;

    public var greenStateText: String;
    public var yellowStateText: String;
    public var redStateText: String;

    public var state = greenState on replace {
       if (state == greenState) {
          currentImage = greenLEDImage;
          currentStateText = greenStateText;
       } else if (state == yellowState) {
          currentImage = yellowLEDImage;
          currentStateText = yellowStateText;
       } else if (state == redState) {
          currentImage = redLEDImage;
          currentStateText = redStateText;
       }
    }

    /** Set to true to have a reflection effect applied to the thumbnail */
    public var reflect: Boolean = false;

    /** set to the LED based on current state */
    var currentImage = redLEDImage;
    var currentStateText = greenStateText;


    var groupEffect: Effect = if (reflect) then reflection else DropShadow {
        offsetY: 2
        offsetX: 2
        color: Color.color(0.4, 0.4, 0.4)
    };

    var toolTip = Text {
        opacity: 0
        fill: defaultTextColor
        font: defaultTextFont
        content: bind currentStateText
    };

    var LEDImage = ImageView {
        image: bind currentImage;
        fitWidth: 32
        fitHeight: 16
        onMouseClicked: function(evt : MouseEvent) : Void {
            nextState();
        }
        onMouseMoved: function( e: MouseEvent ):Void {
            toolTip.opacity = 0.8;
        }
        onMouseExited: function( e: MouseEvent ):Void {
            toolTip.opacity = 0.0;
        }

    }

    function nextState() {
        if (state == redState) {
            state = greenState;
        } else {
            state++;
        }
    }

    /**
     * Thumbnail now includes a watermark in addition to the thumbnail image
     * and the invisible rectangle.
     */
    protected override function create(): Node {
        Group {
            effect: groupEffect;
            content: [
               HBox {content: [ LEDImage, toolTip]}
            ]
        }
    }




}
