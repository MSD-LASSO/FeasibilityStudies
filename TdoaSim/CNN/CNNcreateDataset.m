function CNNcreateDataset(numImages,outputFolder,AzimuthRange,ElevationRange,SatelliteRangeRange,zPlanes)
%This function will create samples over a range.
%change getReceiverLocations and getErrors functions to modify those
%parameters.

if nargin==0
    close all

    addpath('../LocateSat')
    addpath('../TimeDiff')
    addpath('..');
    numImages=20;
    numImages=[numImages numImages/10]; %first number is for primary, second for other planes. 
    %% Input Ranges
    AzimuthRange=[0 360]; %ALWAYS wrt to the first receiver. 
    ElevationRange=[15 85];
    SatelliteRangeRange=[500e3 5000e3]; %range of satellite range values.
    zPlanes=[400e3 50e3 1200e3]; %primary must be listed first.
    outputFolder='Test11val';
    
end
    
%% Invariants    
[R1,R2,R3,Sphere]=getReceiverLocations;
[ClkError, RL_err]=getErrors;
ReceiverLocations=[R1;R2;R3];
mkdir(['Images/' outputFolder]);
ReceiverError=[zeros(3,3) ClkError];
GND=getStruct(ReceiverLocations,ReceiverError,ReceiverLocations(1,:),ReceiverError(1,:),Sphere);

zNames=getZnames(zPlanes,outputFolder);

numPrimary=numImages(1);
numSecondary=numImages(2);



%% Canonical Form of Image
%not vectorized because of parfor.
Limits=getCanonicalForm(zPlanes,ElevationRange(1));

%% Create numImages
z1=length(zPlanes);
GT=zeros(numPrimary,2,z1);
GTendgoal=zeros(numPrimary,2);
nameBC=cell(numPrimary);
nameNBC=cell(numPrimary);
cols=3;
timeDiffs=zeros(numPrimary,cols);
%here to optimize parfor.
Rx=ReceiverLocations(1,1);
Ry=ReceiverLocations(1,2);
Rz=ReceiverLocations(1,3);
Reference=[Rx,Ry,Rz];
%     zPlanes=zeros(numImages,1);
parfor i=1:numPrimary
    %% Set up problem and get ground truth.
    [Az,El,Rng]=getRandSat(AzimuthRange,ElevationRange,SatelliteRangeRange);
    GTendgoal(i,:)=[Az El];
    [lat, long, h]=enu2geodetic(Rng*cosd(El)*sind(Az),Rng*cosd(El)*cosd(Az),Rng*sind(El),...
        Rx,Ry,Rz,Sphere);
    SAT=getStruct([lat long h],zeros(1,4),Reference,zeros(1,4),Sphere);
    
    [TimeDiff, TimeDiffErr]=timeDiff3toMatrix(GND,SAT);
    
    %% Get the plots
    %Apply the Noise
    distanceDiff=normrnd(TimeDiff,TimeDiffErr)*3e8; %model error as a Gaussian.
    %         timeDiffs(i,:)=[distanceDiff(1,2), distanceDiff(1,3), distanceDiff(2,3) zPlane];
    timeDiffs(i,:)=[distanceDiff(1,2), distanceDiff(1,3), distanceDiff(2,3)];
    %     [RL, RL_err]=geo2rect(ReceiverLocations,ReceiverError,Sphere);
    [X, Y, Z]=geodetic2enu(ReceiverLocations(:,1),ReceiverLocations(:,2),ReceiverLocations(:,3),Rx,Ry,Rz,Sphere);
    RL=normrnd([X Y Z],RL_err);
    
    Hyperboloid=sym(zeros(3,1));
    p=1;
    for ii=1:3
        for j=1:3
            if j>ii
                R1a=RL(ii,:);
                R2a=RL(j,:);
                %assume SymVars is the same for all cases.
                [temp,SymVars]=CreateHyperboloid(R1a,R2a,distanceDiff(ii,j));
                Hyperboloid(p)=temp;
                p=p+1;
            end
        end
    end
    
    %% Convert the numerical data to image.
    %structure of this:
    %every 2 elements in TimeDiffs an zPlane will be saved as pixel
    %value of 2.5x greater.
    %if the value is negative, set px to 255, otherwise px=0.
    
    pp=0;
    pixel=ones(1,224)*255;
    temp=timeDiffs(i,:);
    for jj=1:cols
        pp=pp+1;
        floating=temp(jj);
        if floating>0
            positive=255;
        else
            positive=0;
        end
        str=num2str(floating,'%15.15f');
        
        pixel(pp:pp+2)=positive;
        ppPreLoop=pp;
        kk=1;
        while kk<length(str)-1 && pp<ppPreLoop+45
            pp=pp+3;
            pixel(pp:pp+2)=str2double(str(kk:kk+1))*2.5;
            kk=kk+2;
        end
        if pp<ppPreLoop+45
            pp=ppPreLoop+45;
        end
    end
    
    [GTtemp,bctemp,Nbctemp]=createImage(zPlanes,Az,El,Hyperboloid,SymVars,Limits,i,zNames,pixel,numSecondary,outputFolder);
    GT(i,:,:)=GTtemp;
    nameBC{i}=bctemp;
    nameNBC{i}=Nbctemp;
    
    
