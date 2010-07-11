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

import javafx.geometry.BoundingBox;
import javafx.geometry.Bounds;
import javafx.scene.CustomNode;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.shape.Rectangle;


/*
 * Test class Node.
 * Created on Jun 19, 2009, 6:56:20 PM
 */

public class CustomListView extends CustomNode {
    public-init var data:Object[];
    public var width = 100.0;
    public var height = 100.0;
    public var itemHeight = 10.0;

    var visibleCount:Integer = bind ((height / itemHeight) as Integer) + 1;
    var visibleStart = 0.0;
    var currentStartItem = 0;
    var yoff = 0.0;

    public var scrollValue = 0.0 on replace { adjust(); }
    
    function adjust() {
        visibleStart = scrollValue;
        var startItem = (visibleStart / itemHeight) as Integer;
        if(visibleStart >= 0) {
            yoff = -(visibleStart mod itemHeight);
        }
        if(startItem != currentStartItem) {
            currentStartItem = startItem;
            regen(startItem, startItem + visibleCount);
        }
    }

    function regen(start:Integer, end:Integer):Void {
        nodes = null;
        for(i in [start..end]) {
            var bds = BoundingBox{ width: width height: itemHeight };
            var nd = createItemNode(data[i],bds);
            nd.translateX = 0;
            nd.translateY = indexof i * 30;
            insert nd into nodes;
        }
    }


    public var createItemNode: function(obj:Object, bounds:Bounds):Node;
    var nodes:Node[];

    override public function create():Node {
        return Group {
            content: Group { content: bind nodes translateY: bind yoff }
            clip: Rectangle { width: bind width height: bind height }
        }
    }

    init {
        regen(0,visibleCount);
    }

}

