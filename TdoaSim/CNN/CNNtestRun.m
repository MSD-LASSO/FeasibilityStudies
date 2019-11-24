digitDatasetPath='Images/Test6ThickerStrip';
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','none');
load Test6ThickerStrip.mat

name=cell(length(GT),1);
for i=1:length(GT)
    name{i}=[digitDatasetPath '/' num2str(i) '.png'];
end

GTtable=table(name,GT(:,1),GT(:,2));

load Test6ValThickerStrip.mat
Valtable=table(name,GT(:,1),GT(:,2));

epochs = 2; %number of epochs
miniBatch = 64; % number of images per minibatch
lR = 5e-6; % learning rate
GPUDevice = 0; % which gpu device?
L2Reg = 0; % L2 regularization factor

if GPUDevice==0
    options = trainingOptions('sgdm', ...
        'Momentum',0.95,...
        'InitialLearnRate',lR, ...
        'L2Regularization',L2Reg, ...
        'MaxEpochs',epochs, ...
        'MiniBatchSize',miniBatch, ...
        'LearnRateSchedule','piecewise',...
        'LearnRateDropFactor',0.25,...
        'LearnRateDropPeriod',4, ...
        'ValidationData',Valtable,...
        'ValidationFrequency',10, ...
        'Shuffle','every-epoch',...
        'Plots','training-progress',...
        'CheckpointPath','TestEpochs');
else
    options = trainingOptions('sgdm', ...
        'Momentum',0.95,...
        'InitialLearnRate',lR, ...
        'L2Regularization',L2Reg, ...
        'MaxEpochs',epochs, ...
        'MiniBatchSize',miniBatch, ...
        'LearnRateSchedule','piecewise',...
        'LearnRateDropFactor',0.25,...
        'LearnRateDropPeriod',4, ...
        'ValidationData',Valtable,...
        'ValidationFrequency',10, ...
        'Shuffle','every-epoch',...
        'Plots','training-progress',...
        'CheckpointPath','TestEpochs',...
        'ExecutionEnvironment','gpu');
end
 
  

load Resnet101Modified.mat
% net = trainNetwork(GTtable,layers,options);
net=trainNetwork(GTtable,lgraph_2,options); 

% ypredict=predict(net,Valtable(:,1));