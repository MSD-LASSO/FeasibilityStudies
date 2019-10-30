function OneAtaTime(GND,SAT,considerTime,considerLocation,folderName)
%Decide which OneAtaTime analysis to use.
%folderName dictates the name one level below "plots".

if length(GND)==3
    OneAtaTime3(GND,SAT,considerTime,considerLocation,folderName);
elseif length(GND)==4
    OneAtaTime4(GND,SAT,considerTime,considerLocation,folderName);
else
    error('Unknown case')
end

end

