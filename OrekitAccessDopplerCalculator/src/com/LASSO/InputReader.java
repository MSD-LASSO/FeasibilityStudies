package com.LASSO;

import org.orekit.propagation.analytical.tle.SGP4;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScalesFactory;

import java.io.PrintWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.lang.reflect.GenericDeclaration;
import java.util.ArrayList;
import java.util.Scanner;

public class InputReader {

    private int noradID;
    private double timeInterval;
    private double baseFrequency;
    private double signalBandwidth;
    private AbsoluteDate endTime;
    private String inputFileName;
    private double dopplerErrorTime;
    private File inputFile;
    private Scanner elScanner;

    public InputReader(String inputFileName) throws FileNotFoundException{
        this.inputFileName=inputFileName;
        this.inputFile=new File(inputFileName);
        this.elScanner=new Scanner(this.inputFile);
    }
    public void read(){
        //store the parameters in input file as

        elScanner.useDelimiter("\n");

        //1st line: Norad ID
        String noradString=elScanner.next();
        noradID= Integer.valueOf(noradString.replace("noradID=",""));
      //  System.out.println(noradID);

        //2nd line: downlink base frequency
        String baseFreqString=elScanner.next();
        baseFrequency= Double.valueOf(baseFreqString.replace("baseFrequency=",""));
        //System.out.println(baseFrequency);

        //3rd line: signal bandwidth
        String signalBandwidthString=elScanner.next();
        signalBandwidth= Double.valueOf(signalBandwidthString.replace("signalBandwidth=",""));
        //System.out.println(signalBandwidth);

        //4th line: time interval for doppler shift tuning
        String timeIntervalString=elScanner.next();
        timeInterval= Double.valueOf(timeIntervalString.replace("timeInterval=",""));
        //System.out.println(timeInterval);

        //5th line: End Time in Eastern Standard Time.
        // NOTE: UTC time scale is +5 hrs ahead of EST!!!
        //2020-01-19T10:20:00
        //NOTE: the T after the day just is an indicator that the time part of the string is starting
        //   Complete date plus hours, minutes, seconds and a decimal fraction of a
        //second
        // YYYY-MM-DDThh:mm:ss.sTZD
        // TZD= +hh:mm or -hh:mm, to tell offset from UTC.
        //1994-11-05T08:15:30-05:00 corresponds to November 5, 1994, 8:15:30 am, US Eastern Standard Time.
        String endTimeString=elScanner.next();
        endTimeString= endTimeString.replace("endTime=","");
       // System.out.println(endTimeString);

        //splitting end date string into year month day and hour min sec components
        String[] splitEndTimeString=endTimeString.split("T");

        //splitting those strings and separating each component
        String[] yearMonthDay= splitEndTimeString[0].split("-");
        String hourMinSecString=splitEndTimeString[1].substring(0,12);
        String[] hourMinSec=hourMinSecString.split(":");

        //timezone offset for offset from UTC scale
        String timeZoneOffsetString=splitEndTimeString[1].substring(13,splitEndTimeString[1].length());
        String[] hourMinOffset=timeZoneOffsetString.split(":");

        //making AbsoluteDate object from the string date input
        //AbsoluteDate(int year, int month, int day, int hour, int minute, double second, TimeScale timeScale)
        //endTime=new AbsoluteDate(,,,);

        endTime=convertToAbsoluteDate(yearMonthDay,hourMinSec,hourMinOffset);
        //System.out.println(endTime.toString());

        //6th line: error time for doppler shift max min bound
        String errorTimeString=elScanner.next();
        dopplerErrorTime= Double.valueOf(errorTimeString.replace("errorTime=",""));
        //System.out.println(dopplerErrorTime);
        elScanner.close();

    }
    public static AbsoluteDate convertToAbsoluteDate(String[] yearMonthDay, String[] hourMinSec, String[] hourMinOffset){

        int year=Integer.valueOf(yearMonthDay[0]);
        int month=Integer.valueOf(yearMonthDay[1]);
        int day=Integer.valueOf(yearMonthDay[2]);

        int hour=Integer.valueOf(hourMinSec[0]);
        int min=Integer.valueOf(hourMinSec[1]);
        double sec=Double.valueOf(hourMinSec[2]);

        int hourOffset=Integer.valueOf(hourMinOffset[0]);
        int minOffset=Integer.valueOf(hourMinOffset[1]);

        //if the time offset string is negative, we gotta make the minute part of the string also negative.
        if (hourOffset<0){
            minOffset=-minOffset;
        }

        //if the minute offset pushes the time to the previous or next hour, need to account for this.
        int newMinOffset=0;
        if ((min+minOffset)>60){
            min= min+minOffset-60;
            hour=hour+1;
        }
        else if ((min+minOffset)<0){
            min=min+minOffset+60;
            hour=hour-1;
        }
        else {  //normal case
        min=min+minOffset;
        }

        //if the hour offset pushes the time to the previous or next day, need to account for this.
       // int newHourOffset=0;
        if ((hour+hourOffset)>24){
            hour= hour+hourOffset -24 ;
            day=day+1;
        }
        else if ((hour+hourOffset)<0){
            hour=hour+hourOffset +24;
            day=day-1;
        }
        else{  //normal case
            hour=hour+hourOffset;
        }
        AbsoluteDate theAbsDate=new AbsoluteDate(year,month,day,hour,min,sec,TimeScalesFactory.getUTC());
        return theAbsDate;
    }

    public int getNoradID() {
        return noradID;
    }
    public double getTimeInterval(){return timeInterval;}
    public double getBaseFrequency(){return baseFrequency;}
    public AbsoluteDate getEndTime(){return endTime;}
    public double getDopplerErrorTime(){return dopplerErrorTime;}
    public double getSignalBandwidth(){return signalBandwidth;}

}
