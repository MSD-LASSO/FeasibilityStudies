package com.LASSO.StandaloneSimulations;

import com.LASSO.Utils;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;

import java.util.ArrayList;

public class hailMaryRelTimeProcessing {

    public static void main(String[] args){
        Utils.addOrekitData();
        TimeScale utc = TimeScalesFactory.getUTC();

        String[] Times=new String[]{
        "2020-03-26T18:34:00.100000",
        "2020-03-26T18:34:31.100000",
        "2020-03-26T18:35:02.100000",
        "2020-03-26T18:35:33.100000",
        "2020-03-26T18:36:04.100000",
        "2020-03-26T18:36:35.100000",
        "2020-03-26T18:37:06.100000",
        "2020-03-26T18:37:37.100000",
        "2020-03-26T18:38:08.100000",
        "2020-03-26T18:38:39.100000",
        "2020-03-26T18:39:10.100000",
        "2020-03-26T18:39:41.100000",
        "2020-03-26T18:40:12.100000",
        "2020-03-26T18:40:43.100000",
        "2020-03-26T18:41:14.100000",
        "2020-03-26T18:41:45.100000",
        "2020-03-26T18:42:16.100000",
        "2020-03-26T18:42:47.100000",
        "2020-03-26T18:43:18.100000",
        "2020-03-26T18:43:49.100000"};


        AbsoluteDate epoch=new AbsoluteDate("2020-03-26T18:31:40.105",utc);
        ArrayList<AbsoluteDate> dates=new ArrayList<>();
        ArrayList<Double> relDates=new ArrayList<>();

        for (String time: Times) {

            AbsoluteDate date=new AbsoluteDate(time,utc);

            double offset=date.durationFrom(epoch);

//            System.out.println(date.toString());
            dates.add(date);
            relDates.add(offset);

            System.out.println(offset);

        }

        System.out.println(dates);
        System.out.println(relDates);














    }


}
