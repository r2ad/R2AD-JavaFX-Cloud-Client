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
package com.r2ad.cloud.cloudclient.view;


import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.HBox;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import javafx.scene.text.TextOrigin;
import javafx.scene.control.TextBox;
import javafx.scene.control.PasswordBox;
import com.r2ad.cloud.cloudclient.model.CloudConnection;

/**
 * Shows the list of tasks categorized as High, Medium and Low.
 * Provides options to add new tasks, to view projects and to delete any existing
 * tasks.
 */
public class LoginView extends AppView {

    public var alternate: Boolean = false;
    var loggedIn: Boolean = false;
    var devPassword: String = "";
    //var notConnectedString: String = "No Connection";
    //var addComputeMessage: String = "Adding Compute Resource";
    var headingLabelText: String = "User Authentication";
    var loginButtonText: String = "Login";
    var loginFailedMessage: String = "Login unsuccessful, try again...";
    var nameLabelText: String = "User Name:";
    var nameFieldPrompt: String = "Enter cloud user name";
    var passwordLabelText: String = "Pass Phrase:";
    //var urlLabelText: String = "OCCI/CDMI URL";
    var urlFieldPrompt: String = "Enter Cloud URL";
    //var urlCheckBoxLabelText: String = "Apply URL:";
    //var cdmiCheckBoxLabelText: String = "CDMI";
    //var occiCheckBoxLabelText: String = "OCCI";
    public var occiRequest: Boolean = true on replace {
        if (occiRequest) {
            urlField.text = defaultOCCIServer;
        } else {
            urlField.text = defaultCDMIServer;
        }
    }

    // TBD: Keep recently used URLs in a local store and offer as a 
    // pull-down to users.
    def defaultOCCIServer="http://";
    def defaultCDMIServer="http://";


    public function isLoggedIn(): Boolean {
        return loggedIn;
    }

    public function logout() {
        loggedIn = false;
    }

    /*
    public function occiRequest(occi: Boolean) {
        //occiCheckBox.selected = occi;
        //cdmiCheckBox.selected = cdmi;
    }
    */

    var progress: Number = bind progressVal on replace {
                if (progress >= 100) {
                    println("Coming from 1");
                    controller.showComputeList();
                }
            }
    /**
     * Cancels the login operation and goes back to list view.
     */
    var cancelButton: Button = Button {
                text: cancelButtonText
                action: function () {
                    controller.showComputeList();
                }
                onKeyPressed: function (ke: KeyEvent) {
                    if (ke.code == KeyCode.VK_DOWN) {
                        loginButton.requestFocus();
                    } else if (ke.code == KeyCode.VK_UP) {
                    } else if (ke.code == KeyCode.VK_ENTER or ke.code == KeyCode.VK_SPACE) {
                        cancelButton.fire();
                    }
                }
                layoutInfo: LayoutInfo { vpos: javafx.geometry.VPos.CENTER }
            }
    var loginButton: Button = Button {
                text: loginButtonText
                action: function () {
                    nameField.commit();
                    passwordField.commit();
                    urlField.commit();
                    //var loginCheck: CloudSearchTest = CloudSearchTest{ };
                    //loginCheck.queryCloudNode(nameField.text, passwordField.text);
                    //TBD: Assume login okay for now:
                    loggedIn = true;
                    //println("Attempting to login with User: {userName} Pass: {passwordField.password}");
                    //println("logged in: {loggedIn} system: {systemPassword}");
                    if (loggedIn == false) {
                        showMessage(loginFailedMessage);
                    } else {
                        if (occiRequest) {
                            dataManager.setComputeConnection(CloudConnection {
                                connection: urlField.text
                                user: nameField.text
                                credentials: passwordField.text
                            });
                            controller.showComputeList();
                        } else {
                            dataManager.setStorageConnection(CloudConnection {
                                connection: urlField.text
                                user: nameField.text
                                credentials: passwordField.text
                            });
                            controller.showStorageList();
                        }
                    }
                }
                onKeyPressed: function (ke: KeyEvent) {
                    if (ke.code == KeyCode.VK_DOWN) {
                        nameField.requestFocus();
                    } else if (ke.code == KeyCode.VK_UP) {
                        nameField.requestFocus();
                    } else if (ke.code == KeyCode.VK_ENTER) {
                        loginButton.fire();
                    }
                }
                layoutInfo: LayoutInfo { vpos: javafx.geometry.VPos.CENTER }
            }
    var nameLabel = Text {
        font: defaultTextFont
        fill: defaultTextColor
        content: nameLabelText
        textOrigin: TextOrigin.TOP
        layoutInfo: LayoutInfo { vpos: javafx.geometry.VPos.CENTER }
    }