%     for zz=1:z1
%         zPlane=zPlanes(zz);
%     
%         %This is ALWAYS measured from Receiver 1. XY position.
%         GT(i,:,zz)=[zPlane*cosd(El)*sind(Az) zPlane*cosd(El)*cosd(Az)]/zPlane;
% 

% 
%         Hyperboloid=sym(zeros(3,1));
%         p=1;
%         for ii=1:3
%             for j=1:3
%                 if j>ii
%                     R1a=RL(ii,:);
%                     R2a=RL(j,:);
%                     %assume SymVars is the same for all cases.
%                     [temp,~]=CreateHyperboloid(R1a,R2a,distanceDiff(ii,j));
%                     Hyperboloid(p)=temp;
%                     p=p+1;
%                 end
%             end
%         end
%         syms z
%         Hyperbola=subs(Hyperboloid,z,zPlane);
% 
%         figure(1)
%         fimplicit(Hyperbola,[Limits(zz,:) Limits(zz,:)],'linewidth',3);
% 
%         %% Convert the numerical data to image.
%         %structure of this:
%         %every 2 elements in TimeDiffs an zPlane will be saved as pixel
%         %value of 2.5x greater.
%         %if the value is negative, set px to 255, otherwise px=0.
% 
%         pp=0;
%         pixel=zeros(1,224);
%         temp=timeDiffs(i,:,zz);
%         for jj=1:cols
%             pp=pp+1;
%             floating=temp(jj);
%             if floating>0
%                 positive=0;
%             else
%                 positive=255;
%             end
%             str=num2str(floating,'%15.15f');
% 
%             pixel(pp:pp+2)=positive;
%             ppPreLoop=pp;
%             kk=1;
%             while kk<length(str)-1 && pp<ppPreLoop+45
%                 pp=pp+3;
%                 pixel(pp:pp+2)=str2double(str(kk:kk+1))*2.5;
%                 kk=kk+2;
%             end
%             if pp<ppPreLoop+45
%                 pp=ppPreLoop+45;
%             end
%         end
% 
% 
% 
%         %% Save Image
%         nameBC{i,zz}=['Images/' outputFolder '/' zNames{zz} '/' num2str(i) '.png'];
%         nameNBC{i,zz}=['Images/' outputFolder 'NBC/' zNames{zz} '/' num2str(i) '.png'];
%         F = getframe;
%         [X, ~]=frame2im(F); %can alternatively collect colormap as well.
%         Xoriginal=X;
%         X(end-5:end,:,1)=repmat(pixel,6,1);
%         X(end-5:end,:,2)=repmat(pixel,6,1);
%         X(end-5:end,:,3)=repmat(pixel,6,1);
% 
%         imwrite(255-X,nameBC{i,zz});
%         imwrite(255-Xoriginal,nameNBC{i,zz});
%         %     imshow(imread(name{i})); %debugging purposes.
%         
%         if i>numSecondary
%             break
%         end
%     end
end

save(outputFolder,'GT','timeDiffs','ReceiverLocations','nameBC','nameNBC')

