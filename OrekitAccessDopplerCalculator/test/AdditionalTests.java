import com.LASSO.Utils;
import com.LASSO.ValueRange;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import java.util.InputMismatchException;

public class AdditionalTests {

    @Before
    public void setUp(){
        Utils.addOrekitData();
    }


    @Test
    public void ValueRangeTest(){
        ValueRange value=new ValueRange(2.5,2,3);
        Assert.assertEquals(2,value.getLowerBound(),0);
        Assert.assertEquals(2.5,value.getNominal(),0);
        Assert.assertEquals(3,value.getUpperBound(),0);

        try {
            value=new ValueRange(5,2,3);
        } catch (InputMismatchException e){
            Assert.assertTrue(e.getMessage().contains("ERROR 051"));
        }

        try {
            value=new ValueRange(2.5,3,2);
        } catch (InputMismatchException e){
            Assert.assertTrue(e.getMessage().contains("ERROR 050"));
        }
    }

    @Test
    public void findsAllEventsTest(){

    }

    @Test
    public void startsInMiddleOfEventTest(){

    }

    @Test
    public void endsInMiddleOfEventTest(){

    }

    @Test
    public void ApproximateDopplerComparisonTest(){

    }
}
