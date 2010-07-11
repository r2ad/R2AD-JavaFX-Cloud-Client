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
import java.util.ArrayList;

/**
 * The OCCIKindType class is a Java implementation of the OCCI "kind"
 * HTTP/REST response. The current (v2.0) definition is as follows:
 * <pre>
  <xs:element name="kind" type="occi:kind" />
  <xs:complexType name="kind">
    <xs:sequence>
      <xs:element name="compute" type="occi:compute" minOccurs="0" maxOccurs="unbounded" />
      <xs:element name="network" type="occi:network" minOccurs="0" maxOccurs="unbounded" />
      <xs:element name="storage" type="occi:storage" minOccurs="0" maxOccurs="unbounded" />
    </xs:sequence>
    <xs:attribute name="id" type="xs:NMTOKEN" use="required" />
    <xs:attribute name="related" type="occi:RelatedType" use="optional" />
    <xs:attribute name="title" type="xs:string" use="optional" />
    <xs:attribute name="summary" type="xs:string" use="optional" />
  </xs:complexType>
 * </pre>
 * @author David K. Moolenaar, R2AD LLC
 */
public class OCCIKindType extends OCCIBaseType {

    /** Class properties not related to OCCI specification */
    public static final String COMPUTE_ADDED = "Compute Added";
    public static final String COMPUTE_REMOVED = "Compute Removed";
    public static final String NETWORK_ADDED = "Network Added";
    public static final String NETWORK_REMOVED = "Network Removed";
    public static final String STORAGE_ADDED = "Storage Added";
    public static final String STORAGE_REMOVED = "Storage Removed";

    /** OPTIONAL by OCCI Schema */
    private ArrayList<OCCIComputeType> computeArray;
    private ArrayList<OCCINetworkType> networkArray;
    private ArrayList<OCCIStorageType> storageArray;

    public OCCIKindType() {
        super();
        computeArray = new ArrayList<OCCIComputeType>();
        networkArray = new ArrayList<OCCINetworkType>();
        storageArray = new ArrayList<OCCIStorageType>();
    }

    public OCCIKindType(String id, String related, String summary,
        String title, OCCIComputeType[] compute, OCCINetworkType[] network,
        OCCIStorageType[] storage) {
        super(id, related, summary, title);
    }

    // ***************************
    // Class Public Methods
    // ***************************

    public void addType(Object target) {
        if (target != null) {
            if (target instanceof OCCIComputeType) {
                computeArray.add((OCCIComputeType)target);
                firePropertyChange(new PropertyChangeEvent(this,
                    COMPUTE_ADDED, null, target));
            } else if (target instanceof OCCINetworkType) {
                networkArray.add((OCCINetworkType)target);
                firePropertyChange(new PropertyChangeEvent(this,
                    NETWORK_ADDED, null, target));
            } else if (target instanceof OCCIStorageType) {
                storageArray.add((OCCIStorageType)target);
                firePropertyChange(new PropertyChangeEvent(this,
                    STORAGE_ADDED, null, target));
            }
        }
    }

    public void addType(Object[] target) {
        if (target != null) {
            for (int i = 0; i < target.length; i++) {
                addType(target[i]);
            }
        }
    }

    public OCCIComputeType[] getCompute() {
        OCCIComputeType[] result = new OCCIComputeType[computeArray.size()];
        computeArray.toArray(result);
        return result;
    }

    public OCCINetworkType[] getNetwork() {
        OCCINetworkType[] result = new OCCINetworkType[networkArray.size()];
        networkArray.toArray(result);
        return result;
    }

    public OCCIStorageType[] getStorage() {
        OCCIStorageType[] result = new OCCIStorageType[storageArray.size()];
        storageArray.toArray(result);
        return result;
    }

    public Object removeType(Object target) {
        Object result = null;
        if (target != null) {
            if (target instanceof OCCIComputeType) {
                int pos = computeArray.indexOf(target);
                if (pos >= 0) {
                    result = computeArray.remove(pos);
                    firePropertyChange(new PropertyChangeEvent(this,
                        COMPUTE_REMOVED, null, result));
                }
            } else if (target instanceof OCCINetworkType) {
                int pos = networkArray.indexOf(target);
                if (pos >= 0) {
                    result = networkArray.remove(pos);
                    firePropertyChange(new PropertyChangeEvent(this,
                        NETWORK_REMOVED, null, result));
                }
            } else if (target instanceof OCCIStorageType) {
                int pos = storageArray.indexOf(target);
                if (pos >= 0) {
                    result = storageArray.remove(pos);
                    firePropertyChange(new PropertyChangeEvent(this,
                        STORAGE_REMOVED, null, result));
                }
            }
        }
        return result;
    }

}
