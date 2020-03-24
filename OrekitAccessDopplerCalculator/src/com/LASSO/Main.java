package com.LASSO;

import org.orekit.data.DataProvidersManager;
import org.orekit.data.DirectoryCrawler;
import org.orekit.propagation.analytical.tle.TLE;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import java.time.Instant;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

//Java location
//C:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2019.3.1\jbr\bin

//jar file
//C:\Users\Acer\IdeaProjects\OrekitAccessDopplerCalculator\out\artifacts\OrekitAccessDopplerCalculator_jar\OrekitAccessDopplerCalculation.jar

//command prompt calls
//cd C:\Program Files\JetBrains\IntelliJ IDEA Community Edition 2019.3.1\jbr\bin
//java -jar C:\Users\Acer\IdeaProjects\OrekitAccessDopplerCalculator\out\artifacts\OrekitAccessDopplerCalculator_jar\OrekitAccessDopplerCalculator.jar

//TODO check server java version. This will not run on java before 11.0. Built as is.

public class Main {

    public static void main(String[] args) throws FileNotFoundException {
        /*
        INPUTS CAN BE IN ANY ORDER!!!!!!!

        initialDate (current time as DEFAULT)
        endDate  (1 day ahead of initial date)
        noradID= error thrown (legit error)
        TLEestimatedErrorTimes (0.3 [s])
        recordingRate     (60 [s] )
        and then add default vals if none chosen. ^^^ in ( ) above.
         */
//        System.out.println(args[0]);
//        System.out.println(args[1]);

        /* text version
        String fileName="./LASSO_INPUT.txt";
        Runner runner=new Runner(fileName);
        runner.execute();
         */
        Utils.addOrekitData();
        InputReader terminalReader;
        try {
            terminalReader = new InputReader();
            terminalReader.readFromTerminal(args);
        } catch(NoradIDnotFoundException ex) {
            terminalReader = new InputReader("./Backup_Input.txt");
        }
        int noradID=terminalReader.getNoradID();
        AbsoluteDate initialDate=terminalReader.getinitialTime();
        AbsoluteDate endDate=terminalReader.getEndTime();
        double errorTimeForTLE=terminalReader.getErrorTimeForTLE();
        double recordingRate=terminalReader.getRecordingRate();
        double channelFrequency=terminalReader.getChannelFrequency();
        Runner terminalRunner=new Runner(initialDate,endDate,noradID,errorTimeForTLE,recordingRate,channelFrequency);
        terminalRunner.execute();
    }
}
