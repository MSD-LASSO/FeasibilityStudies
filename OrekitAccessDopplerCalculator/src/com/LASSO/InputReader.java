package com.LASSO;

import org.orekit.propagation.analytical.tle.SGP4;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScalesFactory;

import java.io.PrintWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.lang.reflect.GenericDeclaration;
import java.util.ArrayList;
import java.util.InputMismatchException;
import java.util.Scanner;

public class InputReader {

    private int noradID;
    private double channelFrequency;
    private AbsoluteDate endTime;
    private AbsoluteDate initialTime;
    private String inputFileName;
    private double errorTimeForTLE;
    private double recordingRate;
    private double paddingTime;
    private File inputFile;
    private Scanner elScanner;

    public InputReader(String inputFileName) throws FileNotFoundException{
        this.inputFileName=inputFileName;
        this.inputFile=new File(inputFileName);
        this.elScanner=new Scanner(this.inputFile);
    }

    public InputReader(){
        //this inputReader is to use for the terminal reading
    }

    public void read(){
        //store tfhe parameters in input file as

        elScanner.useDelimiter("\n");

        if(System.getProperty("os.name").toLowerCase().contains("windows")){
            elScanner.useDelimiter("\r\n");
        }

       try {
            //1st line: Norad ID
            String noradString = elScanner.next();
            noradID = Integer.valueOf(noradString.replace("noradID=", ""));
             System.out.println(noradID);

            //2nd line: downlink channel frequency
            String channelFreqString = elScanner.next();
            channelFrequency = Double.valueOf(channelFreqString.replace("channelFrequency=", ""));
            System.out.println(channelFrequency);


           String initialTimeString = elScanner.next();
           initialTimeString = initialTimeString.replace("initialTime=", "");
           // System.out.println(endTimeString);

           //splitting end date string into year month day and hour min sec components
           String[] splitIntTimeString = initialTimeString.split("T");

           //splitting those strings and separating each component
           String[] yearMonthDay = splitIntTimeString[0].split("-");
           String hourMinSecString = splitIntTimeString[1].substring(0, 12);
           String[] hourMinSec = hourMinSecString.split(":");

           //timezone offset for offset from UTC scale
           String timeZoneOffsetString = splitIntTimeString[1].substring(13, splitIntTimeString[1].length());
           String[] hourMinOffset = timeZoneOffsetString.split(":");

           //making AbsoluteDate object from the string date input
           //AbsoluteDate(int year, int month, int day, int hour, int minute, double second, TimeScale timeScale)
           //endTime=new AbsoluteDate(,,,);

           initialTime = convertToAbsoluteDate(yearMonthDay, hourMinSec, hourMinOffset);

            //5th line: End Time in Eastern Standard Time.
            // NOTE: UTC time scale is +5 hrs ahead of EST!!!
            //2020-01-19T10:20:00
            //NOTE: the T after the day just is an indicator that the time part of the string is starting
            //   Complete date plus hours, minutes, seconds and a decimal fraction of a
            //second
            // YYYY-MM-DDThh:mm:ss.sTZD
            // TZD= +hh:mm or -hh:mm, to tell offset from UTC.
            //1994-11-05T08:15:30-05:00 corresponds to November 5, 1994, 8:15:30 am, US Eastern Standard Time.
            String endTimeString = elScanner.next();
            endTimeString = endTimeString.replace("endTime=", "");
            // System.out.println(endTimeString);

            //splitting end date string into year month day and hour min sec components
            String[] splitEndTimeString = endTimeString.split("T");

            //splitting those strings and separating each component
            yearMonthDay = splitEndTimeString[0].split("-");
            hourMinSecString = splitEndTimeString[1].substring(0, 12);
            hourMinSec = hourMinSecString.split(":");

            //timezone offset for offset from UTC scale
            timeZoneOffsetString = splitEndTimeString[1].substring(13, splitEndTimeString[1].length());
            hourMinOffset = timeZoneOffsetString.split(":");

            //making AbsoluteDate object from the string date input
            //AbsoluteDate(int year, int month, int day, int hour, int minute, double second, TimeScale timeScale)
            //endTime=new AbsoluteDate(,,,);

            endTime = convertToAbsoluteDate(yearMonthDay, hourMinSec, hourMinOffset);
            System.out.println(endTime.toString());

            //6th line: error time for doppler shift max min bound
            String errorTimeString = elScanner.next();
            errorTimeForTLE = Double.valueOf(errorTimeString.replace("errorTimeForTLE=", ""));
            System.out.println(errorTimeForTLE);

            //7th line: record time for SDR. How long it will record data for Cross Correlation purposes
            String recordTimeString = elScanner.next();
            recordingRate = Double.valueOf(recordTimeString.replace("recordingRate=", ""));
            System.out.println(recordingRate);
            String paddingTimeString=elScanner.next();
            paddingTime=  Double.valueOf(paddingTimeString.replace("paddingTime=", ""));
           System.out.println(paddingTime);

            elScanner.close();
        }
        catch (Exception problemo){
            int ERROR_WRONG_TEXT_INPUT = -1;
            int ERROR_BAD_  = -2;
            throw new InputMismatchException("ERROR 001: Problem during input reading. Wrong # of inputs/Identifier strings messed up?");
        }


    }
    public void readFromTerminal(String[] args){
        //New input reading from "args" variable from when this is run from the terminal.
      /*
        INPUTS CAN BE IN ANY ORDER!!!!!!!

        initialDate (current time as DEFAULT)
        endDate  (1 day ahead of initial date)
        noradID= error thrown (legit error)
        errorTimeForTLE (0.3 [s])
        recordingRate     (60 [s] )
        and then add default vals if none chosen. ^^^ in ( ) above.
         */

        //setting default values before reading in
        recordingRate=60;
        errorTimeForTLE=0.3;
        initialTime=Utils.getCurrentTime();
        int timeOffset=86400; //seconds in 1 day
        endTime=initialTime.shiftedBy(timeOffset);
        channelFrequency=437;
        noradID=-1;
        paddingTime=0;
        // check if the user actually put the stuff in
        for (String argument: args)
        {
            if (argument.toLowerCase().contains("noradid=")){
                noradID = Integer.valueOf(argument.toLowerCase().replace("noradid=", ""));
            }
            else if (argument.toLowerCase().contains("initialtime=")){
                String initialTimeString =argument.toLowerCase();
                initialTimeString = initialTimeString.replace("initialtime=", "");
                String[] splitinitialTimeString = initialTimeString.split("T");
                String[] yearMonthDay = splitinitialTimeString[0].split("-");
                String hourMinSecString = splitinitialTimeString[1].substring(0, 12);
                String[] hourMinSec = hourMinSecString.split(":");
                String timeZoneOffsetString = splitinitialTimeString[1].substring(13, splitinitialTimeString[1].length());
                String[] hourMinOffset = timeZoneOffsetString.split(":");
                initialTime = convertToAbsoluteDate(yearMonthDay, hourMinSec, hourMinOffset);
            }
            else if (argument.toLowerCase().contains("endtime=")){
                String endTimeString =argument.toLowerCase();
                endTimeString = endTimeString.replace("endtime=", "");
                String[] splitEndTimeString = endTimeString.split("t");
                String[] yearMonthDay = splitEndTimeString[0].split("-");
                String hourMinSecString = splitEndTimeString[1].substring(0, 12);
                String[] hourMinSec = hourMinSecString.split(":");
                String timeZoneOffsetString = splitEndTimeString[1].substring(13, splitEndTimeString[1].length());
                String[] hourMinOffset = timeZoneOffsetString.split(":");
                endTime = convertToAbsoluteDate(yearMonthDay, hourMinSec, hourMinOffset);
            }
            else if (argument.toLowerCase().contains("errortimefortle=")){
            //   System.out.println(argument);
                errorTimeForTLE=Double.valueOf(argument.toLowerCase().replace("errortimefortle=", ""));
            }
            else if (argument.toLowerCase().contains("recordingrate=")){
                recordingRate=Double.valueOf(argument.toLowerCase().replace("recordingrate=", ""));
            }
            else if (argument.toLowerCase().contains("channelfrequency=")){
                channelFrequency=Double.valueOf(argument.toLowerCase().replace("channelfrequency=", ""));
            }
            else if (argument.toLowerCase().contains("paddingtime=")){
                paddingTime=Double.valueOf(argument.toLowerCase().replace("paddingtime=", ""));
            }
            else{

                throw new InputMismatchException("ERROR 008: UNKNOWN STRING WAS INPUTTED. CHECK AGAIN!!!!!!!!!!!!!!!");
            }

        }
        if (noradID==-1){
            throw new NoradIDnotFoundException("ERROR 002: The NORAD ID was not found!!!!!!!! Please check the command input!!!!!!!!");
        }

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
    public double getChannelFrequency(){return channelFrequency;}
    public AbsoluteDate getEndTime(){return endTime;}
    public AbsoluteDate getinitialTime(){return initialTime;}
    public double getDopplerErrorTime(){return errorTimeForTLE;}
    public double getRecordingRate(){return recordingRate;}
    public double getErrorTimeForTLE(){return errorTimeForTLE;}
    public double getPaddingTime(){return paddingTime;}
}
