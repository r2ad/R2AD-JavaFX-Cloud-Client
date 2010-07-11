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
package com.r2ad.cloud.cloudclient.model;


import org.occi.model.OCCIComputeType;
import org.occi.model.OCCIStorageType;
import com.r2ad.cloud.cloudclient.parsers.storage.CDMIRootContainerParser;
import com.r2ad.cloud.cloudclient.parsers.storage.CDMIDeleteContainer;
import com.r2ad.cloud.cloudclient.parsers.storage.CDMICreateContainer;
import com.r2ad.cloud.cloudclient.parsers.compute.OCCINodeParser;
import com.r2ad.cloud.cloudclient.parsers.compute.OCCICreateNetwork;
import org.occi.model.OCCINetworkType;

/**
 * @author David K. Moolenaar, R2AD LLC
 */

public class CloudDataManager {

    var computeConnection: CloudConnection;
    var storageConnection: CloudConnection;
    var selectedConnection: CloudConnection;
    var computeArray: OCCIComputeType[] = [];
    var storageArray: OCCIStorageType[] = [];

    /**
     * Returns the currently selected CloudConnection for the Client
     */
    public function getSelectedConnection(): CloudConnection {
        return selectedConnection;
    }

    /**
     * Sets the currently selected CloudConnection for the Client
     */
    public function setSelectedConnection(conn: CloudConnection) {
        this.selectedConnection = conn;
    }

    /**
     * Returns the Compute CloudConnection for the Client
     */
    public function getComputeConnection(): CloudConnection {
        if (computeConnection == null) {
            computeConnection = CloudConnection {
            }
        }
        return computeConnection;
    }

    /**
     * Sets the Compute CloudConnection for the Client
     */
    public function setComputeConnection(conn: CloudConnection) {
        if (computeArray != null) {
            computeArray = [];
        }
        computeConnection = conn;
        queryComputeConnection();
    }

    /**
     * Returns the Storage CloudConnection for the Client
     */
    public function getStorageConnection(): CloudConnection {
        if (storageConnection == null) {
            storageConnection = CloudConnection {
            }
        }
        return storageConnection;
    }

    /**
     * Sets the Storage CloudConnection for the Client
     */
    public function setStorageConnection(conn: CloudConnection) {
        if (storageConnection != null) {
            storageArray = [];
        }
        storageConnection = conn;
        queryStorageConnection();
    }

    function queryComputeConnection() {
        if (computeConnection != null) {
            //println("queryComputeConnection....");
            OCCINodeParser.getComputeNode("");
            // Test for external real rackspace account:
            //RackSpaceParser.getAuthToken();
        }
    }

    function queryStorageConnection() {
        if (storageConnection != null) {
            CDMIRootContainerParser.getRootCDMIContainers();
        }
    }

    /**
     * Clear all Type arrays maintained by this DataHandler.
     */
    public function clearAll() {
        computeArray = [];
        storageArray = [];
    }

    /***************************/
    /** OCCIComputeType Functions */
    /***************************/

    public function createOCCIComputeType(): OCCIComputeType {
        var compute = OCCIComputeType {
        };
        return compute;
    }

    /**
     * Add a OCCIComputeType into the local array.
     */
    public function addComputeType(cModel: OCCIComputeType):Integer {
        // Add calls to a OCCI PUT on /compute
        //println("++addComputeType: {cModel}");
        var netModel: OCCINetworkType = new OCCINetworkType();
        netModel.setTitle(cModel.getTitle());
        netModel.setAddress("10.1.230.1");
        //println("++addComputeType: {netModel}");
        OCCICreateNetwork.createNetwork(netModel);        
        insert cModel into computeArray;
        return storageArray.size();

    }

    /**
     * Inserts a OCCIComputeType into the local array.
     */
    public function insertComputeType(cModel: OCCIComputeType):Integer {
        //println("++insertComputeType: {cModel}");
        insert cModel into computeArray;
        return computeArray.size();
    }

