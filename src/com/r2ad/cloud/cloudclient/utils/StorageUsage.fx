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

/**
 * Sample pie chart that can be used in CDMI/OCCI to render space usage
 * @author JavaFX@r2ad.com
 * Created on Jun 6, 2010, 10:50:17 AM
 */

/*
 * Main.fx
 *
 * Created on Mar 10, 2009, 11:05:28 AM
 */

import javafx.scene.Scene;
import javafx.scene.text.Font;
import javafx.scene.text.Text;
import javafx.stage.Stage;
import javafx.scene.chart.PieChart;
import javafx.stage.Alert;

/**
 * @author sst
 */


Stage {
    title: "Cloud Storage Usage"
    width: 450
    height: 400
    scene: Scene {
        content: [Text {
                font: Font {
                    size: 16
                    name: "Arial"
                }
                x: 10,
                y: 30
                content: "Storage Allocation:"
            },
            PieChart {
                data: [
                    PieChart.Data { label: "DataStore" value: 34 },
                    PieChart.Data { label: "VMStore" value: 23 },
                    PieChart.Data { label: "Unallocated"
                                    value: 43
                                    action: function(){
                                            Alert.inform("Actions can be taken on slices");
                                    } },
                ]
                pieLabelVisible: true

            }]
    }
}

