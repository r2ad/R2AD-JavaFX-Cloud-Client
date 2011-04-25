/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.r2ad.cloud.cloudclient.test;

import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;

import org.htmlparser.Node;
import org.htmlparser.Parser;
import org.htmlparser.PrototypicalNodeFactory;
import org.htmlparser.Text;

import org.htmlparser.util.NodeIterator;
import org.htmlparser.util.ParserException;
/**
 *
 * @author JavaFX@r2ad.com
 */
public class ParserTest {
   static
    {
        System.setProperty ("org.htmlparser.tests.ParserTest", "ParserTest");
    }

    /**
     * This testcase needs you to be online.
     */
    public void testElementsFromWeb() throws Exception {
        Parser parser;
        try {
            parser = new Parser("http://www.google.com");
        }
        catch (Exception e ){
            throw new ParserException("You must be offline! This test needs you to be connected to the internet.",e);
        }

        Node[] node = new Node[500];
        int i = 0;
        for (NodeIterator e = parser.elements();e.hasMoreNodes();)
        {
            node[i++] = e.nextNode();
        }
        int cnt = i;
        parser.reset ();
        // Now try getting the elements again
        i = 0;
        for (NodeIterator e = parser.elements();e.hasMoreNodes();)
        {
            node[i++] = e.nextNode();
            System.out.println("Google Node=" + node[i]);
        }
    }

    /**
     * Test the Parser(URLConnection) constructor.
     * This testcase needs you to be online.
     * Based on the form at Canada Post <code>http://www.canadapost.ca/tools/pcl/bin/default-e.asp</code>:
     * Sumbits the POST and verifies the returned HTML contains an expected value.
     */
    public void testPOST() throws Exception
    {   // the form data:
        final String number = "2708";
        final String street = "Kelly";
        final String type = "Avenue";
        final String city = "Ottawa";
        final String province = "ON";
        // the correct answer
        final String postal_code = "K2B 7V4";

        Parser parser;
        URL url;
        HttpURLConnection connection;
        StringBuffer buffer;
        PrintWriter out;
        boolean pass;
        NodeIterator enumeration;
        Node node;
        Text string;

        try
        {
            url = new URL ("http://www.canadapost.ca/tools/pcl/bin/cp_search_response-e.asp");
             connection = (HttpURLConnection)url.openConnection ();
            connection.setRequestMethod ("POST");
            connection.setRequestProperty ("Referer", "http://www.canadapost.ca/tools/pcl/bin/default-e.asp");
            connection.setDoOutput (true);
            connection.setDoInput (true);
            connection.setUseCaches (false);
            buffer = new StringBuffer (1024);
            buffer.append ("app_language=");
            buffer.append ("english");
            buffer.append ("&");
            buffer.append ("app_response_start_row_number=");
            buffer.append ("1");
            buffer.append ("&");
            buffer.append ("app_response_rows_max=");
            buffer.append ("9");
            buffer.append ("&");
            buffer.append ("app_source=");
            buffer.append ("quick");
            buffer.append ("&");
            buffer.append ("query_source=");
            buffer.append ("q");
            buffer.append ("&");
            buffer.append ("name=");
            buffer.append ("&");
            buffer.append ("postal_code=");
            buffer.append ("&");
            buffer.append ("directory_area_name=");
            buffer.append ("&");
            buffer.append ("delivery_mode=");
            buffer.append ("&");
            buffer.append ("Suffix=");
            buffer.append ("&");
            buffer.append ("street_direction=");
            buffer.append ("&");
            buffer.append ("installation_type=");
            buffer.append ("&");
            buffer.append ("delivery_number=");
            buffer.append ("&");
            buffer.append ("installation_name=");
            buffer.append ("&");
            buffer.append ("unit_numbere=");
            buffer.append ("&");
            buffer.append ("app_state=");
            buffer.append ("production");
            buffer.append ("&");
            buffer.append ("street_number=");
            buffer.append (number);
            buffer.append ("&");
            buffer.append ("street_name=");
            buffer.append (street);
            buffer.append ("&");
            buffer.append ("street_type=");
            buffer.append (type);
            buffer.append ("&");
            buffer.append ("test=");
            buffer.append ("&");
            buffer.append ("city=");
            buffer.append (city);
            buffer.append ("&");
            buffer.append ("prov=");
            buffer.append (province);
            buffer.append ("&");
            buffer.append ("Search=");
            out = new PrintWriter (connection.getOutputStream ());
            out.print (buffer);
            out.close ();
            parser = new Parser (connection);
            parser.setNodeFactory (new PrototypicalNodeFactory (true));
        }
        catch (Exception e)
        {
            throw new ParserException ("You must be offline! This test needs you to be connected to the internet.", e);
        }

        pass = false;
        for (enumeration = parser.elements (); enumeration.hasMoreNodes ();)
        {
            node = enumeration.nextNode ();
            if (node instanceof Text)
            {
                string = (Text)node;
                System.out.println("Post Node=" +string);

                if (-1 != string.getText ().indexOf (postal_code))
                    pass = true;
            }
        }
    }

    public static void main(String args[]) throws Exception {
        System.out.println("Testing HTML Parser");
    }

}
