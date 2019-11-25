function zNames = getZnames(zPlanes,outputFolder)

zNames=cell(length(zPlanes),1);
for i=1:length(zPlanes)
    zNames{i}=num2str(zPlanes(i));
    mkdir([outputFolder '/' zNames{i}]);
end

end

