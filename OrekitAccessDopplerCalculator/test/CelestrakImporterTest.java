import com.LASSO.CelestrakImporter;
import com.LASSO.NoradIDnotFoundException;
import com.LASSO.Utils;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.orekit.propagation.analytical.tle.TLE;

import java.io.IOException;
import java.net.UnknownHostException;

public class CelestrakImporterTest {

    @Before
    public void setUp(){
        Utils.addOrekitData();
    }

    @Test
    public void getTLEtest(){

        int noradID=30776;
        try {
            TLE tle = CelestrakImporter.importSatelliteData(noradID);
            Assert.assertEquals(tle.getSatelliteNumber(),noradID,0);
        } catch (IOException | RuntimeException e){
            System.out.println(e.getStackTrace().toString());
            Assert.fail(e.getMessage());
        } catch (Exception e){
            throw e;
        }

    }

    @Test
    public void failToFindTest(){
        int noradID=666666;
        try {
            TLE tle = CelestrakImporter.importSatelliteData(noradID);
            Assert.fail("Found this noradID. Consider using a new noradID number");
        } catch (NoradIDnotFoundException e) {
            Assert.assertTrue(e.getMessage().contains("ERROR 002"));
        } catch (Exception e){
            System.out.println(e.getStackTrace().toString());
            Assert.fail(e.getMessage());
        }
    }

    /**
     * You must turn off the internet to run this test properly.
     */
    @Test
    public void notConnectedToInternetTest(){
        int noradID=30776;
        try {
            TLE tle = CelestrakImporter.importSatelliteData(noradID);
            System.out.println("WARNING: noConnectedToInternetTest does nothing if host is connected to internet.");
        } catch (UnknownHostException e) {
            Assert.assertTrue(e.getMessage().contains("ERROR 007"));
        } catch (Exception e){
            System.out.println(e.getStackTrace().toString());
            Assert.fail(e.getMessage());
        }

    }

}
