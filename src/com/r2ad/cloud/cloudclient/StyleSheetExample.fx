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
 /*
 * StyleSheetExample.fx
 *
 * Created on 28 May, 2010, 2:04:48 PM
 */

package com.r2ad.cloud.cloudclient;

import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.control.ListView;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.Group;
import com.javafx.preview.control.TreeItemBase;
import com.javafx.preview.control.TreeView;
import javafx.scene.Cursor;

/**
 * Thanks to Rakesh for his great examples - please visit:
 * http://rakeshmenonp.wordpress.com/
 * @author Rakesh Menon
 */

def listViewItems = [
    "People's Republic of China",
    "India",
    "United States",
    "Indonesia",
    "Brazil",
    "Pakistan",
    "Bangladesh",
    "Nigeria",
    "Russia",
    "Japan",
    "Mexico",
    "Philippines",
    "Vietnam",
    "Germany",
    "Ethiopia",
    "Egypt",
    "Iran",
    "Turkey",
    "Dem. Rep. of Congo",
    "France"
];
def listView = ListView {
    layoutX: 10
    layoutY: 10
    items: listViewItems
    layoutInfo: LayoutInfo {
        width: 280
        height: 200
    }
    cursor: Cursor.HAND
}

//COUNTRY POPULATION
def countryPopulation = [
    "China 1,306,313,800",
    "India 1,080,264,400",
    "USA 295,734,100",
    "Indonesia 241,973,900",
    "Brazil 186,112,800",
    "Pakistan 162,419,900",
    "Bangladesh 144,319,600",
    "Russia 143,420,300",
    "Nigeria 128,772,000",
    "Japan 127,417,200"
];
//LARGEST USA CITIES
def largestUSACities = [
    "New York City, NY 8.09 million",
    "Los Angeles, CA 3.8 million",
    "Chicago, IL 3.1 million",
    "Houston, TX 2.78 million",
    "Philadelphia, PA 1.62 million",
    "Phoenix, AZ 1.54 million",
    "San Antonio, TX 1.5 million",
    "San Diego, CA 1.4 million",
    "Dallas, TX 1.32 million",
    "Detroit, MI 1 million"
];
//LARGEST CITIES ON THE PLANET
def largestCitiesOnThePlanet = [
    "Shanghai, China 13.3 million",
    "Mumbai (Bombay), India 12.6 million",
    "Buenos Aires, Argentina 11.92 million",
    "Moscow, Russia 11.3 million",
    "Karachi, Pakistan 10.9 million",
    "Delhi, India 10.4 million",
    "Manila, Philippines 10.3 million",
    "Sao Paulo, Brazil 10.26 million",
    "Seoul, South Korea 10.2 million",
    "Istanbul, Turkey 9.6 million",
    "Jakarta, Indonesia 9.0 million",
    "Mexico City, Mexico 8.7 million",
    "Lagos, Nigeria 8.68 million",
    "Lima, Peru 8.38 million",
    "Tokyo, Japan 8.3 million",
    "New York City, USA 8.09 million",
    "Cairo, Egypt 7.6 million",
    "London, UK 7.59 million",
    "Teheran, Iran 7.3 million",
    "Beijing, China 7.2 million"
];
//LARGEST METRO AREAS IN THE WORLD
def largestMetroAreasInTheWorld = [
    "Toyko, Japan 31.2 million",
    "New York City - Philadelphia area, USA 30.1 million",
    "Mexico City, Mexico 21.5 million",
    "Seoul, South Korea 20.15 million",
    "Sao Paulo, Brazil 19.9 million",
    "Jakarta, Indonesia 18.2 million",
    "Osaka-Kobe-Kyoto, Japan 17.6 million",
    "New Delhi, India 17.36 million",
    "Mumbai, India (Bombay) 17.34 million",
    "Los Angeles, USA 16.7 million",
    "Cairo, Egypt 15.86 million",
    "Calcutta, India 14.3 million",
    "Manila, Philippines 14.1 million",
    "Shanghai, China 13.9 million",
    "Buenos Aires, Argentina 13.2 million",
    "Moscow, Russian Fed. 12.2 million"
];

def treeRoot = TreeItemBase {
    children: [
        TreeItemBase {
            data: "COUNTRY POPULATION"
            children: for(data in countryPopulation) {
                TreeItemBase { data: data }
            }
        },
        TreeItemBase {
            data: "LARGEST USA CITIES"
            children: for(data in largestUSACities) {
                TreeItemBase { data: data }
            }
        },
        TreeItemBase {
            data: "LARGEST CITIES ON THE PLANET"
            children: for(data in largestCitiesOnThePlanet) {
                TreeItemBase { data: data }
            }
        },
        TreeItemBase {
            data: "LARGEST METRO AREAS IN THE WORLD"
            children: for(data in largestMetroAreasInTheWorld) {
                TreeItemBase { data: data }
            }
        }
    ]
};
def treeView = TreeView {
    layoutX: 10
    layoutY: 210
    root: treeRoot
    showRoot: false
    layoutInfo: LayoutInfo {
        width: 280
        height: 200
    }
    cursor: Cursor.HAND
}

Stage {
    title: "Power of CSS"
    width: 300
    height: 450
    resizable: false
    scene: Scene {
        content: Group {
            content: [
                ImageView {
                    image: Image {
                        url: "{__DIR__}background.jpg"
                    }
                },
                listView, treeView
            ]
        }
        stylesheets: [ "{__DIR__}javafx.css" ]
    }
}

