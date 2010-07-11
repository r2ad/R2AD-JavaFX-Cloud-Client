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
package org.occi.model;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;
import java.net.URI;

/**
 * The OCCIBaseType class is a Java implementation of the most basic OCCI node
 * HTTP/REST response. The v2.0 node has the following common properties:
 * <pre>
   <xs:attribute name="id" type="xs:NMTOKEN" use="required" />
   <xs:attribute name="related" type="occi:RelatedType" use="optional" />
   <xs:attribute name="title" type="xs:string" use="optional" />
   <xs:attribute name="summary" type="xs:string" use="optional" />
 * </pre>
 * This class is extended by actual OCCI node types.
 * @author David K. Moolenaar, R2AD LLC
 */
public class OCCIBaseType {

    /** Class properties not related to OCCI specification */
    public static final String ID = "ID";
    public static final String RELATED = "Related";
    public static final String SUMMARY = "Summary";
    public static final String TITLE = "Title";
    public static final String URI = "URI";
    private PropertyChangeSupport propertySupport;

    /** Defined by OCCI Schema v2.0 */
    private String id; //REQUIRED - PROVIDED BY OCCI SERVICE
    private URI uri; //OPTIONAL - FOR NOW I GUESS
    private String related; //OPTIONAL
    private String summary; //OPTIONAL
    private String title;   //OPTIONAL

    public OCCIBaseType() {
    }

    public OCCIBaseType(String id, String related, String summary,
        String title) {
        this.id = id;
        this.related = related;
        this.summary = summary;
        this.title = title;
    }

    // ***************************
    // Class Public Methods
    // ***************************

    public void addPropertyChangeListener(PropertyChangeListener pcl) {
        if (propertySupport == null) {
            propertySupport = new PropertyChangeSupport(this);
        }
        propertySupport.addPropertyChangeListener(pcl);
    }

    protected void firePropertyChange(PropertyChangeEvent pce) {
        if (propertySupport != null) {
            propertySupport.firePropertyChange(pce);
        }
    }

    public String getID() {
        return id;
    }

    public String getRelated() {
        return related;
    }

    public String getSummary() {
        return summary;
    }

    public String getTitle() {
        return title;
    }

    public URI getURI() {
        return uri;
    }

    public void removePropertyChangeListener(PropertyChangeListener pcl) {
        if (propertySupport != null) {
            propertySupport.removePropertyChangeListener(pcl);
        }
    }

    public void setID(String id) {
        String temp = this.id;
        this.id = id;
        firePropertyChange(new PropertyChangeEvent(this,
            ID, temp, id));
    }

    public void setRelated(String related) {
        String temp = this.related;
        this.related = related;
        firePropertyChange(new PropertyChangeEvent(this,
            RELATED, temp, related));
    }

    public void setSummary(String summary) {
        String temp = this.summary;
        this.summary = summary;
        firePropertyChange(new PropertyChangeEvent(this,
            SUMMARY, temp, summary));
    }

    public void setTitle(String title) {
        String temp = this.title;
        this.title = title;
        firePropertyChange(new PropertyChangeEvent(this,
            TITLE, temp, title));
    }

    public void setURI(URI newURI) {
        URI temp = this.uri;
        this.uri = newURI;
        firePropertyChange(new PropertyChangeEvent(this,
            URI, temp, newURI));
    }

    public String toString() {
        return getTitle();
    }
}
