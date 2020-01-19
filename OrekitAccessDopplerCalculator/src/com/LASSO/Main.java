package com.LASSO;

import org.orekit.data.DataProvidersManager;
import org.orekit.data.DirectoryCrawler;
import org.orekit.propagation.analytical.tle.TLE;

import java.io.File;
import java.io.IOException;

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
        System.out.println("HI Daniel");

//        File orekitData = new File("C:\\Users\\Acer\\IdeaProjects\\OrekitAccessDopplerCalculator\\orekit-data-master");
        File orekitData = new File(".\\orekit-data-master");
        DataProvidersManager manager = DataProvidersManager.getInstance();
        manager.addProvider(new DirectoryCrawler(orekitData));

        try {
            TLE sat = CelestrakImporter.importSatelliteData(26719);
            System.out.println(sat.getLine1());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
