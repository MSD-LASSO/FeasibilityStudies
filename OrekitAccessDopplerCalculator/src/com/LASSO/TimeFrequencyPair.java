package com.LASSO;

import org.hipparchus.analysis.function.Abs;
import org.orekit.time.AbsoluteDate;

/**
 * Container to store time and frequency pairings.
 */
public class TimeFrequencyPair {

    private AbsoluteDate date;
    private ValueRange frequency;

    /**
     *
     * @param date Absolute date when this frequency should be measured.
     * @param nominalfrequency in Hz to measure at.
     * @param frequencyRange lower and upper bound of nominal frequency.
     */
    public TimeFrequencyPair(AbsoluteDate date, double nominalfrequency, double[] frequencyRange){
        this.date=date;
        frequency=new ValueRange(nominalfrequency,frequencyRange[0],frequencyRange[1]);
    }

    public TimeFrequencyPair(AbsoluteDate date, ValueRange frequency){
        this.date=date;
        this.frequency=frequency;
    }

    public AbsoluteDate getDate() {
        return date;
    }

    public ValueRange getFrequency() {
        return frequency;
    }

    public String toString(){
        return date.toString() + "      "+ frequency.getNominal()+"     "+frequency.getLowerBound()+"       "+frequency.getUpperBound();
    }
}
