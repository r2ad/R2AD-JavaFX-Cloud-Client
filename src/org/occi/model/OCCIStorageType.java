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
import java.net.URI;
import java.util.Date;

/**
 * The OCCIStorageType class is a Java implementation of the OCCI "storage"
 * HTTP/REST response. The current (v2.0) definition is as follows:
 * <pre>
  <xs:element name="storage" type="occi:storage"/>
  <xs:complexType name="storage">
    <xs:sequence minOccurs="0">
      <xs:element name="link" type="xs:anyURI" maxOccurs="unbounded" />
    </xs:sequence>
    <xs:attribute name="id" type="xs:NMTOKEN" use="required" />
    <xs:attribute name="related" type="occi:RelatedType" use="optional" />
    <xs:attribute name="title" type="xs:string" use="optional" />
    <xs:attribute name="summary" type="xs:string" use="optional" />
    <xs:attribute name="size" type="occi:positiveFloat" use="optional" />
    <xs:attribute name="status" type="occi:StorageStatusEnum" use="optional" />
  </xs:complexType>
 * </pre>
 * @author David K. Moolenaar, R2AD LLC
 */
public class OCCIStorageType extends OCCILinkType {

    /** Property names fired when a class property is changed (via set) */
    public static final String STATUS = "Status";
    public static final String SIZE = "Size";
    public static final String ACCESS_TIME = "Access_Time";
    public static final String CREATE_TIME = "Create_Time";
    public static final String MODIFIED_TIME = "Modified_Time";
    /** Defined by the OCCI v2.0 Schema */
    public static enum Status {ONLINE, OFFLINE, DEGRADED}
    public static String[] StatusString = {"Online", "Offline", "Degraded"};
    private float size;
    private Status status;
    /** NOT YET IN THE SPEC ***/
    private Date createTime;
    private Date modifiedTime;
    private Date accessTime;

    // ***************************
    // Public Class Constructor Methods
    // ***************************

    public OCCIStorageType() {
        super();
        this.accessTime = new Date();
        this.createTime = new Date();
        this.modifiedTime = new Date();
    }

    public OCCIStorageType(String id, float size, Status status,
        URI[] links, String summary, String title, String related) {
        super(id, links, summary, title, related);
        this.size = size;
        this.status = status;
    }

    // ***************************
    // Class Public Methods
    // ***************************

    public Date getAccessTime() {
        return accessTime;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public Date getModifiedTime() {
        return modifiedTime;
    }

    public float getSize() {
        return size;
    }

    public Status getStatus() {
        return status;
    }

    public void setAccessTime(Date time) {
        Date temp = this.accessTime;
        this.accessTime = time;
        firePropertyChange(new PropertyChangeEvent(this,
            ACCESS_TIME, temp, time));
    }

    public void setCreateTime(Date time) {
        Date temp = this.createTime;
        this.createTime = time;
        firePropertyChange(new PropertyChangeEvent(this,
            CREATE_TIME, temp, time));
    }

    public void setModifiedTime(Date time) {
        Date temp = this.modifiedTime;
        this.modifiedTime = time;
        firePropertyChange(new PropertyChangeEvent(this,
            MODIFIED_TIME, temp, time));
    }

    public void setSize(float size) {
        float temp = this.size;
        this.size = size;
        firePropertyChange(new PropertyChangeEvent(this,
            SIZE, Float.valueOf(temp), Float.valueOf(size)));
    }

    public void setStatus(Status status) {
        Status temp = this.status;
        this.status = status;
        firePropertyChange(new PropertyChangeEvent(this,
            STATUS, temp, status));
    }
    
    public String getString() {
         return "ID:"+ this.getID() +", Title:"+ this.getTitle()+", Status:"+ this.getStatus() +", URI:"+ this.getURI();
    }
}

