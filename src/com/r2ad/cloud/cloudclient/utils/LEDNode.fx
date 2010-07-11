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
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.scene.Node;
import javafx.animation.Interpolator;
import javafx.scene.paint.Color;
import javafx.scene.paint.RadialGradient;
import javafx.scene.paint.Stop;
import javafx.scene.shape.Circle;
import javafx.scene.control.Label;

/*
 * LEDNode.fx
 *
 * Created on May 24, 2010, 6:00:49 PM
 * @author JavaFX@r2ad.com
 */
var transX = 0.0;
var transY = 0.0;



public class LEDNode extends CustomNode {
    public var radius = 10.0;
    public var speed = 1;

    //var opacity = 1.0;

    var timeline: Timeline = Timeline {
        repeatCount: Timeline.INDEFINITE
        keyFrames : [
            KeyFrame {
                time : speed*100ms
                canSkip : true
                values : [
                opacity => 0.0 tween Interpolator.EASEOUT
                ]//values

            }//KeyFrame
            KeyFrame {
                time : speed*200ms
                canSkip : true
                values : [
                opacity => 1.0 tween Interpolator.EASEOUT
                ]//values

            }//KeyFrame
        ]
    }


    public override function create(): Node {
         var circle : Circle;
         var lightBlue = "#3B8DED";
         var lightGreen= "#56FF3C"; //#00C334";
         var darkGreen = "#00690E";
         var darkBlue = "#044EA4";

         circle = Circle {
             translateX: bind transX
             translateY: bind transY
             radius: bind radius
             opacity: bind opacity
             fill: RadialGradient {
                 centerX: -25
                 centerY: -25
                 radius: this.radius
                 proportional: false
                    stops: [
                        Stop {
                        offset: 0.0
                        color: Color.BLACK
                        //color: Color.web(lightGreen)
                        },
                        Stop {
                        offset: 1.0
                        color:Color.BLUE
                        //color:Color.web(darkGreen)
                        }
                    ] // stops
            } // RadialGradient
         }//Circle

         return circle;
    }


  public function start() {
    this.timeline.play();
  }

  public function stop() {
    this.timeline.stop();
  }

}
