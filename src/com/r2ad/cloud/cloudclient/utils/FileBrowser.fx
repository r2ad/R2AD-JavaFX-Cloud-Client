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

import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.Container;
import javafx.scene.text.Font;
import javafx.geometry.VPos;
import javafx.util.Sequences;

import java.io.File;
import java.util.Comparator;

import com.javafx.preview.control.TreeCell;
import com.javafx.preview.control.TreeItem;
import com.javafx.preview.control.TreeItemBase;
import com.javafx.preview.control.TreeView;

/**
 * @author Rakesh Menon
 */

def computeImage = Image {
    url: "{__DIR__}images/compute.png"
}
def storageImage = Image {
    url: "{__DIR__}images/storage.png"
}

public class FileBrowser extends Container {

    // Selected File Path
    public-read var selectedFile = bind "{treeView.selectedItem.data}";

    def roots = File.listRoots();

    def treeView = TreeView {

        override var cellFactory = function() : TreeCell {
            def cell:TreeCell = TreeCell {
                //disclosureNode: ImageView {
                //    translateX: bind (cell.treeItem.level - (if (cell.treeView.showRoot) then 1 else 2)) + 6
                //    image: bind if(cell.treeItem.expanded) { computeImage } else { storageImage }
                //    visible: bind ((cell.item != null) and (not cell.treeItem.leaf))
                //}
                node: Label {
                    text: bind formatLabel(cell.item)
                    translateX: bind (cell.treeItem.level + 6)
                    graphic: ImageView {
                        image: bind formatImage(cell.item, cell.treeItem)
                    }
                    visible: bind (cell.item != null)
                }
            }
        }

        showRoot: false

        root: TreeItem {
            data: "ROOT"
            children: for(root in roots) {
                FileTreeItem { data: root }
            }
        }
    }

    def selectedFileLabel = Label {
        font: Font { size: 12 }
        text: bind "{treeView.selectedItem.data}"
        vpos: VPos.CENTER
    }

    init {
        children = [ selectedFileLabel, treeView ];
    }

    override function doLayout() : Void {
        def h = getNodePrefHeight(selectedFileLabel);
        layoutNode(treeView, 0, 0, width, height - h - 10);
        layoutNode(selectedFileLabel, 5, height - h - 5, width - 10, h + 5);
    }

    function formatLabel(data : Object) : String {

        if(data == null) { return ""; }

        if(data instanceof File) {
            var fileName = (data as File).getName();
            if((fileName != null) and (fileName.trim().length() > 0)) {
                return fileName;
            }
        }
        return "{data}";
    }

    function formatImage(data : Object, treeItem : TreeItemBase) : Image {

        if(data == null) { return null; }
        if(not (data instanceof File)) { return null; }
        /*
        if((data as File).isDirectory()) {
            if(treeItem.expanded) {
                return treeOpenImage;
            } else {
                return treeClosedImage;
            }
        }
        */
        return computeImage;
    }
}

def fileComparator = FileComparator { };

class FileTreeItem extends TreeItem {

    override var createChildren = function(item:TreeItemBase) : TreeItemBase[] {

        var treeItemBase : TreeItemBase[] = [];

        var file = (item.data as File);

        if(file.isDirectory()) {
            var files = file.listFiles();
            if(files != null) {
                for(f in files) {
                    insert FileTreeItem { data: f } into treeItemBase;
                }
            }
        }

        Sequences.sort(treeItemBase, fileComparator) as TreeItemBase[];
    }

    override var isLeaf = function(item:TreeItemBase) : Boolean {
        return not (item.data as File).isDirectory();
    }
}

class FileComparator extends Comparator {

    override function compare(obj1 : Object, obj2 : Object) : Integer {

        if(not (obj1 instanceof TreeItemBase)) return -1;
        if(not (obj2 instanceof TreeItemBase)) return -1;

        def file1 = (obj1 as TreeItemBase).data as File;
        def file2 = (obj2 as TreeItemBase).data as File;

        if(file1.isDirectory() and file2.isDirectory()) {
            return file1.getName().compareToIgnoreCase(file2.getName());
        } else if(file1.isFile() and file2.isFile()) {
            return file1.getName().compareToIgnoreCase(file2.getName());
        } else if(file1.isFile()) return 1;

        return -1;
    }
}
