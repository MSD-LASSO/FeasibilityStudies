package com.LASSO;

import org.orekit.propagation.analytical.tle.TLE;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

public class CelestrakImporter {

    final static String NORAD_FILE = "http://www.celestrak.com/NORAD/elements/active.txt";

    public static TLE importSatelliteData(int satelliteNumber) throws IOException {
        URL url = new URL(NORAD_FILE);
        HttpURLConnection httpConn = (HttpURLConnection) url.openConnection();
        int responseCode = httpConn.getResponseCode();

        if(responseCode==HttpURLConnection.HTTP_OK) {
            System.out.println(httpConn.getContentLength());

            InputStream inputStream = httpConn.getInputStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));

            boolean nextSatellite = true;
            while(nextSatellite) {
                String name = reader.readLine();
                String row1 = reader.readLine();
                String row2 = reader.readLine();
                TLE satSet = new TLE(row1, row2);
                if(satSet.getSatelliteNumber() == satelliteNumber) {
                    return satSet;
                }
                //todo handle the fact this breaks if no satellite found
            }

        } else {
            throw new RuntimeException("Bad shit happened");
        }

        throw new RuntimeException("NOT FOUND!");
    }
}
