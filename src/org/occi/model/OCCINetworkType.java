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
 * The OCCINetworkType class is a Java implementation of the OCCI "network"
 * HTTP/REST response. The current (v2.0) definition is as follows:
 * <pre>
  <xs:element name="network" type="occi:network"/>
  <xs:complexType name="network">
    <xs:sequence minOccurs="0">
      <xs:element name="link" type="xs:anyURI" maxOccurs="unbounded" />
    </xs:sequence>
    <xs:attribute name="id" type="xs:NMTOKEN" use="required" />
    <xs:attribute name="related" type="occi:RelatedType" use="optional" />
    <xs:attribute name="allocation" type="occi:NetworkAllocationEnum" use="optional" />
    <xs:attribute name="title" type="xs:string" use="optional" />
    <xs:attribute name="summary" type="xs:string" use="optional" />
    <xs:attribute name="address" type="xs:string" use="optional" />
    <xs:attribute name="gateway" type="xs:string" use="optional" />
    <xs:attribute name="vlan" type="occi:NetworkVlanType" use="optional" />
    <xs:attribute name="label" type="xs:string" use="optional" />
  </xs:complexType>
 * </pre>
 * @author David K. Moolenaar, R2AD LLC
 */
public class OCCINetworkType extends OCCILinkType {

    /** Class properties not related to OCCI specification */
    /** Property names fired when a class property is changed (via set) */
    public static final String ALLOCATION = "Allocation";
    public static final String ADDRESS = "Address";
    public static final String GATEWAY = "Gateway";
    public static final String VLAN = "Vlan";
    public static final String LABEL = "Label";

    /** Defined by the OCCI v2.0 Schema */
    public enum Allocation {AUTO, DHCP, MANUAL}
    private Allocation allocation;
    private String address;
    private String gateway;
    private int vlan;
    private String label;

    // ***************************
    // Public Class Constructor Methods
    // ***************************

    public OCCINetworkType() {
        super();
    }

    public OCCINetworkType(String id, int vlan, String label,
        Allocation allocation, URI[] links, String summary,
        String address, String gateway, String title, String related) {
        super(id, links, summary, title, related);
        this.vlan = vlan;
        this.label = label;
        this.allocation = allocation;
        this.address = address;
        this.gateway = gateway;
    }

    // ***************************
    // Class Public Methods
    // ***************************

    public String getAddress() {
        return address;
    }

    public Allocation getAllocation() {
        return allocation;
    }

    public String getGateway() {
        return gateway;
    }

    public String getLabel() {
        return label;
    }

    public int getVLan() {
        return vlan;
    }

    public void setAddress(String address) {
        String temp = this.address;
        this.address = address;
        firePropertyChange(new PropertyChangeEvent(this,
            ADDRESS, temp, address));
    }

    public void setAllocation(Allocation allocation) {
        Allocation temp = this.allocation;
        this.allocation = allocation;
        firePropertyChange(new PropertyChangeEvent(this,
            ALLOCATION, temp, allocation));
    }

    public void setGateway(String gateway) {
        String temp = this.gateway;
        this.gateway = gateway;
        firePropertyChange(new PropertyChangeEvent(this,
            GATEWAY, temp, gateway));
    }

    public void setLabel(String label) {
        String temp = this.label;
        this.label = label;
        firePropertyChange(new PropertyChangeEvent(this,
            LABEL, temp, label));
    }

    public void setVLan(int vlan) {
        int temp = this.vlan;
        this.vlan = vlan;
        firePropertyChange(new PropertyChangeEvent(this,
            VLAN, Integer.valueOf(temp), Integer.valueOf(vlan)));
    }

}

