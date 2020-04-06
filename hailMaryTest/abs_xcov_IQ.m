function [sample_delay, corr_factor, lags_matrix, lags, Ts] = abs_xcov_IQ(IQ_data_1, IQ_data_2, max_lag,titleString,fractionOfData)
%This function  takes in two IQ data files and returns the complex cross
%correlation results

if nargin<4
    titleString=[]
end

[x1, Fs1, N1All] = readIQ(IQ_data_1);
[x2, Fs2, N2All] = readIQ(IQ_data_2);

percents=0:fractionOfData:1-fractionOfData;
sample_delay=zeros(length(percents),1);
for p=1:length(percents)
    sa=ceil(percents(p)*N1All)+1;
    en=ceil((percents(p)+fractionOfData)*N2All);
%     x1=x1All(sa:en);
%     x2=x2All(sa:en);
    N1=size(x1(sa:en),1);
    N2=size(x2(sa:en),1);
    
    if Fs1 ~= Fs2
        disp('The data sets are sampled at different frequencies');
        return;
    end
    if max_lag == 0
        if N1 <= N2
            max_lag_f = N1;
        else
            max_lag_f = N2;
        end
    else
        max_lag_f = max_lag;
    end
    Ts = 1 / Fs1;
    [d, lags] = xcov(x1(sa:en), x2(sa:en), max_lag_f);
    d_norm = abs(d)/max(abs(d));
    figure()
    plot(lags*Ts, abs(d_norm))
    xlabel('Time Delay [s]');
    ylabel('Normalized Crosscorrelation');
    title([titleString 'Absolute Value Cross-covariance Plot at ' num2str(percents(p)*100) '%']);
    legend(strcat('first pi ',' - ',' second pi'));
    [corr_factor, index_max] = max(abs(d));
    sample_delay(p) = index_max - round(size(lags, 2)/2); 
    lags_matrix = d;
    
    if mod(p,50)==0
        GraphSaver({'png'},'Plots/millisecond150Intervals',1,0);
    end
    
end
GraphSaver({'png'},'Plots/millisecond150Intervals',1,0);
end

