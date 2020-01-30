package com.LASSO;

import org.hipparchus.util.FastMath;
import org.orekit.bodies.BodyShape;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.data.DataProvidersManager;
import org.orekit.data.DirectoryCrawler;
import org.orekit.frames.TopocentricFrame;
import org.orekit.propagation.events.BooleanDetector;
import org.orekit.propagation.events.ElevationDetector;
import org.orekit.propagation.events.EventDetector;
import org.orekit.propagation.events.handlers.RecordAndContinue;

import java.io.File;
import java.util.ArrayList;

public class Utils {

    public static void addOrekitData() {
        //File orekitData = new File(".\\orekit-data-master"); //for windows
        File orekitData = new File("./orekit-data-master"); //for mac

        DataProvidersManager manager = DataProvidersManager.getInstance();
        manager.addProvider(new DirectoryCrawler(orekitData));
    }

    public static ArrayList<Station> createStations(boolean inRadians,double[] latArray, double[] lonArray, double[] altArray, double[] minElevations, BodyShape earth,String[] stationNames) {

        ArrayList<Station> stations = new ArrayList<>();

        for (int i=0;i<latArray.length;i++) {
            String identifier="Station "+Integer.toString(i)+":"+stationNames[i];
            if(inRadians) {
                stations.add(new Station(identifier, new double[]{latArray[i], lonArray[i], altArray[i]}, new double[3], minElevations[i], 0, earth));
            } else {
                stations.add(new Station(identifier, new double[]{FastMath.toRadians(latArray[i]),FastMath.toRadians(lonArray[i]),FastMath.toRadians(altArray[i])}, new double[3], minElevations[i], 0, earth));
            }
        }
        return stations;
    }

    public static ArrayList<Station> createStations(boolean inRadians,double[] latArray, double[] lonArray, double[] altArray, double[] minElevations,String[] stationNames) {
        BodyShape earth=Station.getDefaultEarth();
        return createStations(inRadians,latArray,lonArray,altArray,minElevations,earth,stationNames);
    }

}
