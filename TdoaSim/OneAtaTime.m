function [SensitivityLocation, SensitivityTime]=OneAtaTime(GND,SAT,considerTime,considerLocation,folderName,Frame,DebugMode)
%Decide which OneAtaTime analysis to use.
%folderName dictates the name one level below "plots".

if length(GND)==3
    [SensitivityLocation, SensitivityTime]=OneAtaTime3(GND,SAT,considerTime,considerLocation,folderName,Frame,DebugMode);
elseif length(GND)==4
    [SensitivityLocation, SensitivityTime]=OneAtaTime4(GND,SAT,considerTime,considerLocation,folderName);
else
    error('Unknown case')
end

end

