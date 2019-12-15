function resizeAllImages(ParentFolder,newSize)
if nargin==0
    ParentFolder='Images/Dummy';
    newSize=[224 224];
end

Folders={'50','50NBC','400','400NBC','1200','1200NBC'};

for i=1:length(Folders)
    d=Folders{i};
    a = dir([ParentFolder '/' d '/*.png']);
    for j=1:length(a)
        fileName=[ParentFolder '/' d '/' num2str(j) '.png'];
        Img=imread(fileName);
        Img=imresize(Img,newSize);
        imwrite(Img,fileName);
    end
end


end