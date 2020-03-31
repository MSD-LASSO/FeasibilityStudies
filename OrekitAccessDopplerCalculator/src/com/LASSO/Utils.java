package com.LASSO;

import org.hipparchus.analysis.function.Abs;
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
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;

import java.io.File;
import java.time.Instant;
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
                stations.add(new Station(identifier, new double[]{FastMath.toRadians(latArray[i]),FastMath.toRadians(lonArray[i]),(altArray[i])}, new double[3], minElevations[i], 0, earth));
            }
        }
        return stations;
    }

    public static AbsoluteDate getCurrentTime(){
        TimeScale utc = TimeScalesFactory.getUTC();

        String initialTimeString= Instant.now().toString();
        String[] splitInitialTimeString=initialTimeString.split("T");

        //splitting those strings and separating each component
        String[] yearMonthDay= splitInitialTimeString[0].split("-");
        String hourMinSecString=splitInitialTimeString[1].replace("Z","");
        String[] hourMinSec=hourMinSecString.split(":");
        int year=Integer.valueOf(yearMonthDay[0]);
        int month=Integer.valueOf(yearMonthDay[1]);
        int day=Integer.valueOf(yearMonthDay[2]);
        int hour=Integer.valueOf(hourMinSec[0]);
        int min=Integer.valueOf(hourMinSec[1]);
        double sec=Double.valueOf(hourMinSec[2]);
        // defining the initialDate in AbsoluteDate form from the string components above.

        return new AbsoluteDate(year,month,day,hour,min,sec,utc);
    }

    public static ArrayList<Station> createStations(boolean inRadians,double[] latArray, double[] lonArray, double[] altArray, double[] minElevations,String[] stationNames) {
        BodyShape earth=Station.getDefaultEarth();
        return createStations(inRadians,latArray,lonArray,altArray,minElevations,earth,stationNames);
    }

}