    /**
     * Add multiple OCCIComputeType objects into the local array
     */
    public function addComputeTypes(cModels: OCCIComputeType[]):Void {
        for (cModel in cModels) {
            addComputeType(cModel);
        }
    }

    /**
     * Return the OCCIComputeType by OCCIComputeType.getID()
     */
    public function getComputeType(stringID: String): OCCIComputeType {
        //println("++getComputeType: {stringID}");
        var result: OCCIComputeType;
        for (model in computeArray) {
            //println("++getComputeType Iterate: {model.getString()}");
            if (model.getTitle().equals(stringID) ) {
                result = model;
                //println("++getComputeType Found Match: {result.getString()}");
                break;
            }
        }
        return result;
    }

    /**
     * Return the current array of OCCIComputeType.
    */
    public function getComputeTypes(): OCCIComputeType[] {
        return computeArray;
    }

    /**
     * Return the current array of OCCIComputeType.
     */
    public function getComputeTypeNames(): String[] {
        var result: String[] = [];
        for (model in computeArray) {
            insert model.getTitle() into result;
        }
        return result;
    }

    /**
     * Return the OCCIComputeType by OCCIComputeType.getID()
     */
    public function removeComputeType(stringID: String) {
        for (model in computeArray) {
            if (model.getTitle().equals(stringID)) {
                removeComputeType(model);
                break;
            }
        }
    }

    /**
     * Remove the provided OCCIComputeType from the the local array
     */
    public function removeComputeType(cModel: OCCIComputeType){
        delete cModel from computeArray;
    }

    /***************************/
    /** OCCIStorageType Functions */
    /***************************/

    public function createOCCIStorageType(): OCCIStorageType {
        var storage = OCCIStorageType {
        };
        return storage;
    }

    /**
     * Add a OCCIStorageType into the local array.
     */
    public function addStorageType(sModel: OCCIStorageType):Integer {
        insert sModel into storageArray;
        //
        // Item is in model...so now Network call can be performed.
        // Info from network call can be used to update or delete model.
        //
        CDMICreateContainer.createContainer(sModel);
        return storageArray.size();
    }


    /**
     * Insert an existing OCCIStorageType into the local array.
     */
    public function insertStorageType(sModel: OCCIStorageType):Integer {
        insert sModel into storageArray;
        return storageArray.size();
    }

    /**
     * Add multiple OCCIStorageType objects into the local array
     */
    public function addStorageTypes(sModels: OCCIStorageType[]):Void {
        for (sModel in sModels) {
            addStorageType(sModel);
        }
    }

    /**
     * Return the OCCIStorageType by OCCIStorageType.getID()
     */
    public function getStorageType(stringID: String): OCCIStorageType {
        var result: OCCIStorageType;
        for (model in storageArray) {
            if (model.getTitle().equals(stringID)) {
                result = model;
                break;
            }
        }
        return result;
    }

    /**
     * Return the current array of OCCIStorageType.
    */
    public function getStorageTypes(): OCCIStorageType[] {
        return storageArray;
    }

    /**
     * Return the current array of OCCIStorageType ID names.
     */
    public function getStorageTypeNames(): String[] {
        var result: String[] = [];
        for (model in storageArray) {
            insert model.getTitle() into result;
        }
        return result;
    }

    /**
     * Return the OCCIStorageType by OCCIStorageType.getID()
     */
    public function removeStorageType(stringID: String) {
        if (stringID != null) {
            for (model in storageArray) {
                if (model.getTitle().equals(stringID) ) {
                    removeStorageType(model);
                    break;
                }
            }
        } else {
            println("Warning: Tried to delete null object!")
        }
    }

    /**
     * Remove the provided OCCIStorageType from the the local array
     */
    public function removeStorageType(sModel: OCCIStorageType){
        CDMIDeleteContainer.deleteContainer(sModel.getTitle());
        delete sModel from storageArray;
    }

}
