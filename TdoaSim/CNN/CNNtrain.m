ImageFolder='50'; zz=2; names=0; netPath='C:\Users\awian\Desktop\MachineIntelligence\Resnet101trained400.mat';
% ImageFolder='50NBC'; zz=2; names=1; netPath='C:\Users\awian\Desktop\MachineIntelligence\Resnet101trained400NBC.mat';
% ImageFolder='400'; zz=1; names=0; netPath='C:\Users\awian\Desktop\MachineIntelligence\Resnet101Modified.mat';
% ImageFolder='400NBC'; zz=1; names=1; netPath='C:\Users\awian\Desktop\MachineIntelligence\Resnet101Modified.mat';
% ImageFolder='1200'; zz=3; names=0; netPath='C:\Users\awian\Desktop\MachineIntelligence\Resnet101trained400.mat';
% ImageFolder='1200NBC'; zz=3; names=1; netPath='C:\Users\awian\Desktop\MachineIntelligence\Resnet101trained400NBC.mat';

digitDatasetPath=['Images/Test11/' ImageFolder];
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','none');
load Test11.mat

% name=cell(length(GT),1);
% for i=1:length(GT)
%     name{i}=[digitDatasetPath '/' num2str(i) '.png'];
% end
if names==0
    nameCell=nameBC;
else
    nameCell=nameNBC;
end

name=cell(size(nameCell,1),1);
for i=1:size(nameCell,1)
    if isempty(nameCell{i,1}{zz})==0
        name{i}=nameCell{i,1}{zz};
    else
        name(i:end)=[];
        break;
    end
end
if size(name,1)<size(nameCell,1)
    i=i-1;
end

GTtable=table(name,GT(1:i,1,zz),GT(1:i,2,zz));

% layers = [
%     imageInputLayer([224 224 3])
%     
%     convolution2dLayer(25,8,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     maxPooling2dLayer(2,'Stride',2)
%     
%     convolution2dLayer(25,16,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     maxPooling2dLayer(2,'Stride',2)
%     
%     convolution2dLayer(25,32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     fullyConnectedLayer(7)
%     reluLayer
%     fullyConnectedLayer(4)
%     reluLayer
%     fullyConnectedLayer(2)
%     regressionLayer]; %how do I add in additional inputs at Fullyconnected layer?

% options = trainingOptions('sgdm', ...
%     'LearnRateSchedule','piecewise', ...
%     'LearnRateDropFactor',0.2, ...
%     'LearnRateDropPeriod',5, ...
%     'MaxEpochs',20, ...
%     'MiniBatchSize',64, ...
%     'Plots','training-progress');
load Test11val.mat
if names==0
    nameCell=nameBC;
else
    nameCell=nameNBC;
end

name=cell(size(nameCell,1),1);
for i=1:size(nameCell,1)
    if isempty(nameCell{i,1}{zz})==0
        name{i}=nameCell{i,1}{zz};
    else
        name(i:end)=[];
        break;
    end
end
if size(name,1)<size(nameCell,1)
    i=i-1;
end
Valtable=table(name,GT(1:i,1,zz),GT(1:i,2,zz));

load(netPath);
if zz~=1
    lgraph_2=layerGraph(net);
    lR=1e-6;
    DropFactor=0.75;
    Period=4;
else
    lR = 1e-3; % learning rate
    DropFactor=0.1;
    Period=1;
end

epochs = 10; %number of epochs
miniBatch = 24; % number of images per minibatch

GPUDevice = 1; % which gpu device?
L2Reg = 0; % L2 regularization factor
Freq=25;

if GPUDevice==0
    options = trainingOptions('sgdm', ...
        'Momentum',0.95,...
        'InitialLearnRate',lR, ...
        'L2Regularization',L2Reg, ...
        'MaxEpochs',epochs, ...
        'MiniBatchSize',miniBatch, ...
        'LearnRateSchedule','piecewise',...
        'LearnRateDropFactor',DropFactor,...
        'LearnRateDropPeriod',Period, ...
        'ValidationData',Valtable,...
        'ValidationFrequency',Freq, ...
        'Shuffle','every-epoch',...
        'Plots','training-progress',...
        'CheckpointPath','C:\Users\awian\Desktop\MachineIntelligence\Epochs');
else
    options = trainingOptions('sgdm', ...
        'Momentum',0.95,...
        'InitialLearnRate',lR, ...
        'L2Regularization',L2Reg, ...
        'MaxEpochs',epochs, ...
        'MiniBatchSize',miniBatch, ...
        'LearnRateSchedule','piecewise',...
        'LearnRateDropFactor',DropFactor,...
        'LearnRateDropPeriod',Period, ...
        'ValidationData',Valtable,...
        'ValidationFrequency',Freq, ...
        'Shuffle','every-epoch',...
        'Plots','training-progress',...
        'ExecutionEnvironment','gpu');
end
% 'CheckpointPath','C:\Users\awian\Desktop\MachineIntelligence\Epochs',...
%     
% 'GradientDecayFactor',0.9, %default is 0.9
%    'SquaredGradientDecayFactor' ,0.999,
%     

% options=trainingOptions('sgdm','InitialLearnRate',1e-6,...
%     'MaxEpochs',10, ...
%     'Shuffle','every-epoch',...
%     'ValidationData',Valtable,...
%     'Plots','training-progress');
        

% net = trainNetwork(GTtable,layers,options);
net=trainNetwork(GTtable,lgraph_2,options); 

ypredict=predict(net,Valtable(:,1));
error=ypredict-GT(1:i,:,zz);
figure()
plot(error(:,1),error(:,2),'.')
title('Residuals')
xlabel('X error')
ylabel('Y error')
