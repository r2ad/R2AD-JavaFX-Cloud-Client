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

package com.r2ad.cloud.cloudclient.controller;
/*
 * Modifed extensibly by R2AD, LLC in support of an open cloud client project.
 * visit: http://cloud.r2ad.net for more information.
 */
import javafx.scene.Node;


import com.r2ad.cloud.cloudclient.view.LoginView;
import com.r2ad.cloud.cloudclient.view.ComputeEditorView;
import com.r2ad.cloud.cloudclient.view.CloudView;
import com.r2ad.cloud.cloudclient.view.ConnectionStatusView;
import com.r2ad.cloud.cloudclient.view.StorageEditorView;
import com.r2ad.cloud.cloudclient.controller.Controller;
import com.r2ad.cloud.cloudclient.model.CloudDataManager;

/**
 * Controller class that takes care of screen navigation. Screen navigation is
 * centralized and abstracted here and all the view classes rely on the
 * controller to proceed to the previous or next screen.
 *
 * This class also takes care of doing the necessary initializations when the user
 * navigates from one screen to the other.
 */

 // Global access to the controller instance:
public var controller: Controller;

public class Controller {

    public var contents: Node;
    public var dataManager: CloudDataManager = new CloudDataManager;
    public var cloudView: CloudView;
    public var loginView: LoginView;
    var computeEditorView: ComputeEditorView;
    var storageEditorView: StorageEditorView;
    var connectionStatusView: ConnectionStatusView;

    /**
     * Shows the LoginView
    public function showLoginView2() {
        showLoginView(true, true);
    }
    */

    /**
     * Shows the LoginView
     */
    public function showLoginView(occi:Boolean) {
        if (loginView == null) {
            controller = this;
            loginView = LoginView {
                controller: this
            };
        }
        loginView.occiRequest = occi;
        contents = loginView;
        loginView.defControl.requestFocus();
    }

    /**
     * Shows the CloudListView with Compute resource list populated
     */
    public function showCloudList() {
        if (cloudView == null) {
            cloudView = CloudView {
                controller: this
            };
        }
        contents = cloudView;
        cloudView.defControl.requestFocus();
    }

    /**
     * Shows the CloudListView with Compute resource list populated
     */
    public function showComputeList() {
        if (cloudView == null) {
            cloudView = CloudView {
                controller: this
            };            
        }
        cloudView.loadComputeList();
        contents = cloudView;
        cloudView.defControl.requestFocus();
    }

    /**
     * Shows the CloudListView with Storage resource list populated
     */
    public function showStorageList() {
        if (cloudView == null) {
            cloudView = CloudView {
                controller: this
            };
        }
        cloudView.loadStorageList();
        contents = cloudView;
        cloudView.defControl.requestFocus();
    }

    /**
     * Shows the ComputeEditorView configured to view Compute resource
     */
    public function showComputeModelView(cModel: String) {
        if (computeEditorView == null) {
            computeEditorView = ComputeEditorView {
                controller: this
            };
        }
        computeEditorView.computeType = dataManager.getComputeType(cModel);
        contents = computeEditorView;
        computeEditorView.defControl.requestFocus();
    }

    /**
     * Shows the StorageEditorView configured to view a Storage resource
     */
    public function showStorageModelView(sModel: String) {
        if (storageEditorView == null) {
            storageEditorView = StorageEditorView {
                controller: this
            };
        }
        storageEditorView.storageType = dataManager.getStorageType(sModel);
        contents = storageEditorView;
        storageEditorView.defControl.requestFocus();
    }

    /**
     * Shows the ComputeEditorView configured to view Compute resource
     */
    public function showConnectionStatusView(desc: String) {
        if (connectionStatusView == null) {
            connectionStatusView = ConnectionStatusView {
                controller: this
            };
        }
        connectionStatusView.description = desc;
        var conn = dataManager.getSelectedConnection();
        if (conn != null) {
            connectionStatusView.listContent = conn.getStatus();
        }
        contents = connectionStatusView;
        connectionStatusView.defControl.requestFocus();
    }

}
