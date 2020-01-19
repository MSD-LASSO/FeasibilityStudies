package com.LASSO;

import org.orekit.data.DataProvidersManager;
import org.orekit.data.DirectoryCrawler;
import org.orekit.propagation.analytical.tle.TLE;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

//Java location
//C:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2019.3.1\jbr\bin

//jar file
//C:\Users\Acer\IdeaProjects\OrekitAccessDopplerCalculator\out\artifacts\OrekitAccessDopplerCalculator_jar\OrekitAccessDopplerCalculation.jar

//command prompt calls
//cd C:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2019.3.1\jbr\bin
//java -jar C:\Users\Acer\IdeaProjects\OrekitAccessDopplerCalculator\out\artifacts\OrekitAccessDopplerCalculator_jar\OrekitAccessDopplerCalculator.jar

//TODO Orekit-data needs to be on a relative path
//TODO check server java version. This will not run on java before 11.0. Built as is.

public class Main {

    public static void main(String[] args) {

        ///* CASE 4: Mess Bristol , Brockport,   Webster High School:43.204291, -77.469981
        double[] stationLatitudes= {43.209037, 42.700192,43.204291 };
        double[] stationLongitudes=  {-77.950921,-77.408628,-77.469981};
        double[] stationAltitudes=  {0,  0,  0 };
        double[] minElevations ={0,0,0};
        TimeScale utc = TimeScalesFactory.getUTC();

        //set initial date as October 30th, 2019 at 0:00
        AbsoluteDate endDate = new AbsoluteDate(2020, 1, 21, 0, 0, 00.000, utc);


        ArrayList<Station> stations=Utils.createStations(false,stationLatitudes,stationLongitudes,stationAltitudes,minElevations);

        ADcalculator calc=new ADcalculator(26719,60,stations);

        calc.computeAccessTimes(endDate,true);

        //Consider the below a test.
//        System.out.println("HI Daniel");
//
////        File orekitData = new File("C:\\Users\\Acer\\IdeaProjects\\OrekitAccessDopplerCalculator\\orekit-data-master");
//        File orekitData = new File(".\\orekit-data-master");
//        DataProvidersManager manager = DataProvidersManager.getInstance();
//        manager.addProvider(new DirectoryCrawler(orekitData));

//        try {
//            TLE sat = CelestrakImporter.importSatelliteData(26719);
//            System.out.println(sat.getLine1());
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
    }
}
