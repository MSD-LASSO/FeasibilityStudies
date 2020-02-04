package com.LASSO;

import org.orekit.propagation.analytical.tle.TLE;
import java.lang.NullPointerException;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.UnknownHostException;
import java.util.logging.Logger;

public class CelestrakImporter {

    final static String NORAD_FILE = "http://www.celestrak.com/NORAD/elements/active.txt";

    public static TLE importSatelliteData(int satelliteNumber) throws IOException,NoradIDnotFoundException {
        return importSatelliteData(satelliteNumber,false);
    }

    public static TLE importSatelliteData(int satelliteNumber, boolean debug) throws IOException,NullPointerException {
        try {
            URL url = new URL(NORAD_FILE);
            HttpURLConnection httpConn = (HttpURLConnection) url.openConnection();
            int responseCode = httpConn.getResponseCode();

            if (responseCode == HttpURLConnection.HTTP_OK) {
                if(debug) {
                    System.out.println(httpConn.getContentLength());
                }

                InputStream inputStream = httpConn.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));

                boolean nextSatellite = true;
                while (nextSatellite) {
                    String name = reader.readLine();
                    String row1 = reader.readLine();
                    String row2 = reader.readLine();
                    TLE satSet = new TLE(row1, row2);
                    if (satSet.getSatelliteNumber() == satelliteNumber) {
                        return satSet;
                    }
                }

            } else {
                throw new RuntimeException("ERROR 005: The site was unresponsive. Failed to get the text file. NEEDS TEST CASE");
            }
            throw new RuntimeException("ERROR 006: Not sure how the program got here. Debugging System required. NEEDS TEST CASE");
        }
        catch (NullPointerException problemo){
            String error="ERROR 002: The NORAD ID was not found!!!!!!!! Please check the input file!!!!!!!!!";
//            System.out.println(error);
//            problemo.printStackTrace();
            throw new NoradIDnotFoundException(error);
        }
        catch (UnknownHostException e) {
            String error="ERROR 007: Check internet connection.";
            throw new UnknownHostException(error+", "+e.getMessage());
        }
    }
}
