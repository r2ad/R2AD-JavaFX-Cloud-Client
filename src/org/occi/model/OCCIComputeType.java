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

/**
 * The OCCIComputeType class is a Java implementation of the OCCI "compute"
 * HTTP/REST response. The current (v2.0) definition is as follows:
 * <pre>
   <xs:element name="compute" type="occi:compute" />
   <xs:complexType name="compute">
     <xs:sequence minOccurs="0" maxOccurs="unbounded" >
       <xs:element name="link" type="xs:anyURI" />
     </xs:sequence>
     <xs:attribute name="id" type="xs:NMTOKEN" use="required" />
     <xs:attribute name="related" type="occi:RelatedType" use="optional" />
     <xs:attribute name="title" type="xs:string" use="optional" />
     <xs:attribute name="summary" type="xs:string" use="optional" />
     <xs:attribute name="cores" type="occi:positiveFloat" use="optional" />
     <xs:attribute name="architecture" type="occi:ComputeArchitectureEnum" use="optional" />
     <xs:attribute name="hostname" type="xs:string" use="required" />
     <xs:attribute name="speed" type="occi:positiveFloat" use="required" />
     <xs:attribute name="memory" type="occi:positiveFloat" use="required" />
     <xs:attribute name="status" type="occi:ComputeStatusEnum" use="required" />
   </xs:complexType>
 * </pre>
 * @author David K. Moolenaar, R2AD LLC
 */
public class OCCIComputeType extends OCCILinkType {

    /** Class properties not related to OCCI specification */
    /** Property names fired when a class property is changed (via set) */
    public static final String HOSTNAME = "Hostname";
    public static final String MEMORY = "Memory";
    public static final String SPEED = "Speed";
    public static final String STATUS = "Status";
    public static final String ARCHITECTURE = "Architecture";
    public static final String CORES = "Cores";
    public static final String CATEGORY = "Category";

    /** Defined by the OCCI v2.0 Schema */
    public static enum Status {ACTIVE, INACTIVE, SUSPENDED}
    public static String[] StatusString = {"Active", "Inactive", "Suspended"};
    public static enum Architecture {x86, x86_32, x86_64}
    public static String[] ArchString = {"X86", "x86_32", "x86_64"};

    private String hostname;    //REQUIRED
    private String category;    //REQUIRED
    private float memory;       //REQUIRED
    private float speed;        //REQUIRED
    private Status status;      //REQUIRED
    private Architecture architecture;
    private float cores;

    // ***************************
    // Public Class Constructor Methods
    // ***************************

    public OCCIComputeType() {
        super();
    }

    public OCCIComputeType(String id) {
        super(id, null, "", "", "");
    }

    public OCCIComputeType(String id, String hostname, float memory,
        float speed, Status status, URI[] links, Architecture architecture,
        float cores, String summary, String title, String related) {
        super(id, links, summary, title, related);
        this.hostname = hostname;
        this.memory = memory;
        this.speed = speed;
        this.status = status;
        this.architecture = architecture;
        this.cores = cores;
    }

    // ***************************
    // Class Public Methods
    // ***************************

    public Architecture getArchitecture() {
        return architecture;
    }

    public int getArchitectureAsInt() {
        int result = 0;
        switch (architecture) {
            case x86: result = 0;
            case x86_32: result = 1;
            case x86_64: result = 2;
        }
        return result;
    }

    public float getCores() {
        return cores;
    }

    public String getCategory() {
        return category;
    }

    public String getHostname() {
        return hostname;
    }

    public float getMemory() {
        return memory;
    }

    public float getSpeed() {
        return speed;
    }

    public Status getStatus() {
        return status;
    }

    public int getStatusAsInt() {
        int result = 0;

        try {
            result=1;
            switch (status) {
                case INACTIVE: result = 1;
                               break;
                case SUSPENDED: result = 2;
                                break;
            }
        } catch (Exception e) {
            result=0;
        }



        return result;
    }

    public void setArchitecture(int arch) {
        if (arch == 0) {
            setArchitecture(Architecture.x86);
        } else if (arch == 1) {
            setArchitecture(Architecture.x86_32);
        } else if (arch == 2) {
            setArchitecture(Architecture.x86_64);
        }
    }

    public void setArchitecture(Architecture architecture) {
        Architecture temp = this.architecture;
        this.architecture = architecture;
        firePropertyChange(new PropertyChangeEvent(this,
            ARCHITECTURE, temp, architecture));
    }

    public void setCores(float cores) {
        float temp = this.cores;
        this.cores = cores;
        firePropertyChange(new PropertyChangeEvent(this,
            CORES, Float.valueOf(temp), Float.valueOf(cores)));
    }


    public void setCategory(String cat) {
        this.category = cat;
        firePropertyChange(new PropertyChangeEvent(this,
            CATEGORY, this.category, cat));
    }

    public void setHostname(String hostname) {
        this.hostname = hostname;
        firePropertyChange(new PropertyChangeEvent(this,
            HOSTNAME, hostname, this.hostname));
    }

    public void setMemory(float memory) {
        this.memory = memory;
        firePropertyChange(new PropertyChangeEvent(this,
            MEMORY, Float.valueOf(this.memory), Float.valueOf(memory)));
    }

    public void setSpeed(float speed) {
        this.speed = speed;
        firePropertyChange(new PropertyChangeEvent(this,
            SPEED, Float.valueOf(this.speed), Float.valueOf(speed)));
    }

    public void setStatus(int status) {
        if (status == 0) {
            setStatus(Status.ACTIVE);
        } else if (status == 1) {
            setStatus(Status.INACTIVE);
        } else if (status == 2) {
            setStatus(Status.SUSPENDED);
        }
    }

    public void setStatus(Status status) {
        this.status = status;
        firePropertyChange(new PropertyChangeEvent(this,
            STATUS, this.status, status));
    }

    public String getString() {
        return "[host:"+hostname +", ID:"+ this.getID() +", Title:"+ this.getTitle() +", summary:"+ this.getSummary() +", Mem:"+ memory +", Speed:"+ speed +", Status:"+ status +", Arch:"+ architecture +", Core:"+ cores + "]";
    }


}

