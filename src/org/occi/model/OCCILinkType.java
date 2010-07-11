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
import java.util.ArrayList;

/**
 * The OCCILinkType class is a Java implementation of a OCCI node that
 * contains a sequence of URI links to other resources defined as:
 * HTTP/REST response. The v2.0 node has the following common properties:
 * <pre>
    <xs:sequence minOccurs="0" maxOccurs="unbounded" >
      <xs:element name="link" type="xs:anyURI" />
    </xs:sequence>
 * </pre>
 * This class is extended by actual OCCI node types that have a link property.
 * The v2.0 OCCI schema defines "Compute", "Network", and "Storage" to
 * optionally maintain 0+ URI links.
 * @author David K. Moolenaar, R2AD LLC
 */
public class OCCILinkType extends OCCIBaseType {

    /** Class properties not related to OCCI specification */
    public static final String LINK_ADDED = "Link Added";
    public static final String LINK_REMOVED = "Link Removed";

    /** OPTIONAL by OCCI Schema */
    private ArrayList<URI> linkArray;

    public OCCILinkType() {
        super();
    }

    public OCCILinkType(String id, URI[] links, String related, String summary,
        String title) {
        super(id, related, summary, title);
        addLink(links);
    }

    // ***************************
    // Class Public Methods
    // ***************************

    public void addLink(URI link) {
        if (link != null) {
            getLinkList().add(link);
            firePropertyChange(new PropertyChangeEvent(this,
                LINK_ADDED, null, link));
        }
    }

    public void addLink(URI[] link) {
        if (link != null) {
            for (int i = 0; i < link.length; i++) {
                addLink(link[i]);
            }
        }
    }

    public URI[] getLinks() {
        URI[] result = new URI[getLinkList().size()];
        linkArray.toArray(result);
        return result;
    }

    public URI removeLink(URI link) {
        URI result = null;
        int pos = getLinkList().indexOf(link);
        if (pos >= 0) {
            result = linkArray.remove(pos);
            firePropertyChange(new PropertyChangeEvent(this,
                LINK_REMOVED, null, result));
        }
        return result;
    }

    // PRIVATE METHOD TO ENSURE A VALID ARRAYLIST

    private ArrayList<URI> getLinkList() {
        if (linkArray == null) {
            linkArray = new ArrayList<URI>();
        }
        return linkArray;
    }

}
