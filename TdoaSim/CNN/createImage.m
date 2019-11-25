function [GT,nameBC,nameNBC]=createImage(zPlanes,Az,El,Hyperboloid,Symvars,Limits,i,zNames,pixel,numSecondary,outputFolder)
    z1=length(zPlanes);
    GT=zeros(1,2,z1);
    nameBC=cell(1,z1);
    nameNBC=cell(1,z1);
    
    h1=figure('Position', [100 100 floor(224^3/171/226) floor(224^3/174/227)]);
    for zz=1:z1
        zPlane=zPlanes(zz);
    
        %This is ALWAYS measured from Receiver 1. XY position.
        R=zPlane/sind(El); %minimum elevation
        GT(1,:,zz)=[R*cosd(El)*sind(Az) R*cosd(El)*cosd(Az)]/zPlane;

        Hyperbola=subs(Hyperboloid,Symvars(3),zPlane);

        figure(h1)
        fimplicit(Hyperbola,[Limits(zz,:) Limits(zz,:)],'linewidth',3);


        %% Save Image
        nameBC{zz}=['Images/' outputFolder '/' zNames{zz} '/' num2str(i) '.png'];
        nameNBC{zz}=['Images/' outputFolder '/' zNames{zz} 'NBC/' num2str(i) '.png'];
        F = getframe;
        [X, ~]=frame2im(F); %can alternatively collect colormap as well.
        Xoriginal=X;
        X(end-5:end,:,1)=repmat(pixel,6,1);
        X(end-5:end,:,2)=repmat(pixel,6,1);
        X(end-5:end,:,3)=repmat(pixel,6,1);

        imwrite(255-X,nameBC{zz});
        imwrite(255-Xoriginal,nameNBC{zz});
        %     imshow(imread(name{i})); %debugging purposes.
        
        if i>numSecondary
            break
        end
    end
    close(h1);
end