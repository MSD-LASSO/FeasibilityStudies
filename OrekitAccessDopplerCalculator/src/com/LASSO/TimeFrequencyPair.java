package com.LASSO;

import org.hipparchus.analysis.function.Abs;
import org.orekit.time.AbsoluteDate;

/**
 * Container to store time and frequency pairings.
 */
public class TimeFrequencyPair {

    private AbsoluteDate date;
    private ValueRange frequency;
    private double relativeTime;

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
    public void calcRelativeTime(AbsoluteDate startDate){
        relativeTime=date.durationFrom(startDate);
    }

    public AbsoluteDate getDate() {
        return date;
    }

    public ValueRange getFrequency() {
        return frequency;
    }

    public String toString(){

        String outputString1=String.format(date.toString()+", %7.2f ",relativeTime);
        String outputString2=String.format("             ,%.8f    ,%.8f   ,%.8f",frequency.getNominal(),frequency.getLowerBound(),frequency.getUpperBound());
        //return String.format(date.toString()+", %7.2f, ",relativeTime,"    ,%.8f    ,%.8f   ,%.8f", frequency.getNominal(),frequency.getLowerBound(),frequency.getUpperBound());
        return outputString1+outputString2;

//        return date.toString() + "      "+ frequency.getNominal()+"     "+frequency.getLowerBound()+"       "+frequency.getUpperBound();
    }
    public String toStringWithoutDate(){
        return String.format( "  ,%.8f    ,%.8f   ,%.8f", frequency.getNominal(),frequency.getLowerBound(),frequency.getUpperBound());
    }
}
