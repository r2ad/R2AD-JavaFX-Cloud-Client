/*
 * Sample code: source; KodeJava.com
 * http://www.kodejava.org/examples/266.html
 */

package com.r2ad.cloud.cloudclient.utils;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.io.Writer;
import java.io.Reader;
import java.io.BufferedReader;
import java.io.InputStreamReader;

/**
 *
 * @author JavaFX@r2ad.com
 */
public class StreamToString {
    public static void main(String[] args) throws Exception {
        StreamToString sts = new StreamToString();

        /*
         * Get input stream of our data file. This file can be in
         * the root of you application folder or inside a jar file
         * if the program is packed as a jar.
         */
        InputStream is =
                sts.getClass().getResourceAsStream("/data.txt");

        /*
         * Call the method to convert the stream to string
         */
        System.out.println(sts.convertStreamToString(is));
    }

    public String convertStreamToString(InputStream is)
            throws IOException {
        /*
         * To convert the InputStream to String we use the
         * Reader.read(char[] buffer) method. We iterate until the
         * Reader return -1 which means there's no more data to
         * read. We use the StringWriter class to produce the string.
         */
        if (is != null) {
            Writer writer = new StringWriter();

            char[] buffer = new char[1024];
            try {
                Reader reader = new BufferedReader(
                        new InputStreamReader(is, "UTF-8"));
                int n;
                while ((n = reader.read(buffer)) != -1) {
                    writer.write(buffer, 0, n);
                }
            } finally {
                is.close();
            }
            return writer.toString();
        } else {
            return "";
        }
    }

}