    var nameField: TextBox = TextBox {
        blocksMouse: true
        columns: 20
        promptText: nameFieldPrompt
        selectOnFocus: false
        onKeyPressed: function (e: KeyEvent) {
            //println("nameField key pressed e.code: {e.code}");
            if (e.code == KeyCode.VK_UP) {
                urlField.requestFocus();
            } else if (e.code == KeyCode.VK_RIGHT) {
                //if("{__PROFILE__}" == "mobile") {
                passwordField.requestFocus();
                //}
            } else if (e.code == KeyCode.VK_ENTER) {
                passwordField.requestFocus();
            }
        }
    }

    var passwordLabel = Text {
        font: defaultTextFont
        fill: defaultTextColor
        content: passwordLabelText
        textOrigin: TextOrigin.TOP
        layoutInfo: LayoutInfo {
            vpos: javafx.geometry.VPos.CENTER
        }
    }

    var passwordField: PasswordBox = PasswordBox {
        columns: 20
        onKeyPressed: function (e: KeyEvent) {
            if (e.code == KeyCode.VK_DOWN) {
                urlField.requestFocus();
            } else if (e.code == KeyCode.VK_UP) {
                nameField.requestFocus();
            } else if (e.code == KeyCode.VK_RIGHT) {
                //if("{__PROFILE__}" == "mobile") {
                loginButton.fire();
                //}
            } else if (e.code == KeyCode.VK_ENTER) {
                loginButton.fire();
            }

        }
    }

    var headingLabel: Label = Label {
        text: headingLabelText
        textFill: defaultTextColor
        font: defaultTextFont
    };

    var headingBox = HBox {
        translateX: 55
        translateY: 5
        content: [headingLabel]
        layoutInfo: LayoutInfo {
            width: bind screenWidth - 20
            height: 30
        }
    }

    var urlLabel = Text {
        font: defaultTextFont
        fill: defaultTextColor
        content: urlFieldPrompt
        textOrigin: TextOrigin.TOP
        layoutInfo: LayoutInfo { vpos: javafx.geometry.VPos.CENTER }
    }

    var urlField: TextBox = TextBox {
        blocksMouse: true
        columns: bind screenWidth - 20
        selectOnFocus: false
        promptText: urlFieldPrompt
        // Default URL:
        text: defaultOCCIServer

        onKeyPressed: function (e: KeyEvent) {
            if (e.code == KeyCode.VK_DOWN) {
                nameField.requestFocus();
            } else if (e.code == KeyCode.VK_RIGHT) {
                //if("{__PROFILE__}" == "mobile") {
                nameField.requestFocus();
                //}
            } else if (e.code == KeyCode.VK_ENTER) {
                nameField.requestFocus();
            }
        }
    }

    var urlPanelBox: VBox = VBox {
        translateX: 5
        content: [urlLabel, urlField]
        spacing: 3
    }

    var namePanelBox: VBox = VBox {
        translateX: 5
        content: [nameLabel, nameField]
        spacing: 3
    }

    var passwordPanelBox: VBox = VBox {
        translateX: 5
        spacing: 3
        content: [passwordLabel, passwordField]
        layoutInfo: LayoutInfo {
            height: 60
        }
    }

    var bottomButtonBox: HBox = HBox {
        translateX: 55
        translateY: 10
        content: [loginButton, cancelButton]
        spacing: 4
        layoutInfo: LayoutInfo {
            width: bind screenWidth - 25
            height: 40
        }
    }

    protected override function createView(): Void {
        view = VBox {
            spacing: 4
            content: [
                headingBox,
                urlPanelBox,
                namePanelBox,
                passwordPanelBox,
                bottomButtonBox,
            ]
        };
        passwordField.replaceSelection(devPassword);
    }

}
