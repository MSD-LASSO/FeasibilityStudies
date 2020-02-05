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
        String fileName="./LASSO_INPUT.txt";
        Runner runner=new Runner(fileName);
        runner.execute();


    }
}
