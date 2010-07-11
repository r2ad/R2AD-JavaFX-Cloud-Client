/* 
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
 * Copyright 2009 Sun Microsystems, Inc. All rights reserved. Use is subject to license terms. 
 * 
 * This file is available and licensed under the following license:
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright notice, 
 *     this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *
 *   * Neither the name of Sun Microsystems nor the names of its contributors 
 *     may be used to endorse or promote products derived from this software 
 *     without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Main.fx
 * Modifed by R2AD, LLC in support of an open cloud client project.
 * visit: http://cloud.r2ad.net for more information.
 * Created on Apr 27, 2009, 2:39:51 PM
 */
package com.r2ad.cloud.cloudclient;

import javafx.scene.Group;
import javafx.scene.paint.Color;
import javafx.scene.paint.LinearGradient;
import javafx.scene.paint.Stop;
import javafx.scene.Scene;
import javafx.scene.shape.Rectangle;
import javafx.stage.Stage;
import com.r2ad.cloud.cloudclient.view.AppView;
import com.r2ad.cloud.cloudclient.controller.Controller;

/**
 * Application's Main class that instantiates the stage and initilizes
 * scene's contents. Also takes care of rendering the background,
 * Initializing the screen size and performing the necessary clean-ups on
 * application exit.
 */
/**
 * Denotes if the application is running on mobile.
 */
var mobile: Boolean = "{__PROFILE__}" == "mobile";

/**
 * Denotes if the application is running on browser.
 */
var browser: Boolean = "{__PROFILE__}" == "browser";

/**
 * Initializing the screen width and height here.
 */
AppView.screenWidth = 240;
AppView.screenHeight = 320;

/**
 * Background rectangle with gradience.
 */
var bgRect:Rectangle = Rectangle {
    width: bind AppView.screenWidth
    height: bind AppView.screenHeight
    arcWidth: bind if (not mobile) 15 else 0
    arcHeight: bind if (not mobile) 15 else 0

    /*
    onMouseDragged: function(me: MouseEvent) {
        if (not browser and not mobile) {
            stage.x = me.screenX - me.dragAnchorX;
            stage.y = me.screenY - me.dragAnchorY;
        }
    }
    */
    fill:  LinearGradient {
    endY: 0
    stops: [
      Stop { offset: 0   color: Color.rgb(0,  0, 63, 0.8) }
      Stop { offset: 1   color: Color.rgb(100, 175, 255, 0.8) }
    ]
  }


}


/**
 * Controller that controls the screen navigation is initialized here.
 */
var controller = new Controller;

/**
 * Application's main stage.
 */
var stage: Stage = Stage {
    title: "Cloud Client"   
    scene: Scene {
        width: AppView.screenWidth
        height: AppView.screenHeight
        fill: Color.BLUE
        content: bind [
            Group {
                focusTraversable: true
                content: [bgRect, /*buttonGroup, exitButton*/]

            }, controller.contents]
    }
}

var boundHeight = bind stage.height on replace {
      //bgButtonRect.y =  stage.height - bgButtonRect.height - 40;
      AppView.screenHeight = stage.height;
};

var boundWidth = bind stage.width on replace {
      //bgButtonRect.width =  stage.width-15;
      AppView.screenWidth = stage.width;

};

// Show the first screen.
controller.showComputeList();
