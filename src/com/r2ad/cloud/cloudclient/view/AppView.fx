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
 * AppView.fx
 * Modifed extensibly by R2AD, LLC in support of an open cloud client project.
 * visit: http://cloud.r2ad.net for more information.
 * Created on Apr 27, 2009, 2:39:51 PM
 */

package com.r2ad.cloud.cloudclient.view;

import javafx.animation.Interpolator;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.animation.transition.FadeTransition;
import javafx.scene.*;
import javafx.scene.control.Button;
import javafx.scene.control.ProgressBar;
import javafx.scene.layout.HBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.Font;
import javafx.scene.text.Text;

import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;

import com.r2ad.cloud.cloudclient.controller.Controller;
import com.r2ad.cloud.cloudclient.model.CloudDataManager;

/**
 * Represents screen width. All the views are designed to be proportional with
 * respect to the screen size.
 */
public var screenWidth: Number;

/**
 * Represents screen height. All the views are designed to be proportional with
 * respect to the screen size.
 */
public var screenHeight: Number;

/**
 * Abstract Base class for all the views. This class abstracts the common functionalities
 * shared across by many views. This class abstracts the screen resolution also.
 *
 * Additionally this class provides a custom implementation of Alerts that are
 * shared by many view classes. Alerts are typically shown during screen navigation
 * and deletion of data.
 */
public abstract class AppView extends CustomNode {

    protected var defaultTextColor: Color = Color.WHITE;
    protected var defaultTextFont:Font = Font.font("Veranda", 15);
    protected var smallerTextFont:Font = Font.font("Veranda", 12);
    protected var createButtonText: String = "Create...";
    protected var deleteButtonText: String = "Delete";
    protected var updateButtonText: String = "Update...";
    protected var editButtonText: String = "Edit...";
    protected var okButtonText: String = "Ok";
    protected var cancelButtonText: String = "Cancel";
    protected var urlText: String = "URL";

    /**
     * Handle to the data handler and the actual data.
     */
    public var dataManager: CloudDataManager = bind controller.dataManager;

    /**
     * Handle to the controller that controls the screen navigation.
     */
    public var controller: Controller;

    /**
     * Instance of the view added to the view content. Represents the
     * actual screen contents.
     */
    public var view: Node;

    /**
     * A node array that represents the actual screen and additional
     * dynamically added/removed nodes such as popups.
     */
    var viewContent: Node[] = [];

    /**
     * Handle to the initial/default control on the screen for the
     * purpose of focus restoration.
     */
    public var defControl: Node = null;

    /**
     * Abstract delete function to be overridden by the sub-classes of
     * AppView.
     */
    public function deleteData() {
        println("AV: Override this in order to perform deletion!");
    }

    /**
     * Abstract function that is overridden by the sub-classes.
     * This is where the actual screen contents are created in each
     * view class.
     */
    protected abstract function createView(): Void;

    public function loadData():Void {
    }
    /**
     * Embeds the view into view content and returns the same as a
     * custom node.
     */
    public override function create(): Node {
        loadData();  // restore any preference data first...
        createView();
        insert view into viewContent;
        return Group {
            content: bind viewContent
        }
    }

    /**
     * Progress Identifier that is used to keep track of the progress bar
     * value when opening a new screen. Individual views define a trigger
     * on this value to know if progress is 100%.
     */
    public-read protected var progressVal: Number = 0;

    /**
     * Popup Width and Height are constant but can be configured here.
     * The Popups can be made proportional to the screen size if needed.
     */
    var popupWidth = 220;
    var popupHeight = 320;

    /**
     * Fade Out Transition that is invoked when showing a popup.
     * This fades out the contents beneath the popup.
     */
    var fadeOut: FadeTransition = FadeTransition {
        duration: 400ms
        node: bind view
        fromValue: 1.0
        toValue: 0.3
        repeatCount: 1
        autoReverse: true
    }

    /**
     * Fade In Transition that is invoked when disposing a popup.
     * This fades in the contents beneath the popup when popup is disposed.
     */
    var fadeIn: FadeTransition = FadeTransition {
        duration: 400ms
        node: bind view
        fromValue: 0.3
        toValue: 1.0
        repeatCount: 1
        autoReverse: true
    }

    /**
     * This function shows a Popup with a progress bar on top of the
     * existing screen. The existing screen will be faded out and a new screen
     * will be loaded when progress is 100%.
     */
    public function showProgress (taskName: String) {
        progressVal = 0;

        /**
         * Title of the progress popup.
         */
        var progressTitle: Text = Text {
            content: taskName
            font: defaultTextFont
            wrappingWidth: bind popupWidth - 30
            translateY: 20
            translateX: 10
            fill: Color.BLACK
        };

        /**
         * The background rectangle that forms the popup.
         */
        var progressRect: Rectangle = Rectangle {
            x: 0
            y: 0
            width: bind popupWidth - 10
            height: bind (progressTitle.boundsInLocal.height * 2) + 30
            fill: Color.WHITE
            stroke: Color.BLACK
            strokeWidth: 2
            arcWidth: 20
            arcHeight: 20
        };

        /**
         * The progress bar that shows the progress of loading a screen.
         */
        var progressBar: ProgressBar = ProgressBar {
            progress: bind ProgressBar.computeProgress(100, progressVal)
            translateY: bind progressTitle.boundsInLocal.height + 20
            translateX: bind (progressRect.boundsInLocal.width - progressBar.boundsInLocal.width) / 2
        };

        /**
         * Parent group that holds the entire progress popup
         */
        var progressGroup: Group = Group {
            content: [progressRect, progressTitle, progressBar]
            blocksMouse: true
            translateX: bind screenWidth / 2 - progressGroup.boundsInLocal.width / 2  -10
            translateY: bind screenHeight / 2 - progressGroup.boundsInLocal.height / 2
        };

        insert progressGroup into viewContent;

        /**
         * Timeline that updates the progress value within the progress bar.
         * This is just a simulation of progress whereas the actual progress
         * will be computed in real-time for real applications.
         */
        var t: Timeline = Timeline {
            repeatCount: 1
            autoReverse: false
            keyFrames: [
                KeyFrame {
                    time: 0s
                    values: [progressVal => 0]
                    canSkip: true
                },
                KeyFrame {
                    time: 500ms
                    values: [progressVal => 100 tween Interpolator.LINEAR]
                    canSkip: true
                    action: function() {
                        fadeIn.playFromStart();
                        view.disable = false;
                        delete progressGroup from viewContent;
                    }
                }
            ]
        }
        fadeOut.playFromStart();
        view.disable = true;
        t.play();
    }

