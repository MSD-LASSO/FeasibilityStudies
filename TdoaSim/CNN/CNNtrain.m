function CNNtrain(ImageFolder,zz,names,netPath,textT,ImageFolderParent,RelativePath)

if nargin==0
% ImageFolder='50'; zz=2; names=0; netPath='C:\Users\awian\Desktop\MachineIntelligence\netsBC\netz400.mat'; textT='netz50';
% ImageFolder='50NBC'; zz=2; names=1; netPath='C:\Users\awian\Desktop\MachineIntelligence\netsNBC\netz400.mat'; textT='netz50';
ImageFolder='400'; zz=1; names=0; netPath='C:\Users\awian\Desktop\MachineIntelligence\Resnet101Modified.mat'; textT='netz400';
% ImageFolder='400NBC'; zz=1; names=1; netPath='C:\Users\awian\Desktop\MachineIntelligence\Resnet101Modified.mat'; textT='netz400';
% ImageFolder='1200'; zz=3; names=0; netPath='C:\Users\awian\Desktop\MachineIntelligence\netsBC\netz400.mat'; textT='netz1200';
% ImageFolder='1200NBC'; zz=3; names=1; netPath='C:\Users\awian\Desktop\MachineIntelligence\netsNBC\netz400.mat'; textT='netz1200';

ImageFolderParent='Test11';

end

digitDatasetPath=['Images/' ImageFolderParent '/' ImageFolder];
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','none');
load([ImageFolderParent '.mat']);

% name=cell(length(GT),1);
% for i=1:length(GT)
%     name{i}=[digitDatasetPath '/' num2str(i) '.png'];
% end
if names==0
    nameCell=nameBC;
    Folder='netsBC';
else
    nameCell=nameNBC;    
    Folder='netsNBC';

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

load([ImageFolderParent 'val.mat']);
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
    lR=5e-3;
    DropFactor=0.75;
    Period=4;
    epochs = 10; %number of epochs
else
    lR = 5e-3; % learning rate
    DropFactor=0.1;
    Period=1;
    epochs = 3; %number of epochs
end

miniBatch = 32; % number of images per minibatch

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
        'Plots','training-progress');
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
% 
% 'CheckpointPath','C:\Users\awian\Desktop\MachineIntelligence\Epochs',... 
% 'GradientDecayFactor',0.9, %default is 0.9
%    'SquaredGradientDecayFactor' ,0.999,
%     
   

% net = trainNetwork(GTtable,layers,options);
net=trainNetwork(GTtable,lgraph_2,options); 

% ypredict=predict(net,Valtable(:,1));
% error=ypredict-GT(1:i,:,zz);
% figure()
% plot(error(:,1),error(:,2),'.')
% title('Residuals')
% xlabel('X error')
% ylabel('Y error')

save([RelativePath '\' Folder '\' textT],'net');
end
