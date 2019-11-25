function zNames = getZnames(zPlanes,outputFolder)

zNames=cell(length(zPlanes),1);
for i=1:length(zPlanes)
    zNames{i}=num2str(zPlanes(i)/1000);
    mkdir(['Images/' outputFolder '/' zNames{i}]);
end

end

