/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.r2ad.cloud.cloudclient.parsers.compute;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.InputStream;
import org.occi.model.OCCIComputeType;
/**
 *
 * @author JavaFX@r2ad.com
 */
public class OCCIComputeHTMLParser_1_0 {
    public static String myName = "OCCIComputeHTMLParser_1_0";
    private OCCIComputeType tempComputer;
    //Assigned from invoking method (since the HTTP request had to know what the
    //hostname and URI are:
    // David - you can pass these into a constructor or to the parse method
    private String computerHostname = "TBDhostname";
    private String RID = "0110101010101";  // Unique ID, part of URI to resource

    public OCCIComputeHTMLParser_1_0 (String RID, String hostname) {
        this.RID = RID;
        this.computerHostname = hostname;
    }

    public OCCIComputeType parseInput (InputStream  is) {
        BufferedReader in = new BufferedReader( new InputStreamReader(is) );
        String line = null;
        try {
          while((line = in.readLine()) != null) {
              System.out.println(line);
              if (line.startsWith("Category:")) {
                  int catStart;
                  int catEnd;
                  catStart=line.indexOf("Category:");
                  catEnd=line.indexOf(";");
                  String category;
                  category=line.substring(10, catEnd);
                  System.out.println("["+myName+"] Found Category: " + category);
                  if (category.equals("compute")) {
                     processComputeCategory(line);
                  }
                  //
                  // TBD: Add other categories, network, etc.
                  //
              } else {
                  if ( line.startsWith("X-OCCI-Attribute:")) {
                      processComputeAttribute(line);
                  }
              }
          }
        } catch (Exception e) {
           System.out.println("["+myName+"] Exception: " +e );
        }

        /*
         * This is invoked after all the input has been parsed.
         * It collects the data and creates a real compute resource
         * based on the provided data.
         */
        System.out.println("["+myName+"] processEndOfLine, Temp computer: " + tempComputer);

        // Need to notify controller, etc
        //connection.updateStatus("{myName}: Storing {newcomputer.getHostname()} ID:{newcomputer.getID()}");
        //controller.dataManager.insertComputeType(newcomputer);
        return tempComputer;

    }

    public void processComputeCategory(String input) {
        String title="unknown";
        int idStart;
        int idEnd;
        idStart=input.indexOf("title=\"");
        if ( idStart > 0) {
            idEnd=input.lastIndexOf("\"");
            title=input.substring(idStart+7, idEnd);
            System.out.println("["+myName+"]  Found Title: " + title);
        }

        OCCIComputeType existingComputer;
        // Check for duplicates?  What's the key?
        //existingComputer = controller.dataManager.getComputeType(RID);
        //if (existingComputer != null ) {
        //   newID={newID}"-Duplicate";
        //}

        // Should probably use the Resource ID instead....
        tempComputer = new OCCIComputeType (RID);
        System.out.println("["+myName+"] :#######  Creating new Temp Computer #######" + tempComputer);

        tempComputer.setHostname(computerHostname);
        tempComputer.setCategory("compute");
        tempComputer.setTitle(title); // default - may change as attributes are found
        tempComputer.setCores(1); // default - may change as attributes are found
        tempComputer.setArchitecture(OCCIComputeType.Architecture.x86); // assume
        tempComputer.setMemory(1024); // default - may change as attributes are found
        System.out.println("["+myName+"]  Instantiating Temp computer: {tempComputer}");
    }

    public void processComputeAttribute(String input) {

        int catStart;
        int catEnd;
        catStart=input.indexOf("X-OCCI-Attribute: ");
        catEnd=input.indexOf("=");
        String OCCIattribute = "";
        String attributeValue = "";

        OCCIattribute=input.substring(catStart+18, catEnd);

        catStart=input.indexOf("=");
        attributeValue=input.substring(catStart+1);


        // If value starts and ends with qoutes, remove them:
        catStart=attributeValue.indexOf("\"");
        catEnd=attributeValue.lastIndexOf("\"");
        if (catStart >= 0 ) {
            attributeValue=attributeValue.substring(catStart+1, catEnd);
        }
        //println("{myName}: Value [{attributeValue}]");

        System.out.println("["+myName+"] Found Attribute: [" + OCCIattribute+"]=["+attributeValue+"]");
        if (OCCIattribute.equals("occi.compute.architecture")) {
           if ( attributeValue.equals("x86_64")) tempComputer.setArchitecture(OCCIComputeType.Architecture.x86_64);
           if ( attributeValue.equals("x86_32")) tempComputer.setArchitecture(OCCIComputeType.Architecture.x86_32);
           if ( attributeValue.equals("x86")) tempComputer.setArchitecture(OCCIComputeType.Architecture.x86);
           System.out.println("["+myName+"] Found architecture: " + tempComputer.getArchitecture());

        }
        if (OCCIattribute.equals("occi.compute.state")) {
            if ( attributeValue.equals("active")) tempComputer.setStatus(OCCIComputeType.Status.ACTIVE);
            if ( attributeValue.equals("inactive")) tempComputer.setStatus(OCCIComputeType.Status.INACTIVE);
            if ( attributeValue.equals("suspended")) tempComputer.setStatus(OCCIComputeType.Status.SUSPENDED);
            System.out.println("["+myName+"] Found state: " + tempComputer.getStatus());
        }
        if (OCCIattribute.equals("occi.compute.memory")) {
            try {
               tempComputer.setMemory(Float.parseFloat(attributeValue) * 1024.0f); // default - not always accurate
            } catch (NumberFormatException ne) {
               tempComputer.setMemory(0.07f); // error value "007" flag
               System.out.println("["+myName+"] MEMORY Attribute non numeric...using default of 0.07");
            }
            System.out.println("["+myName+"] Found memory: " + tempComputer.getMemory());
        }
        if (OCCIattribute.equals("occi.compute.speed")) {
            try {
               tempComputer.setSpeed(Float.parseFloat(attributeValue));
            } catch (NumberFormatException ne) {
               tempComputer.setSpeed(0.0f);
               System.out.println("["+myName+"] SPEED Attribute non float...using default of 0.0");
            }
            System.out.println("["+myName+"] Found Speed: " + tempComputer.getSpeed());
        }


    }

}
