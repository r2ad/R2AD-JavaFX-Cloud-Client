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

import javafx.ext.swing.SwingComponent;
import javax.swing.JComponent;
import javax.swing.JScrollPane;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreePath;

/*
 * SwingTree.fx
 * Need to work around this in future - to eliminate Swing dependencies.
 * Created on May 20, 2010, 11:07:14 AM
 */
public class SwingTree extends SwingComponent {

    var tree: CustomJTree;
    var model: DefaultTreeModel;
    public var selectedValue: java.lang.Object;
    public var action: function(obj:Object);

    public var root: DefaultMutableTreeNode on replace{
        if (root != null){
            model.setRoot(root);
            tree.expandPath(new TreePath(root));
            selectedValue = null;
        }
    };

    override function createJComponent(): JComponent {
        tree = new CustomJTree();
        model = tree.getModel() as DefaultTreeModel;
        var  mouseListener = java.awt.event.MouseAdapter {
            override function mousePressed(e: java.awt.event.MouseEvent) {
                var selRow = tree.getRowForLocation(e.getX(), e.getY());
                var selPath = tree.getPathForLocation(e.getX(), e.getY());
                var lastPath = selPath.getPathComponent(selPath.getPathCount() - 1);
                var obj = (lastPath as DefaultMutableTreeNode).getUserObject();
                if(action != null ){
                   action(obj);
                }
                if (selRow != - 1) {
                    if (e.getClickCount() == 1) {
                        selectedValue = obj;
                    } else if(e.getClickCount() == 2) {
                    }
                }
                getJComponent().repaint();
            }
        };
        tree.addMouseListener(mouseListener);
        var scrollPane = new JScrollPane(tree);
        return scrollPane;

    }

}

