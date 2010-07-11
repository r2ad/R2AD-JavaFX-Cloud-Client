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
package com.r2ad.cloud.cloudclient.view.swing;

import org.occi.model.OCCIComputeType;
import org.occi.model.OCCILinkType;
import org.occi.model.OCCIStorageType;
import javax.swing.ImageIcon;
import javax.swing.tree.DefaultMutableTreeNode;

/**
 * Representation for a tree node for VMs and storage.
 * @author David K. Moolenaar, R2AD LLC
 */
public class CloudTreeNode extends DefaultMutableTreeNode
    implements CloudIconNode {

    public static ImageIcon[] icons;
    static {
        icons = new ImageIcon[5];
        try {
            icons[0] = new ImageIcon(
                CloudTreeNode.class.getResource("images/vmb.png"));
            icons[1] = new ImageIcon(
                CloudTreeNode.class.getResource("images/vmy.png"));
            icons[2] = new ImageIcon(
                CloudTreeNode.class.getResource("images/vmr.png"));
            icons[3] = new ImageIcon(
                CloudTreeNode.class.getResource("images/storage.png"));
            icons[4] = new ImageIcon(
                CloudTreeNode.class.getResource("images/url.png"));
        } catch (Exception e) {
            //e.printStackTrace();
        }
    }

    public CloudTreeNode(OCCILinkType occiType) {
        setUserObject(occiType);
    }

    public CloudTreeNode(OCCILinkType[] occiTypes) {
        setUserObject("OCCI Root");
        for (int x = 0; occiTypes != null && x < occiTypes.length; x++) {
            add(new CloudTreeNode(occiTypes[x]));
        }
    }

    @Override public ImageIcon getIcon() {
        if (userObject instanceof OCCIStorageType) {
            return icons[3];
        } else if (userObject instanceof OCCIComputeType) {
            if (((OCCIComputeType)userObject).getStatus() == OCCIComputeType.Status.ACTIVE) {
                return icons[0];
            } else if (((OCCIComputeType)userObject).getStatus() == OCCIComputeType.Status.INACTIVE) {
                return icons[1];
            } else {
                return icons[2];
            }
        }
        return icons[4];
    }
}
