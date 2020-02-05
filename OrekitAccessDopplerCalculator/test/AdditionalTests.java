import com.LASSO.*;
import org.hipparchus.analysis.function.Abs;
import org.hipparchus.util.FastMath;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.orekit.propagation.analytical.tle.TLE;
import org.orekit.time.AbsoluteDate;
import org.orekit.time.TimeScale;
import org.orekit.time.TimeScalesFactory;

import java.util.ArrayList;
import java.util.InputMismatchException;

public class AdditionalTests {

    @Before
    public void setUp() {
        Utils.addOrekitData();
    }


    @Test
    public void ValueRangeTest() {
        ValueRange value = new ValueRange(2.5, 2, 3);
        Assert.assertEquals(2, value.getLowerBound(), 0);
        Assert.assertEquals(2.5, value.getNominal(), 0);
        Assert.assertEquals(3, value.getUpperBound(), 0);

        try {
            value = new ValueRange(5, 2, 3);
        } catch (InputMismatchException e) {
            Assert.assertTrue(e.getMessage().contains("ERROR 051"));
        }

        try {
            value = new ValueRange(2.5, 3, 2);
        } catch (InputMismatchException e) {
            Assert.assertTrue(e.getMessage().contains("ERROR 050"));
        }
    }

    @Test
    public void findsAllEventsTest() {

        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate initialDate = new AbsoluteDate(2020, 2, 5, 0, 0, 00.000, utc);
        AbsoluteDate endDate = new AbsoluteDate(2020, 2, 5, 7, 0, 00.000, utc);
        ADcalculator calc=setupEventTests();


        ArrayList<Access> accessTimes = calc.computeAccessTimes(initialDate, endDate, true);
        //# of Access = 20.

        AbsoluteDate a1 = new AbsoluteDate(2020, 2, 5, 2, 55, 42.310, utc);
        AbsoluteDate a2 = new AbsoluteDate(2020, 2, 5, 3, 4, 28.537, utc);
        AbsoluteDate b1 = new AbsoluteDate(2020, 2, 5, 4, 32, 55.745, utc);
        AbsoluteDate b2 = new AbsoluteDate(2020, 2, 5, 4, 43, 26.605, utc);
        AbsoluteDate c1 = new AbsoluteDate(2020, 2, 5, 6, 11, 7.861, utc);
        AbsoluteDate c2 = new AbsoluteDate(2020, 2, 5, 6, 21, 47.481, utc);

        Assert.assertEquals(3, accessTimes.size(), 0);
        //Check start and end point of each access.
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(0).getBegin().getState().getDate().durationFrom(a1)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(0).getEnd().getState().getDate().durationFrom(a2)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(1).getBegin().getState().getDate().durationFrom(b1)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(1).getEnd().getState().getDate().durationFrom(b2)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(2).getBegin().getState().getDate().durationFrom(c1)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(2).getEnd().getState().getDate().durationFrom(c2)), 1e-3);

    }

    @Test
    public void startsAndEndsInMiddleOfEventTest(){
        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate initialDate = new AbsoluteDate(2020, 2, 5, 3, 0, 00.000, utc);
        AbsoluteDate endDate = new AbsoluteDate(2020, 2, 5, 6, 15, 00.000, utc);
        ADcalculator calc=setupEventTests();


        ArrayList<Access> accessTimes = calc.computeAccessTimes(initialDate, endDate, true);
        //# of Access = 20.

        AbsoluteDate b1 = new AbsoluteDate(2020, 2, 5, 4, 32, 55.745, utc);
        AbsoluteDate b2 = new AbsoluteDate(2020, 2, 5, 4, 43, 26.605, utc);

        Assert.assertEquals(1, accessTimes.size(), 0);
        //Check start and end point of each access.
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(0).getBegin().getState().getDate().durationFrom(b1)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(0).getEnd().getState().getDate().durationFrom(b2)), 1e-3);
    }

    @Test
    public void startsInMiddleOfEventTest() {
        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate initialDate = new AbsoluteDate(2020, 2, 5, 3, 0, 00.000, utc);
        AbsoluteDate endDate = new AbsoluteDate(2020, 2, 5, 7, 0, 00.000, utc);
        ADcalculator calc=setupEventTests();


        ArrayList<Access> accessTimes = calc.computeAccessTimes(initialDate, endDate, true);
        //# of Access = 20.

        AbsoluteDate b1 = new AbsoluteDate(2020, 2, 5, 4, 32, 55.745, utc);
        AbsoluteDate b2 = new AbsoluteDate(2020, 2, 5, 4, 43, 26.605, utc);
        AbsoluteDate c1 = new AbsoluteDate(2020, 2, 5, 6, 11, 7.861, utc);
        AbsoluteDate c2 = new AbsoluteDate(2020, 2, 5, 6, 21, 47.481, utc);

        Assert.assertEquals(2, accessTimes.size(), 0);
        //Check start and end point of each access.
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(0).getBegin().getState().getDate().durationFrom(b1)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(0).getEnd().getState().getDate().durationFrom(b2)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(1).getBegin().getState().getDate().durationFrom(c1)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(1).getEnd().getState().getDate().durationFrom(c2)), 1e-3);
    }

    @Test
    public void endsInMiddleOfEventTest() {
        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate initialDate = new AbsoluteDate(2020, 2, 5, 0, 0, 00.000, utc);
        AbsoluteDate endDate = new AbsoluteDate(2020, 2, 5, 6, 15, 00.000, utc);
        ADcalculator calc=setupEventTests();


        ArrayList<Access> accessTimes = calc.computeAccessTimes(initialDate, endDate, true);
        //# of Access = 20.

        AbsoluteDate a1 = new AbsoluteDate(2020, 2, 5, 2, 55, 42.310, utc);
        AbsoluteDate a2 = new AbsoluteDate(2020, 2, 5, 3, 4, 28.537, utc);
        AbsoluteDate b1 = new AbsoluteDate(2020, 2, 5, 4, 32, 55.745, utc);
        AbsoluteDate b2 = new AbsoluteDate(2020, 2, 5, 4, 43, 26.605, utc);

        Assert.assertEquals(2, accessTimes.size(), 0);
        //Check start and end point of each access.
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(0).getBegin().getState().getDate().durationFrom(a1)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(0).getEnd().getState().getDate().durationFrom(a2)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(1).getBegin().getState().getDate().durationFrom(b1)), 1e-3);
        Assert.assertEquals(0, FastMath.abs(accessTimes.get(1).getEnd().getState().getDate().durationFrom(b2)), 1e-3);
    }

    @Test
    public void ApproximateDopplerComparisonTest() {

        TimeScale utc = TimeScalesFactory.getUTC();
        AbsoluteDate initialDate = new AbsoluteDate(2020, 2, 5, 0, 0, 00.000, utc);
        AbsoluteDate endDate = new AbsoluteDate(2020, 2, 5, 7, 0, 00.000, utc);
        ADcalculator calc=setupEventTests();


        ArrayList<Access> accessTimes = calc.computeAccessTimes(initialDate, endDate, true);
        //# of Access = 20.


        //Obtained from OrbitTron with same lat and long of station.
        double[] groundTruthDoppler=new double[]{437.009018,436.993303,436.990622};


        Assert.assertEquals(3, accessTimes.size(), 0);
        Assert.assertEquals(groundTruthDoppler[0],accessTimes.get(1).getTimesAndFrequency().get(0).getFrequency().getNominal(),1e-4);
        Assert.assertEquals(groundTruthDoppler[1],accessTimes.get(1).getTimesAndFrequency().get(3).getFrequency().getNominal(),1e-4);
        Assert.assertEquals(groundTruthDoppler[2],accessTimes.get(1).getTimesAndFrequency().get(6).getFrequency().getNominal(),1e-4);

    }

    public ADcalculator setupEventTests() {
        //        FALCONSAT-3 from 2/5/2020
        String line1 = "1 30776U 07006E   20035.39966073  .00002439  00000-0  66842-4 0  9997";
        String line2 = "2 30776  35.4354  57.2761 0001833  28.7292 331.3536 15.37158437716194";
        TLE test = new TLE(line1, line2);


        double[] stationLatitudes = {43.209037};
        double[] stationLongitudes = {-77.950921};
        double[] stationAltitudes = {0};
        double[] minElevations = {0};
        String[] stationNames = {"Brockport University"};


        ArrayList<Station> stations = Utils.createStations(false, stationLatitudes, stationLongitudes, stationAltitudes, minElevations, stationNames);

        ADcalculator calc = new ADcalculator(30776, 150, stations, 437, 0.3, 1, 0.5);
        calc.setSatelliteOrbit(test); //set to our static TLE for consistency.

        return calc;
    }

}
