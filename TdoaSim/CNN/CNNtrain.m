digitDatasetPath='Images/Test3correctOutputs';
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','none');
load Test3correctOutputs.mat

name=cell(length(GT),1);
for i=1:length(GT)
    name{i}=[digitDatasetPath '/' num2str(i) '.png'];
end

GTtable=table(name,GT(:,1),GT(:,2));

layers = [
    imageInputLayer([224 224 3])
    
    convolution2dLayer(20,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(20,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(20,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(7)
    fullyConnectedLayer(2)
    regressionLayer]; %how do I add in additional inputs at Fullyconnected layer?

% options = trainingOptions('sgdm', ...
%     'LearnRateSchedule','piecewise', ...
%     'LearnRateDropFactor',0.2, ...
%     'LearnRateDropPeriod',5, ...
%     'MaxEpochs',20, ...
%     'MiniBatchSize',64, ...
%     'Plots','training-progress');
load Test3Validation.mat
Valtable=table(name,GT(:,1),GT(:,2));

options=trainingOptions('sgdm','InitialLearnRate',1e-6,...
    'MaxEpochs',10, ...
    'Shuffle','every-epoch',...
    'ValidationData',Valtable,...
    'Plots','training-progress');
    

        

net = trainNetwork(GTtable,layers,options);
