digitDatasetPath='Images/Test7manyImages';
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','none');
load Test7manyImages.mat

name=cell(length(GT),1);
for i=1:length(GT)
    name{i}=[digitDatasetPath '/' num2str(i) '.png'];
end

GTtable=table(name,GT(:,1),GT(:,2));

layers = [
    imageInputLayer([224 224 3])
    
    convolution2dLayer(25,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(25,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(25,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(7)
    reluLayer
    fullyConnectedLayer(4)
    reluLayer
    fullyConnectedLayer(2)
    regressionLayer]; %how do I add in additional inputs at Fullyconnected layer?

% options = trainingOptions('sgdm', ...
%     'LearnRateSchedule','piecewise', ...
%     'LearnRateDropFactor',0.2, ...
%     'LearnRateDropPeriod',5, ...
%     'MaxEpochs',20, ...
%     'MiniBatchSize',64, ...
%     'Plots','training-progress');
load Test6ValThickerStrip.mat
Valtable=table(name,GT(:,1),GT(:,2));

epochs = 10; %number of epochs
miniBatch = 64; % number of images per minibatch
lR = 5e-6; % learning rate
% GPUDevice = 1; % which gpu device?
L2Reg = 0; % L2 regularization factor
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
    'CheckpointPath','Epochs');

%     'ExecutionEnvironment','gpu'
% 'GradientDecayFactor',0.9, %default is 0.9
%    'SquaredGradientDecayFactor' ,0.999,
%     

% options=trainingOptions('sgdm','InitialLearnRate',1e-6,...
%     'MaxEpochs',10, ...
%     'Shuffle','every-epoch',...
%     'ValidationData',Valtable,...
%     'Plots','training-progress');
        

% net = trainNetwork(GTtable,layers,options);
net=trainNetwork(GTtable,lgraph_1,options); 

ypredict=predict(net,Valtable(:,1))