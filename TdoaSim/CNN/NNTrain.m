load Test5ValidationExtraStrip.mat
testAns=GT';
testInput=timeDiffs';
load Test5ExtraStrip.mat

inputs= timeDiffs';
targets=GT';
            
hiddenLayerSize =[20];
% Create a Pattern Recognition Network
setdemorandstream(2014784333);   %seed for random number generator
net = feedforwardnet(hiddenLayerSize);

% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 0.8;  %note- splits are done in a random fashion
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.0;

net.trainParam.show=50;  %# of ephocs in display
net.trainParam.lr=0.00025;  %learning rate
net.trainParam.epochs=1000;  %max epochs
% net.trainParam.goal=0.05^2;  %training goal
net.performFcn='mse';  %Name of a network performance function %type help nnperformance
% Train the Network
[net,tr] = train(net,inputs,targets);  %return neural net and a training record
% plotperform(tr); %shows train, validation, and test per epoch


testY = net(testInput);   %pass all inputs through nnet
RSME=sum(sum(sqrt((testY-testAns).^2)))