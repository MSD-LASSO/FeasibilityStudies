package com.LASSO;

import org.hipparchus.util.FastMath;

import java.util.InputMismatchException;

public class ValueRange {

    private double nominal;
    private double lowerBound;
    private double upperBound;

    public ValueRange(double nominal, double lowerBound, double upperBound){
        this.nominal=nominal;
        this.lowerBound=lowerBound;
        this.upperBound=upperBound;
        if(FastMath.abs(lowerBound)>FastMath.abs(upperBound)){
                throw new InputMismatchException("Lower bound should be less than upper bound");
        }
    }

    public double getNominal() {
        return nominal;
    }

    public double getLowerBound() {
        return lowerBound;
    }

    public double getUpperBound() {
        return upperBound;
    }
}
