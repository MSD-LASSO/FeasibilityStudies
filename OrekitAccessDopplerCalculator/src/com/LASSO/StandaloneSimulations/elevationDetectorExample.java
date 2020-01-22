package com.LASSO.StandaloneSimulations;

import com.LASSO.Utils;
import org.hipparchus.util.FastMath;
import org.orekit.attitudes.NadirPointing;
import org.orekit.bodies.BodyShape;
import org.orekit.bodies.GeodeticPoint;
import org.orekit.bodies.OneAxisEllipsoid;
import org.orekit.frames.Frame;
import org.orekit.frames.FramesFactory;
import org.orekit.frames.TopocentricFrame;
import org.orekit.propagation.analytical.tle.SGP4;
import org.orekit.propagation.analytical.tle.TLE;
import org.orekit.propagation.events.ElevationDetector;
import org.orekit.propagation.events.EventsLogger;
import org.orekit.propagation.events.handlers.RecordAndContinue;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;
import org.orekit.utils.Constants;
import org.orekit.utils.IERSConventions;

import java.util.List;
import java.util.TimeZone;

public class elevationDetectorExample {

    public static void main(String[] args){
        Utils.addOrekitData();

        //from 1/21
//        String line1="1 30776U 07006E   20021.43542388  .00002005  00000-0  55335-4 0  9990";
//        String line2="2 30776  35.4342 146.5236 0003293 279.7300  80.3055 15.37092046714042";
        //from 1/22
        String line1="1 30776U 07006E   20022.60454396  .00002023  00000-0  55821-4 0  9991";
        String line2="2 30776  35.4343 139.0520 0003256 287.7420  72.2952 15.37097043714225";


        TLE falconSat=new TLE(line1,line2);

        BodyShape earth=getDefaultEarth();
        Frame inertialFrame = FramesFactory.getEME2000();

        NadirPointing pointing=new NadirPointing(inertialFrame,earth);

        GeodeticPoint point=new GeodeticPoint(FastMath.toRadians(43.1574),FastMath.toRadians(-77.6042),0);
        TopocentricFrame station=new TopocentricFrame(earth,point,"Station");

        ElevationDetector detector=new ElevationDetector(60.0,0.001,station).withConstantElevation(0).
                withHandler(new RecordAndContinue());
        EventsLogger logger=new EventsLogger();


        SGP4 prop=new SGP4(falconSat,pointing,100);
        prop.addEventDetector(logger.monitorDetector(detector));

        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate initialDate=new AbsoluteDate(2020,1,22,16,0,00.000,utc);
        AbsoluteDate endDate=new AbsoluteDate(2020,1,24,0,0,00.000,utc);
        prop.propagate(initialDate, endDate);

        List<EventsLogger.LoggedEvent> events=logger.getLoggedEvents();
//        String[] TZ=TimeZone.getAvailableIDs();
        for(EventsLogger.LoggedEvent e : events){
            System.out.println(e.getState().getDate().toString(TimeZone.getTimeZone("America/New_York")));
//            System.out.println(e.getState().getDate().toString());
        }

    }

    public static BodyShape getDefaultEarth(){
        Frame earthFrame = FramesFactory.getITRF(IERSConventions.IERS_2010, true);
        ///*
        return new OneAxisEllipsoid(Constants.WGS84_EARTH_EQUATORIAL_RADIUS,
                Constants.WGS84_EARTH_FLATTENING,
                earthFrame);
    }

}