    /**
     * A popup that shows a message.
     */
    public function showMessage(message: String) {
        var messageText: Text = Text {
            content: message
            font: defaultTextFont 
            wrappingWidth: bind popupWidth - 30
            translateY: 40
            translateX: 10
            fill: Color.BLACK
        }

        /**
         * Background rectangle that forms the popup.
         */
        var messageRect: Rectangle = Rectangle {
            x: 0
            y: 0
            width: bind popupWidth - 10
            height: bind messageText.boundsInLocal.height + 40 + buttonBox.boundsInLocal.height
            fill: Color.WHITE
            stroke: Color.BLACK
            strokeWidth: 2
            arcWidth: 20
            arcHeight: 20
        }

        /**
         * A control to accept user input and dispose the popup.
         */
        var okBut: Button = Button {
            text: okButtonText
            strong: true
            action: function() {
                messageGroup.visible = false;
                view.disable = false;
                fadeIn.playFromStart();
            }
            onKeyPressed: function (ke: KeyEvent) {
                if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                    okBut.fire();
                }
            }
        }

        var buttonBox: HBox = HBox {
            spacing: 5
            content: [okBut]
            translateX: bind messageRect.boundsInLocal.width - (okBut.boundsInLocal.width + 10)
            translateY: bind messageText.boundsInLocal.height + 35
        }

        var messageGroup: Group = Group {
            content: [messageRect, messageText, buttonBox]
            blocksMouse: true
            translateX: bind screenWidth / 2 - messageGroup.boundsInLocal.width / 2 + messageRect.strokeWidth
            translateY: bind screenHeight / 2 - messageGroup.boundsInLocal.height / 2
        }

        insert messageGroup into viewContent;
        okBut.requestFocus();
        view.disable = true;
        fadeOut.playFromStart();
    }

    /**
     * A popup that asks for a confirmation from the user on deleting a task
     * or project. Delete button will invoke view's deleteData() function whereas
     * cancel button will just dispose the popup.
     */
    public function deleteConfirmation(itemName: String) {
        var deleteButtonBox: HBox;
        var deleteText: Text = Text {
            content: bind "Are you sure you want to delete {itemName}?"
            font: defaultTextFont
            wrappingWidth: bind popupWidth - 30
            translateY: 40
            translateX: 10
            fill: Color.BLACK
        }

        var deleteRect: Rectangle = Rectangle {
            x: 0
            y: 0
            width: bind popupWidth - 10
            height: bind deleteText.boundsInLocal.height + 40 + deleteButtonBox.boundsInLocal.height
            fill: Color.WHITE
            stroke: Color.BLACK
            strokeWidth: 2
            arcWidth: 20
            arcHeight: 20
        }

        var cancelBut: Button = Button {
            text: cancelButtonText
            strong: true
            action: function() {
                delete deleteGroup from viewContent;
                view.disable = false;
                fadeIn.playFromStart();

            }
            onKeyPressed: function (ke: KeyEvent) {
                if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                    cancelBut.fire();
                }
            }
        }

        var deleteBut: Button  = Button {
            text: deleteButtonText
            action: function() {
                println("AV: Delete Button Action 1");
                delete deleteGroup from viewContent;
                deleteData();
                view.disable = false;
                fadeIn.playFromStart();
            }

            onKeyPressed: function (ke: KeyEvent) {
                if (ke.code == KeyCode.VK_ENTER or
                ke.code == KeyCode.VK_SPACE) {
                    deleteBut.fire();
                }
            }
        }

        deleteButtonBox = HBox {
            spacing: 5
            content: [cancelBut, deleteBut]
            translateX: bind deleteRect.boundsInLocal.width - (cancelBut.boundsInLocal.width + deleteBut.boundsInLocal.width + 10)
            translateY: bind deleteText.boundsInLocal.height + 35
        }

        var deleteGroup: Group = Group {
            content: [deleteRect, deleteText, deleteButtonBox]
            blocksMouse: true
            translateX: bind screenWidth / 2 - deleteGroup.boundsInLocal.width / 2 + deleteRect.strokeWidth
            translateY: bind screenHeight / 2 - deleteGroup.boundsInLocal.height / 2
        }
        insert deleteGroup into viewContent;
        cancelBut.requestFocus();
        view.disable = true;
        fadeOut.playFromStart();

    }

}
